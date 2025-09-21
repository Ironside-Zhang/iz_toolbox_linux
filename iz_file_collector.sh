#!/bin/bash

# --- 默认值定义 ---
SOURCE_DIR="." # 默认为当前目录
DEFAULT_OUTPUT_DIR="collected_files_$(date +%Y%m%d_%H%M%S)" # 默认输出目录
TARGET_DIR=""    # 如果用户未指定，则使用上面的默认值
TARGET_FILE=""   # 必须由用户指定
EXTENSION=""     # 默认为空

# --- 帮助信息函数 ---
show_help() {
    echo "用法: $0 -f <文件名> [选项...]"
    echo ""
    echo "一个通用的文件查找和复制脚本，可根据文件所在目录结构重命名。"
    echo ""
    echo "选项:"
    echo "  -f <文件名>    (必需) 指定要搜索的文件名，例如 'SConscript'。"
    echo "  -s <源目录>    (可选) 指定从哪个目录开始搜索。默认为当前目录。"
    echo "  -o <目标目录>  (可选) 指定输出结果的目标目录。默认为 './collected_files_YYYYMMDD_HHMMSS'。"
    echo "  -e <扩展名>    (可选) 为复制后的文件添加指定的扩展名，例如 'txt' 或 '.txt'。默认不添加扩展名。"
    echo "  --help         显示此帮助信息并退出。"
    echo ""
    echo "示例:"
    echo "  # 在当前目录查找所有 'SConscript' 并复制到 './output' 文件夹，新文件添加 '.txt' 扩展名"
    echo "  $0 -f SConscript -o ./output -e .txt"
    echo ""
    echo "  # 从 '../projects' 目录查找 'Makefile' 并复制到默认目录，不加扩展名"
    echo "  $0 -f Makefile -s ../projects"
}

# --- 参数解析 ---
# 单独处理 --help 长选项
if [[ " $* " == *" --help "* ]]; then
    show_help
    exit 0
fi

# 使用 getopts 解析短选项
while getopts "f:s:o:e:h" opt; do
    case ${opt} in
        f) TARGET_FILE=$OPTARG ;;
        s) SOURCE_DIR=$OPTARG ;;
        o) TARGET_DIR=$OPTARG ;;
        e)
            # 如果用户忘记加点，自动补上
            if [[ "$OPTARG" != .* && ! -z "$OPTARG" ]]; then
                EXTENSION=".$OPTARG"
            else
                EXTENSION=$OPTARG
            fi
            ;;
        h) # 兼容 -h 选项
            show_help
            exit 0
            ;;
        \?)
            echo "无效的选项: -$OPTARG" >&2
            show_help
            exit 1
            ;;
        :)
            echo "选项 -$OPTARG 需要一个参数。" >&2
            show_help
            exit 1
            ;;
    esac
done

# --- 参数校验 ---
# 检查必需的 -f 参数是否已提供
if [ -z "$TARGET_FILE" ]; then
    echo "错误: 必须使用 -f 指定要查找的文件名。" >&2
    show_help
    exit 1
fi

# 如果用户未指定目标目录，则使用默认值
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$DEFAULT_OUTPUT_DIR"
fi

# --- 脚本主逻辑 ---
set -eou pipefail

# 获取源和目标目录的绝对路径，更稳健
SOURCE_DIR_ABS=$(realpath "$SOURCE_DIR")
TARGET_DIR_ABS=$(realpath "$TARGET_DIR")

if [ ! -d "$SOURCE_DIR_ABS" ]; then
    echo "错误: 源目录 '$SOURCE_DIR_ABS' 不存在或不是一个有效的目录。" >&2
    exit 1
fi

echo "确保目标目录 '$TARGET_DIR_ABS' 存在..."
mkdir -p "$TARGET_DIR_ABS"

BASE_NAME=$(basename "$SOURCE_DIR_ABS")

echo "源目录: $SOURCE_DIR_ABS"
echo "目标目录: $TARGET_DIR_ABS"
echo "查找文件: $TARGET_FILE"
echo "-------------------------------------"

(
    cd "$SOURCE_DIR_ABS"

    echo "开始查找并复制文件..."
    find . -type f -name "$TARGET_FILE" -print0 | while IFS= read -r -d '' filepath; do
        rel_dir=$(dirname "$filepath")

        name_part="" # 初始化变量是一个好习惯
        if [ "$rel_dir" == "." ]; then
            name_part="$BASE_NAME"
        else
            sub_path=$(echo "$rel_dir" | sed "s|^\./||")
            name_part="$BASE_NAME-$(echo "$sub_path" | tr '/' '-')"
         fi

        # 基于原始文件名构建新的文件名
        dest_filename="${TARGET_FILE}-${name_part}${EXTENSION}"
        dest_filepath="${TARGET_DIR_ABS}/${dest_filename}"

        cp "$filepath" "$dest_filepath"
        echo "已复制: $filepath  ->  ${dest_filename}"
    done
)

echo "-------------------------------------"
echo "操作完成！"