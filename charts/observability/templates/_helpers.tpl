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

{{- define "observability.datasourceUid" -}}
{{- .Values.datasource.uid -}}
{{- end -}}

{{- define "observability.cloudProvider" -}}
{{- required "cloudProvider must be set to one of: aws, gcp" .Values.cloudProvider -}}
{{- end -}}

{{- define "observability.grafana.fullname" -}}
{{- $grafanaCtx := index .Subcharts "grafana" -}}
{{- if $grafanaCtx -}}
{{- include "grafana.fullname" $grafanaCtx -}}
{{- else -}}
{{- printf "%s-grafana" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "observability.grafana.internalHost" -}}
{{- $grafanaFullname := include "observability.grafana.fullname" . -}}
http://{{ $grafanaFullname }}.{{ .Release.Namespace }}.svc
{{- end -}}

{{- define "observability.dashboardHeaderHTML" -}}
<div style="padding: 16px 24px; background-color: #f8fafc; border: 1px solid #e5e7eb; border-radius: 8px; font-family: 'Inter', system-ui, sans-serif; display: flex; flex-wrap: wrap; gap: 24px; align-items: center; width: 100%; box-sizing: border-box; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);">
    <a href="/d/central-hub/central-hub" style="background-color: #f8fafc; border: 2px solid #3274d9; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
            <span style="font-size: 24px;">🏠</span>
        </div>
        <div style="color: #1e3a8a; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Central Hub</div>
        <div style="color: #64748b; font-size: 12px; line-height: 1.3;">Platform overview.</div>
    </a>
    <div style="margin-left: 24px;">
        <h2 style="margin: 0; color: #111827; font-size: 20px; font-weight: 800;">{{ .title }}</h2>
        <p style="margin: 4px 0 0 0; color: #4b5563; font-size: 13px;">{{ .subtitle }}</p>
    </div>
    <div style="display: flex; align-items: center; gap: 8px; margin-left: auto;">
        <span style="color: #6b7280; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Environment:</span>
        <span style="color: #111827; font-size: 14px; font-weight: 700; background: #e2e8f0; padding: 4px 10px; border-radius: 6px;">${environment:text}</span>
    </div>
</div>
{{- end -}}

{{- define "observability.htmlToJSON" -}}
{{- printf "\"%s\"" (. | replace "\\" "\\\\" | replace "\"" "\\\"" | replace "\n" "\\n") -}}
{{- end -}}

{{- define "observability.dashboardHeaderJSON" -}}
{{- include "observability.htmlToJSON" (include "observability.dashboardHeaderHTML" .) -}}
{{- end -}}

{{- define "observability.centralHubHTML" -}}
<div style="padding: 32px; background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 12px; font-family: 'Inter', system-ui, sans-serif; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); position: relative; box-sizing: border-box; width: 100%;">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; position: relative; z-index: 1; flex-wrap: wrap; gap: 16px; width: 100%;">

        <div style="height: 30px; display: flex; align-items: center; flex: 1 1 0;">
            <img src="data:image/png;base64,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" style="height: 35px; width: auto;" alt="Liferay Logo">
        </div>

        <div style="position: absolute; left: 50%; transform: translateX(-50%); text-align: center; white-space: nowrap;">
            <h2 style="margin: 0; font-size: 28px; font-weight: 800; color: #1e3a8a; letter-spacing: -0.5px;">Central Hub</h2>
        </div>

        <div style="flex: 1 1 0;"></div>
    </div>

    <div style="display: flex; flex-wrap: wrap; gap: 32px; width: 100%; position: relative; z-index: 1;">

        <div style="width: 49%; flex: 1 1 40%; min-width: 500px; box-sizing: border-box;">
            <div style="margin-bottom: 24px; border-left: 6px solid #3274d9; padding-left: 16px;">
                <h1 style="margin: 0; color: #111827; font-size: 26px; font-weight: 800; letter-spacing: -0.5px;">
                    Environment Resources
                </h1>
                <p style="margin: 4px 0 0 0; color: #4b5563; font-size: 14px; line-height: 1.5;">
                    Operator-configured external systems.
                </p>
            </div>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; width: 100%;">
                <a href="{{ .gitUrl }}" target="_blank" style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                    <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                        <img src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png" width="28" height="28" alt="GitHub">
                    </div>
                    <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">GitHub Source</div>
                    <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">Source code history.</div>
                </a>

                <a href="{{ .argocdHref }}" target="_blank" style="{{ .argocdTileStyle }}">
                    <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                        <img src="https://raw.githubusercontent.com/argoproj/argo-workflows/master/docs/assets/logo.png" width="28" height="28" alt="ArgoCD">
                    </div>
                    <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">ArgoCD</div>
                    <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">{{ .argocdDescription }}</div>
                </a>

                <a href="{{ .argoWfHref }}" target="_blank" style="{{ .argoWfTileStyle }}">
                    <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                        <img src="https://raw.githubusercontent.com/argoproj/argo-workflows/master/docs/assets/logo.png" width="28" height="28" alt="Argo Workflows">
                    </div>
                    <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Argo Workflows</div>
                    <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">{{ .argoWfDescription }}</div>
                </a>
            </div>
        </div>

        <div style="width: 49%; flex: 1 1 40%; min-width: 500px; box-sizing: border-box;">
            <div style="margin-bottom: 24px; border-left: 6px solid #22c55e; padding-left: 16px;">
                <h1 style="margin: 0; color: #111827; font-size: 26px; font-weight: 800; letter-spacing: -0.5px;">
                    Monitoring & Status
                </h1>
                <p style="margin: 4px 0 0 0; color: #4b5563; font-size: 14px; line-height: 1.5;">
                    Real-time observability and infrastructure health.
                </p>
            </div>

            <div style="display: flex; gap: 12px; width: 100%;">

                <div style="width: 49%; flex: 1 1 49%; display: flex; flex-direction: column; gap: 12px;">

                    <a href="/alerting/list" style="background-color: #fef2f2; border: 2px solid #dc2626; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                            <span style="font-size: 24px;">🔔</span>
                        </div>
                        <div style="color: #991b1b; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Alerts</div>
                        <div style="color: #b91c1c; font-size: 12px; line-height: 1.3;">Active firing & rules.</div>
                    </a>

                    <a href="/d/kubernetes-workloads/kubernetes-workloads" style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                            <span style="font-size: 24px;">📦</span>
                        </div>
                        <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Workloads</div>
                        <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">Usage & pods.</div>
                    </a>

                    <a href="/d/backups/backups" style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                            <span style="font-size: 24px;">💾</span>
                        </div>
                        <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Backups</div>
                        <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">Data recovery.</div>
                    </a>

                </div>

                <div style="width: 49%; flex: 1 1 49%; display: flex; flex-direction: column; gap: 12px;">

                    <a href="/d/databases/databases" style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                            <span style="font-size: 24px;">🛢️</span>
                        </div>
                        <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Databases</div>
                        <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">DB health.</div>
                    </a>

                    <a href="/d/load-balancers/load-balancers" style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                            <span style="font-size: 24px;">⚖️</span>
                        </div>
                        <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Load Balancers</div>
                        <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">Traffic status.</div>
                    </a>

                    <a href="/d/custom-domains/custom-domains" style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 10px; padding: 16px; text-decoration: none; display: flex; flex-direction: column; height: 100%; box-sizing: border-box;">
                        <div style="margin-bottom: 8px; height: 28px; display: flex; align-items: center;">
                            <span style="font-size: 24px;">🌐</span>
                        </div>
                        <div style="color: #111827; font-weight: 800; font-size: 16px; margin-bottom: 2px;">Custom Domains</div>
                        <div style="color: #6b7280; font-size: 12px; line-height: 1.3;">Hostname routes.</div>
                    </a>

                </div>

            </div>
        </div>
    </div>

    <div style="margin-top: 32px; padding-top: 16px; border-top: 1px solid #f3f4f6; display: flex; justify-content: space-between; align-items: center; position: relative; z-index: 1; flex-wrap: wrap; gap: 16px; width: 100%;">
        <div style="color: #9ca3af; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">
            <span style="background: #e5e7eb; color: #4b5563; padding: 2px 6px; border-radius: 4px; margin-right: 6px;">v${liferay_chart_version}</span>
            © 2026 Liferay Inc.
        </div>
        <div style="display: flex; gap: 16px;">
            <a href="https://learn.liferay.com/w/dxp/self-hosted-installation-and-upgrades/setting-up-liferay/activating-liferay-dxp#docker-and-cloud-native-deployments" style="color: #3274d9; font-size: 11px; font-weight: 700; text-decoration: none;">Support</a>
            <a href="https://liferay.atlassian.net/servicedesk/customer/portals" style="color: #3274d9; font-size: 11px; font-weight: 700; text-decoration: none;">Docs</a>
        </div>
    </div>

</div>
{{- end -}}
