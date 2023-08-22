package dev.vality.exporter.limits.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import dev.vality.exporter.limits.entity.LimitConfigEntity;
import dev.vality.exporter.limits.entity.TimeRangeType;
import dev.vality.exporter.limits.model.CustomTag;
import dev.vality.exporter.limits.model.LimitsData;
import dev.vality.exporter.limits.model.Metric;
import dev.vality.exporter.limits.repository.LimitConfigRepository;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.Tags;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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
    private final Map<String, Double> limitsBoundaryAggregatesMap;
    private final Map<String, Double> limitsAmountAggregatesMap;
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
            var id = String.format(
                    "%s.%s.%s.%s.%s",
                    limitsData.getLimit().getConfigId(),
                    limitsData.getLimit().getRoute().getProviderId(),
                    limitsData.getLimit().getRoute().getTerminalId(),
                    limitsData.getLimit().getShopId(),
                    limitsData.getLimit().getChange().getCurrency());
            gauge(limitsBoundaryAggregatesMap, Metric.CALENDAR_LIMITS_BOUNDARY, id, getTags(limitsData, limitConfigEntity), limitsData.getLimit().getBoundary());
            gauge(limitsAmountAggregatesMap, Metric.CALENDAR_LIMITS_AMOUNT, id, getTags(limitsData, limitConfigEntity), limitsData.getLimit().getAmount());
        }
        var registeredMetricsSize = meterRegistryService.getRegisteredMetricsSize(Metric.CALENDAR_LIMITS_BOUNDARY.getName()) + meterRegistryService.getRegisteredMetricsSize(Metric.CALENDAR_LIMITS_AMOUNT.getName());
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

    private Tags getTags(LimitsData dto, LimitConfigEntity limitConfigEntity) {
        var tags = Tags.of(
                        CustomTag.terminalId(dto.getLimit().getRoute().getTerminalId()),
                        CustomTag.providerId(dto.getLimit().getRoute().getProviderId()),
                        CustomTag.currency(dto.getLimit().getChange().getCurrency()),
                        CustomTag.shopId(dto.getLimit().getShopId()),
                        CustomTag.configId(dto.getLimit().getConfigId()),
                        CustomTag.timeRangType(limitConfigEntity.getTimeRangType().name()),
                        CustomTag.limitContextType(limitConfigEntity.getLimitContextType()),
                        CustomTag.limitScopeTypes(getLimitScopeTypes(limitConfigEntity.getLimitScopeTypesJson())))
                .and(getLimitScopeTypes(limitConfigEntity.getLimitScopeTypesJson()));
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
                .collect(Collectors.collectingAndThen(
                        Collectors.joining(","),
                        s -> Objects.equals(s, "") ? "all" : s));
    }
}
