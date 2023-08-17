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
import io.micrometer.core.instrument.Tag;
import io.micrometer.core.instrument.Tags;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
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
        log.info("limitsDataByInterval {}", limitsDataByInterval);
        var limitConfigIds = limitsDataByInterval.stream()
                .map(limitsData -> limitsData.getLimit().getConfigId())
                .distinct()
                .toList();
        log.info("limitConfigIds {}", limitConfigIds);
        var limitConfigEntities = limitConfigRepository.findAllUsingLimitConfigIdsAndTimeRangType(limitConfigIds, TimeRangeType.calendar);
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
        return Tags.of(
                        CustomTag.terminalId(dto.getLimit().getRoute().getTerminalId()),
                        CustomTag.providerId(dto.getLimit().getRoute().getProviderId()),
                        CustomTag.currency(dto.getLimit().getChange().getCurrency()),
                        CustomTag.shopId(dto.getLimit().getShopId()),
                        CustomTag.configId(dto.getLimit().getConfigId()),
                        CustomTag.timeRangType(limitConfigEntity.getTimeRangType().name()),
                        CustomTag.timeRangeTypeCalendar(limitConfigEntity.getTimeRangeTypeCalendar()),
                        CustomTag.limitContextType(limitConfigEntity.getLimitContextType()),
                        CustomTag.limitTypeTurnoverMetric(limitConfigEntity.getLimitTypeTurnoverMetric()),
                        CustomTag.limitScope(limitConfigEntity.getLimitScope()),
                        CustomTag.operationLimitBehaviour(limitConfigEntity.getOperationLimitBehaviour()))
                .and(getLimitScopeTypeTags(limitConfigEntity.getLimitScopeTypesJson()));
    }

    @SneakyThrows
    private List<Tag> getLimitScopeTypeTags(String limitScopeTypesJson) {
        return objectMapper.readValue(limitScopeTypesJson, new TypeReference<List<Map<String, Object>>>() {
                })
                .stream()
                .flatMap(stringObjectMap -> stringObjectMap.keySet().stream())
                .map(s -> Tag.of(String.format("limit_scope_type_%s", s), "true"))
                .collect(Collectors.toList());
    }
}
