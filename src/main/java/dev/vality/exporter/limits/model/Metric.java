package dev.vality.exporter.limits.model;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public enum Metric {

    CALENDAR_PAYMENT_LIMITS_BOUNDARY(
            formatWithPrefix("payment_limits_boundary_by_calendar"),
            "Calendar payment limits boundary since last scrape"),
    CALENDAR_PAYMENT_LIMITS_AMOUNT(
            formatWithPrefix("payment_limits_amount_by_calendar"),
            "Calendar payment limits amount since last scrape"),

    CALENDAR_PAYOUT_LIMITS_BOUNDARY(
            formatWithPrefix("payout_limits_boundary_by_calendar"),
            "Calendar payout limits boundary since last scrape"),
    CALENDAR_PAYOUT_LIMITS_AMOUNT(
            formatWithPrefix("payout_limits_amount_by_calendar"),
            "Calendar payout limits amount since last scrape");

    @Getter
    private final String name;
    @Getter
    private final String description;

    private static String formatWithPrefix(String name) {
        return String.format("el_%s", name);
    }
}
