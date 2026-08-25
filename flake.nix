{
  description = "Remember The Milk desktop application for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixgl }:
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

          remember-the-milk-nixgl = pkgs.writeShellApplication {
            name = "rememberthemilk-nixgl";
            runtimeInputs = [ nixgl.packages.${system}.nixGLIntel ];
            text = ''
              exec nixGLIntel ${nixpkgs.lib.getExe pkgs.remember-the-milk} "$@"
            '';
            meta.description = "Remember The Milk with nixGL for non-NixOS Mesa systems";
          };

          default = pkgs.remember-the-milk;
        }
      );

			apps = forAllSystems (
  		  system:
  		  let
  		    packages = self.packages.${system};

  		    mkApp = package: {
  		      type = "app";
  		      program = nixpkgs.lib.getExe package;
  		      meta = package.meta;
  		    };
  		  in
  		  {
  		    remember-the-milk = mkApp packages.remember-the-milk;
  		    nixgl = mkApp packages.remember-the-milk-nixgl;
  		    default = mkApp packages.remember-the-milk;
  		  }
  		);

      nixosModules.default = import ./nixos-module.nix;

      nixosConfigurations.rtm-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.default
          (
            { config, lib, pkgs, ... }:
            {
              nixpkgs.config.allowUnfree = true;

              programs.remember-the-milk.enable = true;
              programs.sway = {
                enable = true;
                extraPackages = [ pkgs.foot ];
              };

              services.greetd = {
                enable = true;
                settings = {
                  default_session = {
                    command = lib.getExe config.programs.sway.package;
                    user = "rtm";
                  };
                };
              };

              users.users.rtm = {
                isNormalUser = true;
              };

              virtualisation.vmVariant.virtualisation = {
                memorySize = 2048;
                cores = 2;
                graphics = true;
              };

              system.stateVersion = "26.05";
            }
          )
        ];
      };
    };
}
