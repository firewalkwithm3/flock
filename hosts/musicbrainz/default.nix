{pkgs, ...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5d71cc16-f1ee-4b87-87b2-00fdf98442bd";
    fsType = "ext4";
  };

  fileSystems."/home/fern/docker/data" = {
    device = "/dev/disk/by-uuid/0eb05c79-7765-4b7e-bf22-c3a53f516db5";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/1402e27f-861f-4ecd-8b46-a29461ec3eeb";}
  ];

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
