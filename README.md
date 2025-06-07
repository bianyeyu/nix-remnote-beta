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

## 手动更新 RemNote Beta (已自动化)

本仓库配置了一个 GitHub Action，可以自动更新软件包的哈希值。

**你的更新流程极其简单：**

1.  在 GitHub 上，直接编辑 `flake.nix` 文件。
2.  只修改 `let` 块中的 `version` 变量为你想要的新版本号。
3.  直接提交你的更改。

**然后会发生什么？**

*   你的提交会自动触发一个 GitHub Action 工作流。
*   这个工作流会自动使用 `nix-prefetch-url` 获取新版本文件对应的正确哈希。
*   机器人会自动用新的哈希值更新 `flake.nix` 文件，并创建一个新的提交推送到仓库。

你只需要修改版本号，剩下的全部由机器人完成。

## 注意事项

- 由于 RemNote 是非自由软件，必须通过 `--impure` 和 `NIXPKGS_ALLOW_UNFREE=1` 或在系统配置中设置 `nixpkgs.config.allowUnfree = true` 来使用它。 