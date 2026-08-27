# Remember The Milk for Nix

This repository packages the [Remember The Milk](https://www.rememberthemilk.com/) desktop application for Nix. It repackages the upstream Debian releases and provides a Nix package, runnable flake apps, an overlay, a NixOS module, and a small NixOS VM for testing.

This is an unofficial package. Remember The Milk is proprietary software, so unfree packages must be allowed. The upstream application provides packages for both `x86_64-linux` and `i686-linux`.

## Licensing

The packaging code in this repository is licensed under the MIT License; see [LICENSE](./LICENSE). Remember The Milk itself is proprietary software and remains subject to the [upstream terms of use](https://www.rememberthemilk.com/help/terms.rtm). This repository does not grant any rights to the packaged application, its artwork, or its trademarks.

The upstream archive includes Electron and Chromium license notices. The package preserves these alongside the application and installs copies under `$out/share/licenses/remember-the-milk` for easier discovery.

Do not assume that the repository's MIT license permits redistribution of the built Remember The Milk application. In particular, review the upstream terms before publishing package outputs through a binary cache.

## Development disclosure

AI-assisted tools were used extensively while investigating runtime issues and developing the code and documentation in this repository. This disclosure does not alter the licenses or terms that apply to the repository or the packaged software.

## Running the application

From a checkout of this repository, the normal launcher is:

```console
nix run
```

You can also build the package without launching it:

```console
nix build
```

Then run it with:

```console
./result/bin/rememberthemilk
```

### Non-NixOS systems with Mesa

Applications packaged by Nix cannot normally find graphics drivers installed by a non-NixOS distribution. For Intel, AMD, and Nouveau/Mesa systems, this flake provides an opt-in nixGL launcher:

```console
nix run .#nixgl
```

The provided launcher is available on `x86_64-linux` and is not intended for proprietary NVIDIA drivers.

## Using the NixOS module

Add this repository as an input to your system flake:

```nix
{
  inputs.remember-the-milk.url = "github:carterjandrew/remember-the-milk-nixos";

  outputs = { nixpkgs, remember-the-milk, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        remember-the-milk.nixosModules.default
        {
          nixpkgs.config.allowUnfree = true;
          programs.remember-the-milk.enable = true;
        }
      ];
    };
  };
}
```

## Using the overlay

The overlay adds `remember-the-milk` to a Nixpkgs package set. This is useful when you want to reference it as `pkgs.remember-the-milk` without using the NixOS module:

```nix
{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ remember-the-milk.overlays.default ];

  environment.systemPackages = [
    pkgs.remember-the-milk
  ];
}
```

## Changing the base package

The module also has a `package` option if you need to supply a customized package.

```nix
      modules = [
        remember-the-milk.nixosModules.default
        {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [ remember-the-milk.overlays.default ];
          programs.remember-the-milk = {
            enable = true;
            package = pkgs.remember-the-milk;
          };
        }
      ];
```

## Testing in a NixOS VM

The flake includes a lightweight Sway VM with Remember The Milk installed:

```console
nix run .#nixosConfigurations.rtm-vm.config.system.build.vm
```

The VM automatically logs in to Sway. Press `Super+Enter` to open Foot, then run:

```console
rememberthemilk
```

## Legacy `nix-build`

For installations that are not using flakes, `default.nix` exposes the package as an attribute:

```console
nix-build -A remember-the-milk
./result/bin/rememberthemilk
```
