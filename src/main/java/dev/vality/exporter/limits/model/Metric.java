package dev.vality.exporter.limits.model;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public enum Metric {

    LIMITS_BOUNDARY(
            formatWithPrefix("limits_boundary"),
            "Limits boundary since last scrape"),
    LIMITS_AMOUNT(
            formatWithPrefix("limits_amount"),
            "Limits amount since last scrape");

    @Getter
    private final String name;
    @Getter
    private final String description;

    private static String formatWithPrefix(String name) {
        return String.format("el_%s", name);
    }
}
