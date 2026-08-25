{
  description = "Remember The Milk desktop application for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      overlays.default = final: _prev: {
        remember-the-milk = final.callPackage ./remember-the-milk.nix { };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ self.overlays.default ];
          };
        in
        {
          inherit (pkgs) remember-the-milk;
          default = pkgs.remember-the-milk;
        }
      );

      apps = forAllSystems (
        system:
        let
          package = self.packages.${system}.remember-the-milk;
          app = {
            type = "app";
            program = nixpkgs.lib.getExe package;
            meta = package.meta;
          };
        in
        {
          remember-the-milk = app;
          default = app;
        }
      );
    };
}
