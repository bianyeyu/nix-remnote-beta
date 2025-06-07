{
  description = "A flake for packaging RemNote Beta";

  # 1. 输入 (Inputs)
  # 我们声明这个 flake 依赖于 nixpkgs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # 2. 输出 (Outputs)
  # 这是 flake 产生的内容，比如软件包、覆盖层等
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      # 为 linux 系统创建一个 nixpkgs 实例，并应用我们的 overlay
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      # 3. 定义 Overlay
      # 这是我们修改 nixpkgs 的地方
      overlays.default = final: prev: {
        # 我们要添加/修改的包名叫 remnote-beta
        # 使用 appimageTools.wrapType2 是打包 AppImage 的标准、可靠方法
        remnote-beta =
          let
            version = "1.19.43";
          in
          final.appimageTools.wrapType2 {
            pname = "remnote-beta";
            inherit version;

            src = final.fetchurl {
              url = "https://download2.remnote.io/remnote-desktop2/RemNote-${version}-beta.AppImage";
              hash = "sha256-l0nChFOahZfAh+QqP8mdfqV5sAInGCtJUl55vza5HOc=";
            };

            meta = with final.lib; {
              description = "The all-in-one tool for thinking and learning (Beta Version)";
              homepage = "https://www.remnote.com/";
              maintainers = with maintainers; [ nova ]; # <-- 你的名字
              platforms = platforms.linux;
              license = licenses.unfree; # RemNote 不是开源软件
            };
          };
      };

      # 4. 将包暴露给不同的系统
      # 这样我们就可以通过 `nix build .#remnote-beta` 或 `nix build` 来使用它
      packages.${system} = {
        default = pkgs.remnote-beta;
        remnote-beta = pkgs.remnote-beta;
      };
    };
}
