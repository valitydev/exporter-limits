package dev.vality.exporter.limits.service;

import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MeterRegistryService {

    private final MeterRegistry meterRegistry;

    public <T> void registry(Gauge.Builder<T> builder) {
        builder.register(meterRegistry);
    }

    public long getRegisteredMetricsSize(String name) {
        return meterRegistry.getMeters().stream()
                .filter(meter -> meter.getId().getName().equals(name))
                .filter(Gauge.class::isInstance)
                .count();
    }
}
