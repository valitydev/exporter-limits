package dev.vality.exporter.limits.repository;

import dev.vality.exporter.limits.entity.LimitConfigEntity;
import dev.vality.exporter.limits.entity.LimitConfigPk;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@SuppressWarnings("LineLength")
public interface LimitConfigRepository extends JpaRepository<LimitConfigEntity, LimitConfigPk> {

    @Query(value = "select lc " +
            "from LimitConfigEntity as lc " +
            "where lc.limit_config_id in :limitConfigIds " +
            "and lc.time_range_type = :time_range_type" +
            "and lc.current = true")
    List<LimitConfigEntity> findAllUsingLimitConfigIdsAndTimeRangType(@Param("limitConfigIds") List<String> limitConfigIds, @Param("time_range_type") String timeRangType);

}
