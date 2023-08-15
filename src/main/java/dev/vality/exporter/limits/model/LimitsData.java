package dev.vality.exporter.limits.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class LimitsData {

    private Payment payment;
    private Machine machine;
    private Limit limit;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Payment {

        private String id;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Machine {

        private String id;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Limit {

        private String amount;
        private String boundary;
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
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Change {

        private String amount;
        private String currency;

    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Route {

        @JsonProperty("provider_id")
        private String providerId;
        @JsonProperty("terminal_id")
        private String terminalId;

    }
}
