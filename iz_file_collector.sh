#!/bin/bash

# --- 默认值定义 ---
SOURCE_DIR="." # 默认为当前目录
DEFAULT_OUTPUT_DIR="collected_files_$(date +%Y%m%d_%H%M%S)" # 默认输出目录
TARGET_DIR=""    # 如果用户未指定，则使用上面的默认值
TARGET_FILE=""   # 必须由用户指定
EXTENSION=""     # 可选，用于在文件名后追加扩展名

# --- 帮助信息函数 ---
show_help() {
    echo "用法: $0 -f <文件名或模式> [选项...]"
    echo ""
    echo "一个通用的文件查找和复制脚本，可根据文件所在目录结构重命名。"
    echo ""
    echo "选项:"
    echo "  -f <文件名>    (必需) 指定要搜索的文件名或模式，例如 'main.c' 或 '*.c'。"
    echo "  -s <源目录>    (可选) 指定从哪个目录开始搜索。默认为当前目录。"
    echo "  -o <目标目录>  (可选) 指定输出结果的目标目录。默认为 './collected_files_YYYYMMDD_HHMMSS'。"
    echo "  -e <扩展名>    (可选) 为复制后的文件添加一个额外的扩展名。如果未提供，则只保留原始扩展名。"
    echo "  --help         显示此帮助信息并退出。"
    echo ""
    echo "示例:"
    echo "  # 查找所有 'main.c'，生成 '.../main-k230-apps.c'"
    echo "  $0 -f main.c -o ./output"
    echo ""
    echo "  # 查找所有 'main.c'，并添加 '.txt' 后缀，生成 '.../main-k230-apps.c.txt'"
    echo "  $0 -f main.c -o ./output -e txt"
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
    # 注意 find 的 TARGET_FILE 参数需要用引号包裹，以支持通配符
    find . -type f -name "$TARGET_FILE" -print0 | while IFS= read -r -d '' filepath; do
        rel_dir=$(dirname "$filepath")

        # 智能提取文件名和原始扩展名
        original_filename=$(basename "$filepath")
        original_basename="${original_filename%.*}"
        
        original_extension=""
        # 检查文件是否包含扩展名
        if [[ "$original_filename" == *.* ]]; then
            original_extension=".${original_filename##*.}"
        fi
        
        # === 核心改动：将 -e 提供的扩展名追加到原始扩展名后面 ===
        final_extension="${original_extension}${EXTENSION}"
        # =======================================================

        name_part=""
        if [ "$rel_dir" == "." ]; then
            name_part="$BASE_NAME"
        else
            sub_path=$(echo "$rel_dir" | sed "s|^\./||")
            name_part="$BASE_NAME-$(echo "$sub_path" | tr '/' '-')"
        fi

        # 使用新的命名规则构建文件名
        dest_filename="${original_basename}-${name_part}${final_extension}"
        dest_filepath="${TARGET_DIR_ABS}/${dest_filename}"

        cp "$filepath" "$dest_filepath"
        echo "已复制: $filepath  ->  ${dest_filename}"
    done
)

echo "-------------------------------------"
echo "操作完成！"

