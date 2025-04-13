# Helm Charts

| 语法                                   | 说明                              | 示例                                                                 |
|------------------------------------------|------------------------------------------|-------------------------------------------------------------------------|
| `helm repo add <repo-name> <repo-url>`   | 添加一个新的 Helm 仓库。          | `helm repo add stable https://charts.helm.sh/stable`                   |
| `helm repo update`                       | 更新已添加的 Helm 仓库信息。      | `helm repo update`                                                     |
| `helm repo list`                         | 列出已添加的 Helm 仓库。          | `helm repo list`                                                       |
| `helm repo remove <repo-name>`           | 删除已添加的 Helm 仓库。          | `helm repo remove stable`                                              |
| `helm search repo <keyword>`             | 在已添加的仓库中搜索 Chart。      | `helm search repo nginx`                                               |
| `helm install <release-name> <chart>`    | 使用指定的发布名称安装 Helm chart。 | `helm install myconfigmap .\hello-word`                                |
| `helm install <release-name> <repo/chart>` | 从官方仓库安装指定的 Chart。       | `helm install mynginx stable/nginx`                                    |
| `helm install <release-name> <chart-archive>` | 从本地压缩包安装 Chart。          | `helm install mychart ./mychart-0.1.0.tgz`                             |
| `helm install <release-name> <url>`      | 从网络地址安装 Chart。             | `helm install mychart https://example.com/charts/mychart-0.1.0.tgz`    |
| `helm install <release-name> <chart> --debug --dry-run` | 模拟安装并输出调试信息，不实际部署资源。 | `helm install myconfigmap3 .\hello-word --debug --dry-run`             |
| `helm upgrade <release-name> <chart>`    | 升级已安装的 Chart，更新 Kubernetes 中的资源。 | `helm upgrade myconfigmap .\hello-word`                                |
| `helm upgrade <release-name> <chart> -f <values-file>` | 使用指定的 `values.yaml` 文件升级 Chart。 | `helm upgrade nginx-service .\hello-word -f .\hello-word\values.yaml`  |
| `helm upgrade <release-name> ./chart-path --reset-values` | 升级 Chart 并重置为默认的 `values.yaml` 配置。 | `helm upgrade nginx-service ./hello-word --reset-values`               |
| `helm upgrade <release-name> ./chart-path --set <key>=<value>` | 升级 Chart 并动态设置指定的值。   | `helm upgrade nginx-service ./hello-word --set image.tag=v2.0.1`       |
| `helm upgrade <release-name> ./chart-path --reuse-values --set <key>=<value>` | 升级 Chart，保留现有的 `values.yaml` 配置并动态设置新值。 | `helm upgrade nginx-service ./hello-word --reuse-values --set image.tag=newversion` |
| `helm rollback <release-name> <revision>`| 回滚到指定的修订版本，恢复 Kubernetes 中的资源到之前的状态。 | `helm rollback myconfigmap 1`                                          |
| `helm get manifest <release-name>`       | 获取指定发布的 Kubernetes manifest。 | `helm get manifest myconfigmap`                                        |
| `helm uninstall <release-name>`          | 卸载指定的发布，删除 Kubernetes 中的相关资源。 | `helm uninstall myconfigmap`                                           |
| `helm create <chart-name>`               | 创建一个新的 Helm Chart 包。      | `helm create mychart`                                                  |
| `helm template <chart>`                  | 预渲染模板并输出结果到标准输出。  | `helm template mychart`                                                |
| `helm show chart <chart>`                | 显示 Chart 的元数据。             | `helm show chart stable/nginx`                                         |
| `helm show values <chart>`               | 显示 Chart 的默认 `values.yaml` 文件内容。 | `helm show values stable/nginx`                                        |
| `helm show readme <chart>`               | 显示 Chart 的 `README.md` 文件内容。 | `helm show readme stable/nginx`                                        |
| `helm pull <chart>`                      | 下载指定的 Chart 包到本地。       | `helm pull stable/nginx`                                               |
| `helm pull <chart> --untar`              | 下载并解压指定的 Chart 包到本地。 | `helm pull stable/nginx --untar`                                       |
| `helm pull <chart> --version <version>`  | 下载指定版本的 Chart 包到本地。   | `helm pull stable/nginx --version 1.2.3`                                |

## Helm 概念与字段说明

| 概念/字段          | 类型       | 说明                                                                 |
|---------------------|------------|----------------------------------------------------------------------|
| `.Release.Name`      | 字符串     | 当前发布的名称，由用户指定或 Helm 自动生成。                         |
| `.Release.Namespace` | 字符串     | 当前发布所在的 Kubernetes 命名空间。                                 |
| `.Release.IsInstall` | 布尔值     | 表示当前操作是否为安装操作。                                         |
| `.Release.IsUpgrade` | 布尔值     | 表示当前操作是否为升级操作。                                         |
| `.Release.Revision`  | 整数       | 当前发布的修订版本号，从 1 开始递增。                                |
| `.Release.Service`   | 字符串     | Helm 的服务名称，通常为 `Helm`。                                     |
| `.Values`            | 字典       | 用户提供的自定义值，通常通过 `values.yaml` 文件或命令行传递。         |
| `.Chart`             | 字典       | 当前 Chart 的元数据和模板信息，包括名称、版本等。                     |
| `.Capabilities`      | 字典       | 集群支持的功能信息，例如 Kubernetes API 版本等。                      |
| `.Capabilities.KubeVersion` | 字符串 | 集群的 Kubernetes 版本信息，例如 `v1.25.0`。                         |
| `.Capabilities.APIVersions` | 列表   | 集群支持的 API 版本列表，例如 `apps/v1`、`batch/v1` 等。              |
| `.Capabilities.HelmVersion` | 字符串 | 当前使用的 Helm 版本信息，例如 `v3.12.0`。                            |
| `.Template.Name`     | 字符串     | 当前模板的名称，例如 `templates/configmap.yaml`。                     |
| `.Template.BasePath` | 字符串     | 当前模板的基础路径，例如 `charts/hello-world/templates`。             |
| `.Template.Engine`   | 字符串     | 模板引擎的名称，通常为 `gotpl`（Go 模板）。                           |

## Kubernetes 常用命令

| 命令                                   | 说明                              | 示例                                                                 |
|------------------------------------------|------------------------------------------|-------------------------------------------------------------------------|
| `kubectl create deployment <name> --image=<image> --dry-run=client -o yaml` | 创建一个 Deployment 并以 YAML 格式输出（不实际应用）。 | `kubectl create deployment nginx --image=nginx --dry-run=client -o yaml` |
| `kubectl create service clusterip <name> --tcp=<port>:<targetPort> --dry-run=client -o yaml` | 创建一个 ClusterIP 类型的 Service 并以 YAML 格式输出（不实际应用）。 | `kubectl create service clusterip my-svc --tcp=80:80 --dry-run=client -o yaml` |
| `kubectl explain <resource>.<field>`     | 查看指定资源及字段的详细说明。    | `kubectl explain service.spec.type`                                    |
