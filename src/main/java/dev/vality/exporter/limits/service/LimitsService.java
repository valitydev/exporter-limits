package dev.vality.exporter.limits.service;

import dev.vality.exporter.limits.model.CustomTag;
import dev.vality.exporter.limits.model.LimitsData;
import dev.vality.exporter.limits.model.Metric;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.Tags;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
@SuppressWarnings("LineLength")
public class LimitsService {

    private final MeterRegistryService meterRegistryService;
    private final Map<String, Double> limitsBoundaryAggregatesMap;
    private final Map<String, Double> limitsAmountAggregatesMap;
    private final OpenSearchService openSearchService;

    public void registerMetrics() {
        var limitsDataByInterval = openSearchService.getLimitsDataByInterval();
        for (var limitsData : limitsDataByInterval) {
            var id = String.format(
                    "%s.%s.%s.%s.%s",
                    limitsData.getLimit().getConfigId(),
                    limitsData.getLimit().getRoute().getProviderId(),
                    limitsData.getLimit().getRoute().getTerminalId(),
                    limitsData.getLimit().getShopId(),
                    limitsData.getLimit().getChange().getCurrency());
            gauge(limitsBoundaryAggregatesMap, Metric.LIMITS_BOUNDARY, id, getTags(limitsData), limitsData.getLimit().getBoundary());
            gauge(limitsAmountAggregatesMap, Metric.LIMITS_AMOUNT, id, getTags(limitsData), limitsData.getLimit().getAmount());
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

    private Tags getTags(LimitsData dto) {
        return Tags.of(
                CustomTag.terminalId(dto.getLimit().getRoute().getTerminalId()),
                CustomTag.providerId(dto.getLimit().getRoute().getProviderId()),
                CustomTag.currency(dto.getLimit().getChange().getCurrency()),
                CustomTag.shopId(dto.getLimit().getShopId()),
                CustomTag.configId(dto.getLimit().getConfigId()));
    }
}
