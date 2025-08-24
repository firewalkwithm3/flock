{pkgs, ...}: let
  rootDisk = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi2";
  rootPart = "/dev/disk/by-uuid/0804a690-0dbe-493d-9f2c-5db091569649";
  dockerPart = "/dev/disk/by-uuid/0eb05c79-7765-4b7e-bf22-c3a53f516db5";
in {
  boot.loader.grub.device = rootDisk;

  fileSystems."/" = {
    device = rootPart;
    fsType = "ext4";
  };

  fileSystems."/home/fern/docker" = {
    device = dockerPart;
    fsType = "ext4";
  };

  # Update Musicbrainz search indexes once a week.
  systemd.timers."musicbrainz-update-indexes" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      Unit = "musicbrainz-update-indexes.service";
    };
  };

  systemd.services."musicbrainz-update-indexes" = {
    script = ''
      set -eu
      cd /home/fern/docker/stacks/musicbrainz
      ${pkgs.docker}/bin/docker compose exec -T indexer python -m sir reindex --entity-type artist --entity-type release
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "fern";
    };
  };
}
