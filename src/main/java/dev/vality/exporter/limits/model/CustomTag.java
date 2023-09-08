package dev.vality.exporter.limits.model;

import io.micrometer.core.instrument.Tag;
import lombok.experimental.UtilityClass;

@UtilityClass
public class CustomTag {

    public static final String PROVIDER_ID_TAG = "provider_id";
    public static final String TERMINAL_ID_TAG = "terminal_id";
    public static final String SHOP_ID_TAG = "shop_id";
    public static final String WALLET_ID_TAG = "wallet_id";
    public static final String CURRENCY_TAG = "currency";
    public static final String CONFIG_ID_TAG = "config_id";
    public static final String TIME_RANGE_TYPE = "time_range_type";
    public static final String TIME_RANGE_TYPE_CALENDAR = "time_range_type_calendar";
    public static final String LIMIT_CONTEXT_TYPE = "limit_context_type";
    public static final String LIMIT_TYPE_TURNOVER_METRIC = "limit_type_turnover_metric";
    public static final String LIMIT_SCOPE = "limit_scope";
    public static final String OPERATION_LIMIT_BEHAVIOUR = "operation_limit_behaviour";
    public static final String LIMIT_SCOPE_TYPES = "limit_scope_types";

    public static Tag providerId(String providerId) {
        return Tag.of(PROVIDER_ID_TAG, providerId);
    }

    public static Tag terminalId(String terminalId) {
        return Tag.of(TERMINAL_ID_TAG, terminalId);
    }

    public static Tag shopId(String shopId) {
        return Tag.of(SHOP_ID_TAG, shopId);
    }

    public static Tag walletId(String walletId) {
        return Tag.of(WALLET_ID_TAG, walletId);
    }

    public static Tag currency(String currency) {
        return Tag.of(CURRENCY_TAG, currency);
    }

    public static Tag configId(String configId) {
        return Tag.of(CONFIG_ID_TAG, configId);
    }

    public static Tag timeRangType(String timeRangType) {
        return Tag.of(TIME_RANGE_TYPE, timeRangType);
    }

    public static Tag timeRangeTypeCalendar(String timeRangeTypeCalendar) {
        return Tag.of(TIME_RANGE_TYPE_CALENDAR, timeRangeTypeCalendar);
    }

    public static Tag limitContextType(String limitContextType) {
        return Tag.of(LIMIT_CONTEXT_TYPE, limitContextType);
    }

    public static Tag limitTypeTurnoverMetric(String limitTypeTurnoverMetric) {
        return Tag.of(LIMIT_TYPE_TURNOVER_METRIC, limitTypeTurnoverMetric);
    }

    public static Tag limitScope(String limitScope) {
        return Tag.of(LIMIT_SCOPE, limitScope);
    }

    public static Tag operationLimitBehaviour(String operationLimitBehaviour) {
        return Tag.of(OPERATION_LIMIT_BEHAVIOUR, operationLimitBehaviour);
    }

    public static Tag limitScopeTypes(String limitScopeTypes) {
        return Tag.of(LIMIT_SCOPE_TYPES, limitScopeTypes);
    }
}
