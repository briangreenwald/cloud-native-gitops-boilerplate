{{/*
Pod spec shared by the datasource-syncer CronJob and its post-install/upgrade
bootstrap Job (Helm hook). Renders the init container that runs the bash
bootstrap (creates / rotates the Grafana SA token), followed by the main
container that runs the GCP datasource-syncer binary against Grafana with
that token.
*/}}
{{- define "observability-paas.datasourceSyncer.podTemplate" -}}
{{- $name := include "observability-paas.datasourceSyncer.fullname" . -}}
{{- $sharedPath := "/shared" -}}
{{- $grafanaTokenFilePath := printf "%s/grafana_sa_token" $sharedPath -}}
{{- with .Values.jobs.gcpDatasourceSyncer }}
template:
    metadata:
        {{- if .podAnnotations }}
        annotations:
            {{- toYaml .podAnnotations | nindent 12 }}
        {{- end }}
        labels:
            {{- include "observability-paas.labels" $ | nindent 12 }}
            observability-paas-grafana-client: "true"
    spec:
        restartPolicy: {{ .restartPolicy | quote }}
        {{- if .initContainer }}
        initContainers:
            -   command:
                    -   sh
                    -   -c
                    -   /scripts/datasource-syncer.sh
                env:
                    {{- include "observability-paas.grafana.credentialsEnv" $ | nindent 20 }}
                    -   name: GRAFANA_SA_NAME
                        value: {{ printf "%s-app" $name | quote }}
                    {{- range .initContainer.env }}
                    -   {{ toYaml . | nindent 24 | trim }}
                    {{- end }}
                    {{- if .serviceAccountTokenInFile }}
                    -   name: GRAFANA_SERVICE_ACCOUNT_TOKEN_IN_FILE
                        value: "true"
                    -   name: GRAFANA_SERVICE_ACCOUNT_TOKEN_IN_FILE_FILEPATH
                        value: {{ $grafanaTokenFilePath | quote }}
                    {{- else }}
                    -   name: GRAFANA_SERVICE_ACCOUNT_TOKEN_SECRET_NAME
                        value: {{ include "observability-paas.datasourceSyncer.tokenSecretName" $ | quote }}
                    -   name: GRAFANA_SERVICE_ACCOUNT_TOKEN_SECRET_KEY
                        value: GRAFANA_SERVICE_ACCOUNT_TOKEN
                    {{- end }}
                image: {{ printf "%s:%s" .initContainer.image.repository .initContainer.image.tag | quote }}
                imagePullPolicy: {{ .initContainer.image.pullPolicy | quote }}
                name: grafana-create-sa-and-token
                resources:
                    {{- toYaml .initContainer.resources | nindent 20 }}
                volumeMounts:
                    -   mountPath: /scripts
                        name: scripts
                    {{- if .serviceAccountTokenInFile }}
                    -   mountPath: {{ $sharedPath }}
                        name: shared-data
                    {{- end }}
        {{- end }}
        containers:
            -   args:
                    -   {{ printf "--datasource-uids=%s" (.args.datasourceUids | join ",") | quote }}
                    -   {{ printf "--grafana-api-endpoint=%s" (include "observability-paas.grafana.internalHost" $) | quote }}
                    -   {{ printf "--project-id=%s" .args.gcpProjectId | quote }}
                    {{- if .serviceAccountTokenInFile }}
                    -   {{ printf "--grafana-api-token-filepath=%s" $grafanaTokenFilePath | quote }}
                    {{- end }}
                {{- if .extraEnv }}
                env:
                    {{- toYaml .extraEnv | nindent 20 }}
                {{- end }}
                {{- if not .serviceAccountTokenInFile }}
                envFrom:
                    -   secretRef:
                            name: {{ include "observability-paas.datasourceSyncer.tokenSecretName" $ | quote }}
                {{- end }}
                image: {{ printf "%s:%s" .image.repository .image.tag | quote }}
                imagePullPolicy: {{ .image.pullPolicy | quote }}
                name: {{ $name | quote }}
                resources:
                    {{- toYaml .resources | nindent 20 }}
                {{- if .serviceAccountTokenInFile }}
                volumeMounts:
                    -   mountPath: {{ $sharedPath }}
                        name: shared-data
                {{- end }}
        volumes:
            -   configMap:
                    defaultMode: 0555
                    name: {{ printf "%s-script" $name | quote }}
                name: scripts
            {{- if .serviceAccountTokenInFile }}
            -   emptyDir: {}
                name: shared-data
            {{- end }}
{{- end }}
{{- end -}}
