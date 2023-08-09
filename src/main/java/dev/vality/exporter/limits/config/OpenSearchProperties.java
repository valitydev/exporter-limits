package dev.vality.exporter.limits.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

@Data
@Configuration
@ConfigurationProperties(prefix = "opensearch")
public class OpenSearchProperties {

    private String username;
    private String password;
    private String hostname;
    private Integer port;
    private Resource certificate;

}
