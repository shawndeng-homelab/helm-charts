{{/*
扩展 chart 的名称。
模板函数 "hello-word.name" 返回 chart 的名称，支持通过 .Values.nameOverride 覆盖默认值。
- .Chart.Name: 当前 chart 的名称，来源于 Chart.yaml 文件中的 name 字段。
- .Values.nameOverride: 用户可以在 values.yaml 文件中定义，用于覆盖默认的 chart 名称。
*/}}
{{- define "hello-word.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
创建一个默认的全限定应用名称。
模板函数 "hello-word.fullname" 返回一个全限定名称，优先使用 .Values.fullnameOverride，或者根据 release 名称和 chart 名称生成。
名称长度限制为 63 个字符。
- .Values.fullnameOverride: 用户可以在 values.yaml 文件中定义，用于覆盖默认的全限定名称。
- .Release.Name: 当前 Helm release 的名称，由用户在安装 chart 时指定。
- .Chart.Name: 当前 chart 的名称，来源于 Chart.yaml 文件中的 name 字段。
- .Values.nameOverride: 用户可以在 values.yaml 文件中定义，用于覆盖默认的 chart 名称。
*/}}
{{- define "hello-word.fullname" -}}
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
创建 chart 的名称和版本，用于 chart 标签。
模板函数 "hello-word.chart" 返回 chart 的名称和版本，版本中的 "+" 会被替换为 "_"。
- .Chart.Name: 当前 chart 的名称，来源于 Chart.yaml 文件中的 name 字段。
- .Chart.Version: 当前 chart 的版本，来源于 Chart.yaml 文件中的 version 字段。
*/}}
{{- define "hello-word.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
通用标签。
模板函数 "hello-word.labels" 返回一组通用的 Kubernetes 标签，包括 chart 名称、版本、管理服务等信息。
- .Chart.AppVersion: 应用的版本，来源于 Chart.yaml 文件中的 appVersion 字段。
- .Release.Service: 当前 Helm release 的管理服务，通常为 "Helm"。
*/}}
{{- define "hello-word.labels" -}}
helm.sh/chart: {{ include "hello-word.chart" . }}
{{ include "hello-word.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
选择器标签。
模板函数 "hello-word.selectorLabels" 返回一组选择器标签，用于标识应用实例和名称。
- .Release.Name: 当前 Helm release 的名称，由用户在安装 chart 时指定。
- .Chart.Name: 当前 chart 的名称，来源于 Chart.yaml 文件中的 name 字段。
*/}}
{{- define "hello-word.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hello-word.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
创建要使用的 ServiceAccount 名称。
模板函数 "hello-word.serviceAccountName" 返回 ServiceAccount 的名称，支持通过 .Values.serviceAccount.name 覆盖默认值。
如果 .Values.serviceAccount.create 为 true，则默认使用全限定名称。
- .Values.serviceAccount.create: 用户可以在 values.yaml 文件中定义，指示是否创建 ServiceAccount。
- .Values.serviceAccount.name: 用户可以在 values.yaml 文件中定义，用于覆盖默认的 ServiceAccount 名称。
- .Release.Name: 当前 Helm release 的名称，由用户在安装 chart 时指定。
- .Chart.Name: 当前 chart 的名称，来源于 Chart.yaml 文件中的 name 字段。
*/}}
{{- define "hello-word.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hello-word.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
