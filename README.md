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
NIXPKGS_ALLOW_UNFREE=1 nix run github:username/nix-remnote-beta --impure
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
    remnote-beta.url = "github:username/nix-remnote-beta";
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

当 RemNote 发布新的 Beta 版本时，可以按照以下步骤手动更新：

1. 在 `flake.nix` 中更新版本号和下载链接：
   ```nix
   version = "1.19.XX"; # 替换为新版本号
   url = "https://download2.remnote.io/remnote-desktop2/RemNote-1.19.XX-beta.AppImage"; # 更新链接
   ```

2. 更新占位符哈希值：
   ```nix
   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
   ```

3. 尝试构建以获取正确的哈希值：
   ```bash
   NIXPKGS_ALLOW_UNFREE=1 nix build .#remnote-beta --impure
   ```

4. 更新哈希值并再次构建：
   ```bash
   # 用错误信息中提供的正确哈希值更新 flake.nix
   NIXPKGS_ALLOW_UNFREE=1 nix build .#remnote-beta --impure
   ```

## 注意事项

- 由于 RemNote 是非自由软件，必须通过 `--impure` 和 `NIXPKGS_ALLOW_UNFREE=1` 或在系统配置中设置 `nixpkgs.config.allowUnfree = true` 来使用它。 