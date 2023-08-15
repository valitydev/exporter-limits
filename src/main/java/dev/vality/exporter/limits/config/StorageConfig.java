package dev.vality.exporter.limits.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Configuration
public class StorageConfig {

    @Bean
    public Map<String, Double> limitsBoundaryAggregatesMap() {
        return new ConcurrentHashMap<>();
    }

    @Bean
    public Map<String, Double> limitsAmountAggregatesMap() {
        return new ConcurrentHashMap<>();
    }
}
