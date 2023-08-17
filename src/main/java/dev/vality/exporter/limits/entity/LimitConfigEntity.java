package dev.vality.exporter.limits.entity;

import dev.vality.exporter.limits.entity.naming.PostgresEnumType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Type;
import org.hibernate.annotations.TypeDef;

import javax.persistence.*;
import java.io.Serializable;

@Entity
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "limit_config")
@TypeDef(name = "pgsql_enum", typeClass = PostgresEnumType.class)
public class LimitConfigEntity implements Serializable {

    @EmbeddedId
    private LimitConfigPk pk;

    @Column(name = "time_range_type")
    @Enumerated(EnumType.STRING)
    @Type(type = "pgsql_enum")
    private TimeRangeType timeRangType;

    @Column(name = "time_range_type_calendar")
    private String timeRangeTypeCalendar;

    @Column(name = "limit_context_type")
    private String limitContextType;

    @Column(name = "limit_type_turnover_metric")
    private String limitTypeTurnoverMetric;

    @Column(name = "limit_scope")
    private String limitScope;

    @Column(name = "operation_limit_behaviour")
    private String operationLimitBehaviour;

    @Column(name = "limit_scope_types_json")
    private String limitScopeTypesJson;

    @Column(name = "current")
    private Boolean current;

}
