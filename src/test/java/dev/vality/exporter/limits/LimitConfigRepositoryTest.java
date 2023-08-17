package dev.vality.exporter.limits;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import dev.vality.exporter.limits.entity.TimeRangeType;
import dev.vality.exporter.limits.repository.LimitConfigRepository;
import io.micrometer.core.instrument.Tag;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.opensearch.client.RestClient;
import org.opensearch.client.opensearch.OpenSearchClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.TestPropertySource;

import java.util.List;
import java.util.Map;

@SpringBootTest
@TestPropertySource({"classpath:application.yml"})
@DirtiesContext
@Slf4j
@Disabled
@SuppressWarnings("LineLength")
public class LimitConfigRepositoryTest {

    @MockBean
    private RestClient restClient;

    @MockBean
    private OpenSearchClient openSearchClient;

    @Autowired
    private LimitConfigRepository limitConfigRepository;

    @Test
    @SneakyThrows
    public void findAllUsingLimitConfigIdsAndTimeRangTypeTest() {
        var limitConfigEntities = limitConfigRepository.findAllUsingLimitConfigIdsAndTimeRangType(List.of("yXAu"), TimeRangeType.calendar);
        var limitConfigEntity = limitConfigEntities.get(0);
        Assertions.assertEquals(1425107996, limitConfigEntity.getPk().getSequenceId());
        var tags = new ObjectMapper().readValue(limitConfigEntity.getLimitScopeTypesJson(), new TypeReference<List<Map<String, Object>>>() {
                })
                .stream()
                .flatMap(stringObjectMap -> stringObjectMap.keySet().stream())
                .map(s -> Tag.of(String.format("limit_scope_type_%s", s), "true"))
                .toList();
        Assertions.assertEquals(3, tags.size());
    }
}
