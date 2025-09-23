#!/bin/bash

#================================================================
# 脚本名称: dir-search-tool.sh (高级目录检索工具)
# 脚本功能: 一个通用的目录查找工具。可以根据目录/文件名/文件内容等多种条件
#           进行筛选，并将结果输出到指定文件中。
# 版本:     v4.1 (Bugfix Release)
#================================================================

# --- 帮助信息函数 ---
show_help() {
cat << EOF
用法: ${0##*/} [-s <源目录>] [-o <输出文件>] [-t <目标文件名>] [-c <内容>] [-h|--help]

一个通用的、支持内容筛选的目录查找脚本。

选项:
  -s <源目录>       指定要搜索的起始目录。
                     默认值: 当前目录 (".").

  -o <输出文件>     指定用于保存结果列表的文件。
                     默认值: "list_YYYYMMDD_RANDOM.txt" (例如: list_20250923_12345.txt).

  -t <目标文件名>   指定一个必须存在于目录中的文件名。只有包含此文件的目录才会被列出。
                     默认值: 无 (列出所有子目录).

  -c <内容>         (需与-t配合使用) 指定目标文件中必须包含的文本内容(字符串或正则表达式)。
                     默认值: 无 (不对文件内容进行筛选).

  -h, --help        显示此帮助信息并退出。
EOF
}

# --- 初始化默认值 ---
SOURCE_DIR="."
OUTPUT_FILE=""
TARGET_FILE=""
CONTENT_PATTERN=""

# --- 解析命令行参数 ---
for arg in "$@"; do
  if [ "$arg" == "--help" ]; then
    show_help
    exit 0
  fi
done

while getopts "s:o:t:c:h" opt; do
  case $opt in
    s) SOURCE_DIR="$OPTARG" ;;
    o) OUTPUT_FILE="$OPTARG" ;;
    t) TARGET_FILE="$OPTARG" ;;
    c) CONTENT_PATTERN="$OPTARG" ;;
    h) show_help; exit 0 ;;
    \?) echo "无效的选项: -$OPTARG" >&2; show_help; exit 1 ;;
    :) echo "选项 -$OPTARG 需要一个参数。" >&2; show_help; exit 1 ;;
  esac
done

# --- 参数处理与安全检查 ---
if [ -n "$CONTENT_PATTERN" ] && [ -z "$TARGET_FILE" ]; then
    echo "错误: -c (内容筛选) 选项必须与 -t (目标文件) 选项一同使用。" >&2
    show_help
    exit 1
fi

if [ -z "$OUTPUT_FILE" ]; then
    DATE_STAMP=$(date +'%Y%m%d')
    RANDOM_NUM=$RANDOM
    OUTPUT_FILE="list_${DATE_STAMP}_${RANDOM_NUM}.txt"
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录 '${SOURCE_DIR}' 不存在或不是一个有效的目录。" >&2
    exit 1
fi

if ! > "$OUTPUT_FILE"; then
    echo "错误: 没有权限写入文件 '${OUTPUT_FILE}'。" >&2
    exit 1
fi

# --- 主逻辑 ---
echo "--- 开始执行查找任务 ---"
echo "源 目 录: ${SOURCE_DIR}"
echo "输 出 文 件: ${OUTPUT_FILE}"

if [ -n "$TARGET_FILE" ] && [ -n "$CONTENT_PATTERN" ]; then
    echo "文件筛选: 目录必须包含 \"${TARGET_FILE}\""
    echo "内容筛选: 文件需包含 \"${CONTENT_PATTERN}\""
    echo "正在搜索..."
    # 修正(CORRECTED): 移除了错误的 sed 命令 's|^${SOURCE_DIR}||'
    find "${SOURCE_DIR}" -type f -name "${TARGET_FILE}" -exec grep -q "${CONTENT_PATTERN}" {} \; -printf "%h\n" | sed "s|^${SOURCE_DIR}/||" > "${OUTPUT_FILE}"

elif [ -n "$TARGET_FILE" ]; then
    echo "文件筛选: 目录必须包含文件 \"${TARGET_FILE}\""
    echo "正在搜索..."
    # 修正(CORRECTED): 移除了错误的 sed 命令 's|^${SOURCE_DIR}||'
    find "${SOURCE_DIR}" -type f -name "${TARGET_FILE}" -printf "%h\n" | sed "s|^${SOURCE_DIR}/||" > "${OUTPUT_FILE}"

else
    echo "筛选条件: 无 (列出所有子目录)"
    echo "正在搜索..."
    # 修正(CORRECTED): 移除了错误的 sed 命令 's|^${SOURCE_DIR}||'
    find "${SOURCE_DIR}" -mindepth 1 -type d | sed "s|^${SOURCE_DIR}/||" > "${OUTPUT_FILE}"
fi

if [ $? -ne 0 ]; then
    echo "错误: find 命令执行失败。" >&2
    exit 1
fi

RESULT_COUNT=$(wc -l < "${OUTPUT_FILE}")
echo "--------------------------------------------------"
echo "任务完成，共找到 $(echo $RESULT_COUNT | xargs) 个结果，已保存至 '${OUTPUT_FILE}'。"
echo "--------------------------------------------------"

exit 0