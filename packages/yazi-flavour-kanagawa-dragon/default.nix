{
  pkgs,
  fetchFromGitHub,
}: let
  flavour = "kanagawa-dragon";
in
  pkgs.stdenv.mkDerivation {
    pname = "yazi-flavour-${flavour}";
    version = "2025-04-15";
    src = fetchFromGitHub {
      owner = "marcosvnmelo";
      repo = "${flavour}.yazi";
      rev = "49055274ff53772a13a8c092188e4f6d148d1694";
      hash = "sha256-gkzJytN0TVgz94xIY3K08JsOYG/ny63Oj2eyGWiWH4s=";
    };

    installPhase = ''
      mkdir -p $out
      cp $src/* $out/
    '';
  }
