{ system ? builtins.currentSystem }:

let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-26.05";
  # Remember The Milk is distributed as a proprietary binary.
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [];
  };
in
{
  remember-the-milk = pkgs.callPackage ./remember-the-milk.nix { };
}
