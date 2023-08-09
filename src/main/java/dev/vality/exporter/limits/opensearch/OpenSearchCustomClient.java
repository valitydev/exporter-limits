package dev.vality.exporter.limits.opensearch;

import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import org.opensearch.client.json.JsonData;
import org.opensearch.client.opensearch.OpenSearchClient;
import org.opensearch.client.opensearch._types.query_dsl.Query;
import org.opensearch.client.opensearch._types.query_dsl.RangeQuery;
import org.opensearch.client.opensearch.core.SearchRequest;
import org.opensearch.client.opensearch.core.search.Hit;
import org.opensearch.client.util.ObjectBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OpenSearchCustomClient {

    private final OpenSearchClient openSearchClient;

    @Value("${interval.time}")
    private String intervalTime;

    @SneakyThrows
    public List<LimitsData> getLimitsData() {
        var searchRequest = new SearchRequest.Builder()
                .query(q -> q.match(builder -> builder.field("message")
                        .query(builder1 -> builder1.stringValue("Limit change commited"))))
                .query(q -> q.bool(builder -> builder.filter(this::range)))
                .build();
        return openSearchClient.search(searchRequest, LimitsData.class).hits().hits()
                .stream()
                .map(Hit::source)
                .collect(Collectors.toList());
    }

    private ObjectBuilder<Query> range(Query.Builder builder1) {
        return builder1.range(this::timestamp);
    }

    private RangeQuery.Builder timestamp(RangeQuery.Builder builder2) {
        return builder2.field("@timestamp").gte(JsonData.of(String.format("now-%ss", intervalTime)));
    }
}
