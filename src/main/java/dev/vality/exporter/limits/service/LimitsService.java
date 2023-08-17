package dev.vality.exporter.limits.service;

import dev.vality.exporter.limits.entity.LimitConfigEntity;
import dev.vality.exporter.limits.model.CustomTag;
import dev.vality.exporter.limits.model.LimitsData;
import dev.vality.exporter.limits.model.Metric;
import dev.vality.exporter.limits.repository.LimitConfigRepository;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.Tags;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("LineLength")
public class LimitsService {

    private static final String CALENDAR = "calendar";

    private final MeterRegistryService meterRegistryService;
    private final Map<String, Double> limitsBoundaryAggregatesMap;
    private final Map<String, Double> limitsAmountAggregatesMap;
    private final OpenSearchService openSearchService;
    private final LimitConfigRepository limitConfigRepository;

    public void registerMetrics() {
        var limitsDataByInterval = openSearchService.getLimitsDataByInterval();
        log.info("limitsDataByInterval {}", limitsDataByInterval);
        var limitConfigIds = limitsDataByInterval.stream()
                .map(limitsData -> limitsData.getLimit().getConfigId())
                .distinct()
                .toList();
        log.info("limitConfigIds {}", limitConfigIds);
        var limitConfigEntities = limitConfigRepository.findAllUsingLimitConfigIdsAndTimeRangType(limitConfigIds, CALENDAR);
        log.info("limitConfigEntities {}", limitConfigEntities);
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
        log.info("limitConfigsById {}", limitConfigsById);
        for (var limitsData : limitsDataByInterval) {
            var limitConfigEntity = limitConfigsById.get(limitsData.getLimit().getConfigId());
            if (limitConfigEntity == null) {
                break;
            }
            var id = String.format(
                    "%s.%s.%s.%s.%s",
                    limitsData.getLimit().getConfigId(),
                    limitsData.getLimit().getRoute().getProviderId(),
                    limitsData.getLimit().getRoute().getTerminalId(),
                    limitsData.getLimit().getShopId(),
                    limitsData.getLimit().getChange().getCurrency());
            log.info("id {}", id);
            gauge(limitsBoundaryAggregatesMap, Metric.LIMITS_BOUNDARY, id, getTags(limitsData, limitConfigEntity), limitsData.getLimit().getBoundary());
            gauge(limitsAmountAggregatesMap, Metric.LIMITS_AMOUNT, id, getTags(limitsData, limitConfigEntity), limitsData.getLimit().getAmount());
        }
        var registeredMetricsSize = meterRegistryService.getRegisteredMetricsSize(Metric.LIMITS_BOUNDARY.getName()) + meterRegistryService.getRegisteredMetricsSize(Metric.LIMITS_AMOUNT.getName());
        log.info("Limits with final statuses metrics have been registered to 'prometheus', " +
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
        return Tags.of(
                CustomTag.terminalId(dto.getLimit().getRoute().getTerminalId()),
                CustomTag.providerId(dto.getLimit().getRoute().getProviderId()),
                CustomTag.currency(dto.getLimit().getChange().getCurrency()),
                CustomTag.shopId(dto.getLimit().getShopId()),
                CustomTag.configId(dto.getLimit().getConfigId()),
                CustomTag.timeRangType(limitConfigEntity.getTimeRangType()),
                CustomTag.timeRangeTypeCalendar(limitConfigEntity.getTimeRangeTypeCalendar()),
                CustomTag.limitContextType(limitConfigEntity.getLimitContextType()),
                CustomTag.limitTypeTurnoverMetric(limitConfigEntity.getLimitTypeTurnoverMetric()),
                CustomTag.limitScope(limitConfigEntity.getLimitScope()),
                CustomTag.operationLimitBehaviour(limitConfigEntity.getOperationLimitBehaviour()));
    }
}
