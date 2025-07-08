{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./server.nix
  ];
}