{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.remember-the-milk;
in
{
  options.programs.remember-the-milk = {
    enable = lib.mkEnableOption "Remember The Milk desktop application";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./remember-the-milk.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./remember-the-milk.nix { }";
      description = "The Remember The Milk package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
