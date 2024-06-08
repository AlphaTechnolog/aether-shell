{
  description = "Aether shell nix integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = import ./nix/overlays.nix;
    };
  in {
    homeManagerModules = {
      aetherShell = import ./nix/hm.nix {inherit pkgs;};
      default = self.homeManagerModules.aetherShell;
    };
  };
}
