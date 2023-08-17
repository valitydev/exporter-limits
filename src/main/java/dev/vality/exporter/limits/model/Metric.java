package dev.vality.exporter.limits.model;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public enum Metric {

    CALENDAR_LIMITS_BOUNDARY(
            formatWithPrefix("limits_boundary_by_calendar"),
            "Calendar limits boundary since last scrape"),
    CALENDAR_LIMITS_AMOUNT(
            formatWithPrefix("limits_amount_by_calendar"),
            "Calendar limits amount since last scrape");

    @Getter
    private final String name;
    @Getter
    private final String description;

    private static String formatWithPrefix(String name) {
        return String.format("el_%s", name);
    }
}
