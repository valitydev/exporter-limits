package dev.vality.exporter.limits.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;

@Entity
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "limit_config")
public class LimitConfigEntity implements Serializable {

    @EmbeddedId
    private LimitConfigPk pk;

    @Column(name = "time_range_type")
    private String timeRangType;

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

}
