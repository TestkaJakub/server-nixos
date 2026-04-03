{ config, ... }:

# ── ClamAV ─────────────────────────────────────────────────────────────────────
# Copied verbatim from system/clamav.nix on the PC.
{
  services.clamav = {
    updater = {
      enable   = true;
      interval = "hourly";
    };

    daemon = {
      enable = true;
      settings = {
        FollowDirectorySymlinks = false;
        FollowFileSymlinks      = false;
        MaxFileSize             = "500M";
        MaxScanSize             = "500M";
        MaxRecursion            = 16;
        MaxFiles                = 10000;
        LogClean                = false;
      };
    };

    scanner = {
      enable          = true;
      interval        = "weekly";
      scanDirectories = [
        "/home/${config.profile.username}"
        "/tmp"
        "/var/tmp"
      ];
    };
  };
}
