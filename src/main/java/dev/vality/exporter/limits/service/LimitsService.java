package dev.vality.exporter.limits.service;

import dev.vality.exporter.limits.opensearch.OpenSearchCustomClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class LimitsService {

    private final OpenSearchCustomClient openSearchCustomClient;

    public void registerMetrics() {
        var limitsData = openSearchCustomClient.getLimitsData();
        log.info("limitsData {}", limitsData);
    }
}
