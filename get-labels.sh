#!/bin/bash
# 输出文件名
output_file="k8s_node_labels_extracted.txt"
# 检查 kubectl 和 jq 是否存在
if ! command -v kubectl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: kubectl or jq is not installed. Please install them and try again."
    exit 1
fi
# 清空或创建输出文件
echo > "$output_file"
# 获取所有节点的标签并提取需要的字段
if ! kubectl get nodes -o json | jq -r '.items[] | 
    {name: .metadata.name, 
     region: .metadata.labels["region"], 
     zone: .metadata.labels["zone"], 
     rack: .metadata.labels["rack"], 
     hostname: .metadata.labels["hostname"]} | 
    select(.hostname != null or .zone != null or .rack != null or .region != null) |"\(.name)  region=\(.region)  zone=\(.zone)  rack=\(.rack)  hostname=\(.hostname)"' >> "$output_file"; then
    echo "Error: Failed to retrieve nodes or process data." >&2
fi
# 去掉空行
sed -i '/^$/d' "$output_file"
# 添加文件结束标记
echo "Output saved to $output_file"
