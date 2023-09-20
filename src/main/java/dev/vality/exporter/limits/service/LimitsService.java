package dev.vality.exporter.limits.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import dev.vality.exporter.limits.entity.LimitConfigEntity;
import dev.vality.exporter.limits.entity.TimeRangeType;
import dev.vality.exporter.limits.error.UnknownLimitTypeException;
import dev.vality.exporter.limits.model.CustomTag;
import dev.vality.exporter.limits.model.LimitType;
import dev.vality.exporter.limits.model.LimitsData;
import dev.vality.exporter.limits.model.Metric;
import dev.vality.exporter.limits.repository.LimitConfigRepository;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.Tags;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("LineLength")
public class LimitsService {

    private final MeterRegistryService meterRegistryService;
    private final Map<String, Double> paymentLimitsBoundaryAggregatesMap;
    private final Map<String, Double> paymentLimitsAmountAggregatesMap;
    private final Map<String, Double> payoutLimitsBoundaryAggregatesMap;
    private final Map<String, Double> payoutLimitsAmountAggregatesMap;
    private final OpenSearchService openSearchService;
    private final LimitConfigRepository limitConfigRepository;
    private final ObjectMapper objectMapper;

    public void registerMetrics() {
        var limitsDataByInterval = openSearchService.getLimitsDataByInterval();
        var limitConfigIds = limitsDataByInterval.stream()
                .map(limitsData -> limitsData.getLimit().getConfigId())
                .distinct()
                .toList();
        var limitConfigEntities = limitConfigRepository.findAllUsingLimitConfigIdsAndTimeRangType(limitConfigIds, TimeRangeType.calendar);
        var limitConfigsById = limitConfigEntities.stream().collect(
                Collectors.groupingBy(
                        o -> o.getPk().getLimitConfigId(),
                        Collectors.mapping(
                                o -> o,
                                Collectors.collectingAndThen(
                                        Collectors.toList(),
                                        values -> values.stream()
                                                .max(Comparator.comparing(limitConfigEntity -> limitConfigEntity.getPk().getSequenceId()))
                                                .orElse(null)))));
        for (var limitsData : limitsDataByInterval) {
            var limitConfigEntity = limitConfigsById.get(limitsData.getLimit().getConfigId());
            if (limitConfigEntity == null) {
                log.warn("limitConfigEntity null, no gauge limitsData {}", limitsData);
                break;
            }

            var limitType = getLimitType(limitsData);
            switch (limitType) {
                case PAYMENT -> {
                    var id = String.format(
                            "%s.%s.%s.%s.%s",
                            limitsData.getLimit().getConfigId(),
                            limitsData.getLimit().getRoute().getProviderId(),
                            limitsData.getLimit().getRoute().getTerminalId(),
                            limitsData.getLimit().getShopId(),
                            limitsData.getLimit().getChange().getCurrency());
                    gauge(paymentLimitsBoundaryAggregatesMap, Metric.CALENDAR_PAYMENT_LIMITS_BOUNDARY, id,
                            getPaymentLimitTags(limitsData, limitConfigEntity),
                            limitsData.getLimit().getBoundary());
                    gauge(paymentLimitsAmountAggregatesMap, Metric.CALENDAR_PAYMENT_LIMITS_AMOUNT, id,
                            getPaymentLimitTags(limitsData,
                            limitConfigEntity), limitsData.getLimit().getAmount());
                }
                case PAYOUT -> {
                    var id = String.format(
                            "%s.%s.%s.%s.%s",
                            limitsData.getLimit().getConfigId(),
                            limitsData.getLimit().getRoute().getProviderId(),
                            limitsData.getLimit().getRoute().getTerminalId(),
                            limitsData.getLimit().getWalletId(),
                            limitsData.getLimit().getChange().getCurrency());
                    gauge(payoutLimitsBoundaryAggregatesMap, Metric.CALENDAR_PAYOUT_LIMITS_BOUNDARY, id,
                            getPayoutLimitTags(limitsData, limitConfigEntity),
                            limitsData.getLimit().getBoundary());
                    gauge(payoutLimitsAmountAggregatesMap, Metric.CALENDAR_PAYOUT_LIMITS_AMOUNT, id,
                            getPayoutLimitTags(limitsData,
                            limitConfigEntity), limitsData.getLimit().getAmount());
                }
                default -> throw new UnknownLimitTypeException(String.format("Limit type '%s' is unknown!", limitType));
            }
        }
        var registeredMetricsSize =
                meterRegistryService.getRegisteredMetricsSize(Metric.CALENDAR_PAYMENT_LIMITS_BOUNDARY.getName()) +
                meterRegistryService.getRegisteredMetricsSize(Metric.CALENDAR_PAYMENT_LIMITS_AMOUNT.getName()) +
                meterRegistryService.getRegisteredMetricsSize(Metric.CALENDAR_PAYOUT_LIMITS_BOUNDARY.getName()) +
                meterRegistryService.getRegisteredMetricsSize(Metric.CALENDAR_PAYOUT_LIMITS_AMOUNT.getName());
        log.info("Limits metrics have been registered to 'prometheus', " +
                "registeredMetricsSize = {}, clientSize = {}", registeredMetricsSize, limitsDataByInterval.size());
    }

    private void gauge(Map<String, Double> storage, Metric metric, String id, Tags tags, String value) {
        if (!storage.containsKey(id)) {
            var gauge = Gauge.builder(metric.getName(), storage, map -> map.get(id))
                    .description(metric.getDescription())
                    .tags(tags);
            meterRegistryService.registry(gauge);
        }
        storage.put(id, Double.parseDouble(value));
    }

    private LimitType getLimitType(LimitsData limitsData) {
        if (!ObjectUtils.isEmpty(limitsData.getPayment())) {
            return LimitType.PAYMENT;
        }

        if (!ObjectUtils.isEmpty(limitsData.getLimit().getWalletId())) {
            return LimitType.PAYOUT;
        }

        throw new UnknownLimitTypeException("Unable to define limit type from this data: " + limitsData);
    }

    private Tags getPaymentLimitTags(LimitsData dto, LimitConfigEntity limitConfigEntity) {
        var tags = Tags.of(
                CustomTag.terminalId(dto.getLimit().getRoute().getTerminalId()),
                CustomTag.providerId(dto.getLimit().getRoute().getProviderId()),
                CustomTag.currency(dto.getLimit().getChange().getCurrency()),
                CustomTag.shopId(dto.getLimit().getShopId()),
                CustomTag.configId(dto.getLimit().getConfigId()),
                CustomTag.timeRangType(limitConfigEntity.getTimeRangType().name()),
                CustomTag.limitContextType(limitConfigEntity.getLimitContextType()),
                CustomTag.limitScopeTypes(getLimitScopeTypes(limitConfigEntity.getLimitScopeTypesJson())));
        return tags.and(getCommonTags(limitConfigEntity));
    }

    private Tags getPayoutLimitTags(LimitsData dto, LimitConfigEntity limitConfigEntity) {
        var tags = Tags.of(
                CustomTag.terminalId(dto.getLimit().getRoute().getTerminalId()),
                CustomTag.providerId(dto.getLimit().getRoute().getProviderId()),
                CustomTag.currency(dto.getLimit().getChange().getCurrency()),
                CustomTag.walletId(dto.getLimit().getWalletId()),
                CustomTag.configId(dto.getLimit().getConfigId()),
                CustomTag.timeRangType(limitConfigEntity.getTimeRangType().name()),
                CustomTag.limitContextType(limitConfigEntity.getLimitContextType()),
                CustomTag.limitScopeTypes(getLimitScopeTypes(limitConfigEntity.getLimitScopeTypesJson())));
        return tags.and(getCommonTags(limitConfigEntity));
    }

    private Tags getCommonTags(LimitConfigEntity limitConfigEntity) {
        Tags tags = Tags.empty();
        if (limitConfigEntity.getTimeRangeTypeCalendar() != null) {
            tags = tags.and(CustomTag.timeRangeTypeCalendar(limitConfigEntity.getTimeRangeTypeCalendar()));
        }
        if (limitConfigEntity.getLimitTypeTurnoverMetric() != null) {
            tags = tags.and(CustomTag.limitTypeTurnoverMetric(limitConfigEntity.getLimitTypeTurnoverMetric()));
        }
        if (limitConfigEntity.getLimitScope() != null) {
            tags = tags.and(CustomTag.limitScope(limitConfigEntity.getLimitScope()));
        }
        if (limitConfigEntity.getOperationLimitBehaviour() != null) {
            tags = tags.and(CustomTag.operationLimitBehaviour(limitConfigEntity.getOperationLimitBehaviour()));
        }
        return tags;
    }

    @SneakyThrows
    private String getLimitScopeTypes(String limitScopeTypesJson) {
        return objectMapper.readValue(limitScopeTypesJson, new TypeReference<List<Map<String, Object>>>() {
                })
                .stream()
                .flatMap(stringObjectMap -> stringObjectMap.keySet().stream())
                .sorted()
                .collect(Collectors.collectingAndThen(
                        Collectors.joining(","),
                        s -> Objects.equals(s, "") ? "all" : s));
    }
}
