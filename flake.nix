{
  description = "How to create a references free NixOS image?";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      configuration = { config, lib, pkgs, ... }: {
        boot.loader.grub.device = "/dev/disk/by-label/nixos";
        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
          autoResize = true;
        };
        system.stateVersion = "25.11";
        system.build.diskImage = import (pkgs.path + "/nixos/lib/make-disk-image.nix") {
          inherit config lib pkgs;
          postVM = ''
            ${pkgs.zstd}/bin/zstd --rm $out/nixos.img
          '';
        };
      };

      nixos = pkgs.nixos configuration;

      img = pkgs.lib.overrideDerivation nixos.diskImage (_oldAttrs: {
        __structuredAttrs = true;
        unsafeDiscardReferences.out = true;
      });
    in {
      packages.${system}.default = img;
    };
}
