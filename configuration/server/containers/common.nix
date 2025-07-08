{ modulesPath, ... }:
{
  # Import Proxmox LXC configuration.
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
}

