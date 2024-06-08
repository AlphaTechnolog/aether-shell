let
  fontOverlays = _: prev: {
    material-symbols = prev.callPackage ./pkgs/material-symbols.nix {};
  };
in [fontOverlays]
