{{- define "observability.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "observability.customLabels" -}}
{{- with .Values.customLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "observability.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "observability.labels" -}}
{{ include "observability.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
component: observability
helm.sh/chart: {{ include "observability.chart" . }}
{{- include "observability.customLabels" . }}
{{- end }}

{{- define "observability.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "observability.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "observability.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "observability.name" . }}
{{- end }}

{{/*
The shared datasource UID used by all dashboards/alerts. Helm value-driven so
that different deployments can wire the same dashboards against different
Prometheus datasources (gmp on GCP, amp on AWS, customer-managed elsewhere).
*/}}
{{- define "observability.datasourceUid" -}}
{{- .Values.datasource.uid -}}
{{- end -}}

{{- define "observability.cloudProvider" -}}
{{- required "cloudProvider must be set to one of: aws, gcp" .Values.cloudProvider -}}
{{- end -}}

{{/*
Grafana fullname — defers to the upstream grafana chart's helper if the
subchart is reachable, otherwise falls back to a sensible default.
*/}}
{{- define "observability.grafana.fullname" -}}
{{- $grafanaCtx := index .Subcharts "grafana" -}}
{{- if $grafanaCtx -}}
{{- include "grafana.fullname" $grafanaCtx -}}
{{- else -}}
{{- printf "%s-grafana" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Grafana internal cluster URL.
*/}}
{{- define "observability.grafana.internalHost" -}}
{{- $grafanaFullname := include "observability.grafana.fullname" . -}}
http://{{ $grafanaFullname }}.{{ .Release.Namespace }}.svc
{{- end -}}
