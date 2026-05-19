# observability-paas

PaaS-only overlay for the `observability` chart. Adds:

-   the `builds` dashboard, which queries GCP Cloud Logging log-based metrics
    via the `googlecloud-logging-datasource` plugin
-   the GCP Managed Prometheus datasource-syncer CronJob plus its post-install
    Grafana Service Account / token bootstrap hook
-   an optional CronJob that deletes manually-provisioned Grafana resources
    (off by default)

## Supported clouds

Today: **GCP only.** Helm template will fail with a clear message if
`observability.cloudProvider` is set to anything other than `gcp`. AWS support
is planned but out of scope for this iteration — the PaaS build pipeline on
AWS hasn't been decided, and the GMP datasource-syncer is GCP-specific.
