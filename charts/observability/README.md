# observability

Cloud-agnostic Grafana + kube-state-metrics chart. Wires Managed Prometheus (GMP
on GCP, AMP on AWS) as a Grafana datasource and ships the universal Liferay
dashboards and alert rules. Self-hosted customers install this chart directly;
the PaaS deployment installs `observability-paas`, which depends on this chart.

## Cloud selection

Set `cloudProvider` to either `aws` or `gcp`. This switches:

-   the Grafana Prometheus datasource (sigv4 against AMP on AWS, OAuth against
    GMP on GCP — the OAuth token rotation belongs to `observability-paas`)
-   the scrape-configuration resources (`PodMonitoring` on GCP, `ScrapeConfig`
    on AWS)

## Customer-configurable surface

The chart does not prescribe a custom domain, ingress class, or SMTP server.
Operators are expected to configure these via values:

-   `grafana.ingress` (`enabled`, `ingressClassName`, `annotations`, `hosts`,
    `tls`) — see the upstream grafana subchart for the full schema.
-   `grafana.smtp` — set `enabled: true` and either inline `host`/`user`/
    `password`, or reference an existing secret via `existingSecret`.
-   `grafana.adminCredentials.existingSecret` — set this if you provision the
    Grafana admin credentials yourself (e.g. via External Secrets / SOPS).

## Scraping

`observability` scrapes the following with cloud-specific CRDs:

-   `kube-state-metrics` (KSM allowlist expanded to include
    `kube_pod_container_resource_{limits,requests,info}`)
-   `kubelet/cAdvisor`
-   `prometheus-node-exporter`
-   `prometheus-pushgateway`

This is intentional: GKE's Stackdriver agent surfaced `kubernetes_io:*` metrics
"for free" through GMP, but no equivalent exists on EKS/AMP. The chart's
dashboards and alert rules are written against cAdvisor + KSM-native metric
names so the same set works on both clouds.
