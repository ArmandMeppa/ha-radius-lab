{{- define "freeradius.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "freeradius.fullname" -}}
{{- printf "%s" (include "freeradius.name" .) -}}
{{- end -}}
