package dev.vality.exporter.limits.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import java.io.Serializable;

@Embeddable
@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class LimitConfigPk implements Serializable {

    @Column(name = "limit_config_id")
    private String limitConfigId;

    @Column(name = "sequence_id")
    private Long sequenceId;

}
