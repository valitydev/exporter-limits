package dev.vality.exporter.limits.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
public class StorageConfig {

    @Bean
    public Map<String, Double> paymentlimitsBoundaryAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> paymentlimitsAmountAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> payoutlimitsBoundaryAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> payoutlimitsAmountAggregatesMap() {
        return new ConcurrentHashMap<>();
    }
}
