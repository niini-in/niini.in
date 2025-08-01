{{/*
Expand the name of the chart.
*/}}
{{- define "minishop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "minishop.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "minishop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "minishop.labels" -}}
helm.sh/chart: {{ include "minishop.chart" . }}
{{ include "minishop.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "minishop.selectorLabels" -}}
app.kubernetes.io/name: {{ include "minishop.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "minishop.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "minishop.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Service template helper
*/}}
{{- define "minishop.serviceName" -}}
{{- printf "%s-%s" (include "minishop.fullname" .) .serviceName | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Service labels helper
*/}}
{{- define "minishop.serviceLabels" -}}
{{- $serviceName := .serviceName }}
{{- $context := .context }}
{{- $chartName := include "minishop.chart" $context }}
helm.sh/chart: {{ $chartName }}
app.kubernetes.io/name: {{ $serviceName }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
app.kubernetes.io/component: {{ $serviceName }}
{{- end }}

{{/*
Service selector helper
*/}}
{{- define "minishop.serviceSelector" -}}
{{- $serviceName := .serviceName }}
{{- $context := .context }}
app.kubernetes.io/name: {{ $serviceName }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
{{- end }}