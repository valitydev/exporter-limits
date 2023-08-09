package dev.vality.exporter.limits.opensearch;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LimitsData {

    private Payment payment;
    private Machine machine;
    private Limit limit;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Payment {

        private String id;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Machine {

        private String id;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Limit {

        private Integer amount;
        private Integer boundary;
        private Change change;
        @JsonProperty("config_id")
        private String configId;
        @JsonProperty("party_id")
        private String partyId;
        private Route route;
        @JsonProperty("shop_id")
        private String shopId;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Change {

        private Integer amount;
        private String currency;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Route {

        @JsonProperty("provider_id")
        private Integer providerId;
        @JsonProperty("terminal_id")
        private Integer terminalId;

    }
}
