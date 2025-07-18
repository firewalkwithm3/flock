{
  boot.initrd.availableKernelModules = ["ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-intel"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e18f128e-1bd3-45d5-b323-50457e5904b4";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-6d222bd7-973b-4b96-b76f-e4c51e885f63".device = "/dev/disk/by-uuid/6d222bd7-973b-4b96-b76f-e4c51e885f63";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7560-EA87";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };
}
