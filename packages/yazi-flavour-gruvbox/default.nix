{
  pkgs,
  fetchFromGitHub,
}: let
  flavor = "gruvbox-dark";
in
  pkgs.stdenv.mkDerivation {
    pname = "yazi-flavor-${flavor}";
    version = "2025.04.24";
    src = fetchFromGitHub {
      owner = "bennyyip";
      repo = "${flavor}.yazi";
      rev = "91fdfa70f6d593934e62aba1e449f4ec3d3ccc90";
      hash = "sha256-RWqyAdETD/EkDVGcnBPiMcw1mSd78Aayky9yoxSsry4=";
    };

    installPhase = ''
      mkdir -p $out
      cp $src/* $out/
    '';
  }
