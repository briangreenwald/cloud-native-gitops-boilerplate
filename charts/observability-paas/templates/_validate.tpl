{{/*
observability-paas is GCP-only today. Fail loudly during template rendering
if someone tries to point it at another cloud, so the failure mode is
"helm install errors with a clear message" rather than "helm install
succeeds and the syncer pod CrashLoops in the cluster."

The include call lives in templates/validate.yaml so that Helm actually
evaluates it (code outside a define in a _*.tpl file is never executed).
*/}}
{{- define "observability-paas.validate" -}}
{{- $cloud := index .Values "observability" "cloudProvider" -}}
{{- if ne $cloud "gcp" -}}
{{- fail (printf "observability-paas only supports cloudProvider=gcp today; got %q. AWS PaaS support is not yet implemented." $cloud) -}}
{{- end -}}
{{- end -}}
