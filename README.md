# RemNote Beta NixOS 包

这是一个用于在 NixOS 上打包和使用 RemNote Beta 版的 Nix flake。

## 特性

- 打包并安装 RemNote Beta 版
- 保持版本的可复现性
- 支持 unfree 软件许可

## 使用方法

### 安装 RemNote Beta

临时安装（不将包添加到系统配置中）：

```bash
# 允许非自由软件
NIXPKGS_ALLOW_UNFREE=1 nix run github:bianyeyu/nix-remnote-beta --impure
```

或者直接从本地仓库安装：

```bash
NIXPKGS_ALLOW_UNFREE=1 nix run .#remnote-beta --impure
```

### 将 RemNote Beta 添加到系统配置

在你的 NixOS 系统配置中添加：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # 添加 RemNote Beta flake
    remnote-beta.url = "github:bianyeyu/nix-remnote-beta";
  };

  outputs = { self, nixpkgs, remnote-beta, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 其他系统配置...
        ./configuration.nix
        
        # 添加 RemNote Beta
        ({ pkgs, ... }: {
          # 允许非自由软件
          nixpkgs.config.allowUnfree = true;
          
          # 安装 RemNote Beta
          environment.systemPackages = [ remnote-beta.packages.x86_64-linux.remnote-beta ];
        })
      ];
    };
  };
}
```

## 手动更新 RemNote Beta

当 RemNote 发布新的 Beta 版本时（例如 `1.20.0`），你可以按照以下更直接的步骤来更新软件包：

1.  **获取新版本的哈希值**:
    打开终端，使用 `nix-prefetch-url` 命令来直接下载新版本的 AppImage 并计算其哈希。请将命令中的版本号替换为实际的新版本号：
    ```bash
    nix-prefetch-url "https://download2.remnote.io/remnote-desktop2/RemNote-1.20.0-beta.AppImage"
    ```
    这个命令会输出一个 `sha256-...` 格式的哈希值。复制它。

2.  **一次性更新 `flake.nix`**:
    打开 `flake.nix` 文件，然后：
    *   将 `version` 变量更新为新的版本号。
    *   将 `hash` 的值替换为你刚刚从上一步复制过来的新哈希。

    修改后应如下所示：
    ```nix
    let
      version = "1.20.0"; // <-- 新版本号
    in
    ...
      src = final.fetchurl {
        url = "https://download2.remnote.io/remnote-desktop2/RemNote-${version}-beta.AppImage";
        hash = "sha256-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; // <-- 粘贴新的哈希值
      };
    ...
    ```

3.  **验证和推送**:
    *   运行构建命令来验证你的修改是否正确：
        ```bash
        NIXPKGS_ALLOW_UNFREE=1 nix build .#default --impure
        ```
    *   如果构建成功，提交你的更改并推送到 GitHub：
        ```bash
        git add flake.nix flake.lock
        git commit -m "remnote-beta: update to version 1.20.0"
        git push
        ```

## 注意事项

- 由于 RemNote 是非自由软件，必须通过 `--impure` 和 `NIXPKGS_ALLOW_UNFREE=1` 或在系统配置中设置 `nixpkgs.config.allowUnfree = true` 来使用它。 