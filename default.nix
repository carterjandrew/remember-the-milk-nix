{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {
    inherit system;
    config.allowUnfree = true;
  },
}:

{
  remember-the-milk = pkgs.callPackage ./remember-the-milk.nix { };
}
