# Remember The Milk for Nix

This repository packages the [Remember The Milk](https://www.rememberthemilk.com/) desktop application for Nix. It repackages the upstream 64-bit Debian release and provides a Nix package, runnable flake apps, an overlay, a NixOS module, and a small NixOS VM for testing.

This is an unofficial package. Remember The Milk is proprietary software, so unfree packages must be allowed. Only `x86_64-linux` is supported because that is the architecture provided by the upstream application.

## Licensing

The packaging code in this repository is licensed under the MIT License; see [LICENSE](./LICENSE). Remember The Milk itself is proprietary software and remains subject to the [upstream terms of use](https://www.rememberthemilk.com/help/terms.rtm). This repository does not grant any rights to the packaged application, its artwork, or its trademarks.

The upstream archive includes Electron and Chromium license notices. The package preserves these alongside the application and installs copies under `$out/share/licenses/remember-the-milk` for easier discovery.

Do not assume that the repository's MIT license permits redistribution of the built Remember The Milk application. In particular, review the upstream terms before publishing package outputs through a binary cache.

## Development disclosure

AI-assisted tools were used extensively while investigating runtime issues and developing the code and documentation in this repository. This disclosure does not alter the licenses or terms that apply to the repository or the packaged software.

## Running the application

From a checkout of this repository, the normal launcher is:

```console
nix run .
```

You can also build the package without launching it:

```console
nix build .
./result/bin/rememberthemilk
```

### Non-NixOS systems with Mesa

Applications packaged by Nix cannot normally find graphics drivers installed by a non-NixOS distribution. For Intel, AMD, and Nouveau/Mesa systems, this flake provides an opt-in nixGL launcher:

```console
nix run .#nixgl
```

The normal package does not force nixGL or disable Electron's GPU sandbox. Use the nixGL launcher only when the host graphics stack requires it. The provided launcher is not intended for proprietary NVIDIA drivers.

## Using the NixOS module

Add this repository as an input to your system flake. Replace the example URL with the eventual location of this repository:

```nix
{
  inputs.remember-the-milk.url = "github:OWNER/REPOSITORY";

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

The module also has a `programs.remember-the-milk.package` option if you need to supply a customized package.

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

## Testing in a NixOS VM

The flake includes a lightweight Sway VM with Remember The Milk installed:

```console
nix run .#nixosConfigurations.rtm-vm.config.system.build.vm
```

The VM automatically logs in to Sway. Press `Super+Enter` to open Foot, then run:

```console
rememberthemilk
```

The QEMU runner remains attached to the terminal for as long as the VM is running. Exit Sway with `Super+Shift+E`, shut down the guest, or press `Ctrl+C` in the host terminal to stop it. The runner may create a reusable `nixos.qcow2` disk image in the current directory.

The VM uses the NixOS graphics environment directly; it does not use nixGL. Its virtual GPU is useful for testing package and desktop integration, but it is not representative of physical GPU performance.

## Legacy `nix-build`

For installations that are not using flakes, `default.nix` exposes the package as an attribute:

```console
nix-build -A remember-the-milk
./result/bin/rememberthemilk
```
