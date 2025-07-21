{
  lib,
  stdenv,
  autoreconfHook,
  fetchgit,
  boost,
  cups,
  ...
}: let
  srcRoot = fetchgit {
    url = "https://github.com/dymosoftware/Drivers.git";
    hash = "sha256-3fRALvyGYVpDL0HyUnjDi+TDTX9yeQG6LfZtNuv42pY=";
  };
in
  stdenv.mkDerivation rec {
    pname = "cups-dymo";
    version = "1.5.0";

    src = "${srcRoot}/LW5xx_Linux";

    nativeBuildInputs = [autoreconfHook boost cups];
    makeFlags = [
      "cupsfilterdir=$(out)/lib/cups/filter"
      "cupsmodeldir=$(out)/share/cups/model"
    ];

    patches = [./include-ctime.patch];

    meta = {
      description = "CUPS Linux drivers and SDK for DYMO printers";
      homepage = "https://github.com/dymosoftware/Drivers";
      license = lib.licenses.gpl2Plus;
    };
  }
