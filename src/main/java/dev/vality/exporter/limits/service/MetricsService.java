package dev.vality.exporter.limits.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class MetricsService {

    private final LimitsService limitsService;

    public void registerMetrics() {
        limitsService.registerMetrics();
    }
}
