{
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  ...
}:

buildDotnetModule rec {
  pname = "webone";
  version = "0.17.5";

  src = fetchFromGitHub {
    owner = "atauenis";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Dybm0Yl3f6Q7bjDRZHn7hCIYBryS93PtzFLC2V+LzXg=";
  };

  projectFile = "WebOne.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.runtime_6_0;

  meta = {
    homepage = "https://github.com/atauenis/webone";
    description = "HTTP 1.x proxy that makes old web browsers usable again in the Web 2.0 world.";
  };
}
