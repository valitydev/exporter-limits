package dev.vality.exporter.limits.config;

import dev.vality.exporter.limits.model.Metric;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.MultiGauge;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GaugeConfig {

    @Bean
    public MultiGauge multiGaugeLimitsAmount(MeterRegistry meterRegistry) {
        return MultiGauge.builder(Metric.LIMITS_AMOUNT.getName())
                .description(Metric.LIMITS_AMOUNT.getDescription())
                .register(meterRegistry);
    }
}
