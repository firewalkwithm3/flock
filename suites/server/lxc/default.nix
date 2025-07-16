{modulesPath, ...}: {
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ../. # Server config.
  ];
}
