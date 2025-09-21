# iz_toolbox_linux

---
## 简介

本仓库旨在收集和整理日常工作中常用到的 Linux Shell 脚本，以提高工作效率。

本仓库中的所有脚本都支持 `--help` 参数。您可以通过运行 `your_script_name.sh --help` 来查看每个脚本的具体用法和选项。

---
## 目录

- `iz_file_collector.sh` - **通用文件归集器**

	- 这是一个通用的 Shell 脚本，用于递归查找指定文件，并根据其原始路径重命名后，将其归集到单一目录中。

---
## 使用方法

您可以根据不同的场景选择以下任意一种方式来运行本仓库中的脚本。

### 方法一：使用 `sh` 命令直接执行

这是最简单直接的方法，无需为脚本添加执行权限。

```
sh /path/to/script/your_script_name.sh
```
    

### 方法二：添加执行权限后运行

您可以给脚本文件添加可执行权限，然后像运行普通程序一样执行它。

1. **为脚本添加执行权限** (此操作仅需执行一次):
    
    ```
    chmod +x /path/to/script/your_script_name.sh
    ```
    
2. **运行脚本**:
    
    ```
    # 如果您当前就在脚本所在的目录
    ./your_script_name.sh
    
    # 如果您在其他目录
    /path/to/script/your_script_name.sh
    ```
    
    > **注意**: 在当前目录执行时，前面的 `./` 是必需的，它告诉系统在当前目录下查找该可执行文件。
    

### 方法三：将脚本目录添加至环境变量

将脚本所在的目录添加到系统的 `PATH` 环境变量中，您就可以在任何路径下直接通过脚本名来调用它，就像使用 `ls`, `cd` 等系统命令一样方便。

#### 1. 临时添加 (仅对当前终端会话有效)

执行以下命令，将你的脚本目录添加到 `PATH` 环境变量的最前面。关闭当前终端后，此设置将失效。

```
# 将 /path/to/iz_toolbox_linux 替换为你的实际仓库路径
export PATH="/path/to/iz_toolbox_linux:$PATH"

# 设置完成后，就可以在任何地方直接运行脚本了
your_script_name.sh

```

#### 2. 永久添加 (推荐)

为了让设置永久生效，您需要将 `export` 命令写入您终端的配置文件中。这里提供两种方法：

**选项一：手动编辑配置文件**

1. **打开配置文件** (根据您使用的 Shell 选择对应的文件):
    
    - 如果您使用 Bash (大多数 Linux 发行版的默认 Shell)，编辑 `~/.bashrc`:
        
        ```
        vim ~/.bashrc
        ```
        
    - 如果您使用 Zsh (例如 macOS Catalina 及之后版本或使用了 oh-my-zsh)，编辑 `~/.zshrc`:
        
        ```
        vim ~/.zshrc
        ```
        
2. **在文件末尾添加以下行**:
    
    ```
    # 将 /path/to/iz_toolbox_linux 替换为你的实际仓库路径
    export PATH="/path/to/iz_toolbox_linux:$PATH"
    ```
    
3. **保存文件并使其立即生效**:
    
    - 如果您修改的是 `~/.bashrc`:
        
        ```
        source ~/.bashrc
        ```
        
    - 如果您修改的是 `~/.zshrc`:
        
        ```
        source ~/.zshrc
        ```
        

**选项二：使用命令一步完成**

如果您更喜欢简洁高效的方式，可以使用以下单行命令来完成。请记得将 `/path/to/iz_toolbox_linux` 替换为您的实际仓库路径。

- **对于 Bash 用户:**
    
    ```
    echo 'export PATH="/path/to/iz_toolbox_linux:$PATH"' >> ~/.bashrc && source ~/.bashrc
    ```
    
- **对于 Zsh 用户:**
    
    ```
    echo 'export PATH="/path/to/iz_toolbox_linux:$PATH"' >> ~/.zshrc && source ~/.zshrc
    ```
    

> **提示**: 这条命令会自动将路径配置追加到文件末尾，并立即刷新当前终端环境，让配置生效。

设置完成后，每次打开新的终端窗口，这个配置都会自动加载。您可以随时随地直接通过脚本名运行工具箱里的任何脚本。


## 许可证

MIT