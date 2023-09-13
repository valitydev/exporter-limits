package dev.vality.exporter.limits.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
public class StorageConfig {

    @Bean
    public Map<String, Double> paymentLimitsBoundaryAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> paymentLimitsAmountAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> payoutLimitsBoundaryAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> payoutLimitsAmountAggregatesMap() {
        return new ConcurrentHashMap<>();
    }
}
