package dev.vality.exporter.limits.config;

import lombok.SneakyThrows;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.opensearch.client.RestClient;
import org.opensearch.client.json.jackson.JacksonJsonpMapper;
import org.opensearch.client.opensearch.OpenSearchClient;
import org.opensearch.client.transport.rest_client.RestClientTransport;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

@Configuration
@SuppressWarnings("LineLength")
public class OpenSearchClientConfig {

    @Bean(destroyMethod = "close")
    public RestClient restClient(OpenSearchProperties openSearchProperties) {
        final var credentialsProvider = new BasicCredentialsProvider();
        credentialsProvider.setCredentials(
                AuthScope.ANY,
                new UsernamePasswordCredentials(openSearchProperties.getUsername(), openSearchProperties.getPassword()));
        var httpHost = new HttpHost(openSearchProperties.getHostname(), openSearchProperties.getPort(), "https");
        return RestClient.builder(httpHost)
                .setHttpClientConfigCallback(httpClientBuilder -> httpClientBuilder
                        .setDefaultCredentialsProvider(credentialsProvider)
                        .setSSLContext(sslContext(openSearchProperties.getCertificate()))
                        .setSSLHostnameVerifier(NoopHostnameVerifier.INSTANCE)).build();
    }

    @Bean
    public OpenSearchClient openSearchClient(RestClient restClient) {
        var transport = new RestClientTransport(restClient, new JacksonJsonpMapper());
        return new OpenSearchClient(transport);
    }

    @SneakyThrows
    private SSLContext sslContext(Resource certificate) {
        var tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        try (InputStream pKeyFileStream = certificate.getInputStream()) {
            var cf = CertificateFactory.getInstance("X.509");
            var caCert = (X509Certificate) cf.generateCertificate(pKeyFileStream);
            var ks = KeyStore.getInstance(KeyStore.getDefaultType());
            ks.load(null);
            ks.setCertificateEntry("caCert", caCert);
            tmf.init(ks);
        }
        var sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, tmf.getTrustManagers(), null);
        return sslContext;
    }
}
