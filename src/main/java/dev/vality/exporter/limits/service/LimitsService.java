package dev.vality.exporter.limits.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class LimitsService {

    private final OpenSearchService openSearchService;

    public void registerMetrics() {
        var limitsData = openSearchService.getLimitsDataByInterval();
        log.info("limitsData {}", limitsData);
    }
}
