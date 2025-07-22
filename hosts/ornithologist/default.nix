{pkgs, ...}: {
  # Install some packages.
  environment.systemPackages = with pkgs; [
    deploy-rs
  ];

  # Allows remote deployment on ARM systems (ie. Raspberry Pi).
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
