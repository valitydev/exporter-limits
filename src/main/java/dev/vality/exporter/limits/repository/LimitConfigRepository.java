package dev.vality.exporter.limits.repository;

import dev.vality.exporter.limits.entity.LimitConfigEntity;
import dev.vality.exporter.limits.entity.LimitConfigPk;
import dev.vality.exporter.limits.entity.TimeRangeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@SuppressWarnings("LineLength")
public interface LimitConfigRepository extends JpaRepository<LimitConfigEntity, LimitConfigPk> {

    @Query(value = "select l " +
            "from LimitConfigEntity as l " +
            "where l.pk.limitConfigId in :limitConfigIds " +
            "and l.timeRangType = :timeRangType " +
            "and l.current = true"
    )
    List<LimitConfigEntity> findAllUsingLimitConfigIdsAndTimeRangType(@Param("limitConfigIds") List<String> limitConfigIds, @Param("timeRangType") TimeRangeType timeRangType);

}
