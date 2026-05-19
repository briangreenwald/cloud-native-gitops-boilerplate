{{- define "observability-paas.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "observability-paas.fullname" -}}
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

{{- define "observability-paas.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "observability-paas.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "observability-paas.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "observability-paas.name" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
component: observability-paas
helm.sh/chart: {{ include "observability-paas.chart" . }}
{{- end }}

{{/*
Grafana fullname from the observability subchart. Used by the syncer and
cleanup jobs to talk to Grafana's HTTP API.
*/}}
{{- define "observability-paas.grafana.fullname" -}}
{{- printf "%s-grafana" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "observability-paas.grafana.internalHost" -}}
http://{{ include "observability-paas.grafana.fullname" . }}.{{ .Release.Namespace }}.svc
{{- end -}}

{{/*
The Kubernetes Secret name where the Grafana admin credentials live. Defaults
to the upstream Grafana subchart's convention ({release}-grafana).
*/}}
{{- define "observability-paas.grafana.adminSecretName" -}}
{{- include "observability-paas.grafana.fullname" . -}}
{{- end -}}

{{/*
Grafana credentials env block for the syncer + cleanup jobs.
*/}}
{{- define "observability-paas.grafana.credentialsEnv" -}}
-   name: GRAFANA_USER
    valueFrom:
        secretKeyRef:
            key: admin-user
            name: {{ include "observability-paas.grafana.adminSecretName" . | quote }}
-   name: GRAFANA_PASSWORD
    valueFrom:
        secretKeyRef:
            key: admin-password
            name: {{ include "observability-paas.grafana.adminSecretName" . | quote }}
-   name: GRAFANA_HOST
    value: {{ include "observability-paas.grafana.internalHost" . | quote }}
{{- end -}}

{{/*
Datasource-syncer fullname.
*/}}
{{- define "observability-paas.datasourceSyncer.fullname" -}}
{{- printf "%s-gmp-datasource-syncer" (include "observability-paas.grafana.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Grafana SA token Secret name used by the datasource-syncer when
serviceAccountTokenInFile=false.
*/}}
{{- define "observability-paas.datasourceSyncer.tokenSecretName" -}}
{{- printf "%s-token-secret" (include "observability-paas.datasourceSyncer.fullname" .) -}}
{{- end -}}

{{/*
Cleanup-cronjob fullname.
*/}}
{{- define "observability-paas.cleanup.fullname" -}}
{{- printf "%s-cleanup" (include "observability-paas.grafana.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
