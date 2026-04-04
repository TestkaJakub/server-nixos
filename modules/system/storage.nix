{ config, pkgs, ... }:

# ── Storage — 3.6T HDD via LVM ────────────────────────────────────────────────
# Physical: /dev/sda → LVM PV → VG: storage → LV: data
# Mounted at /mnt/data
#
# To add a new logical volume later:
#   sudo lvcreate -L <size> -n <name> storage
#   sudo mkfs.ext4 /dev/storage/<name>
#   add a new fileSystems entry below
#
# Samba share: \\192.168.0.252\data (LAN)
#              \\100.85.171.80\data (Tailscale)
#
# Samba users must be added manually (run once):
#   sudo smbpasswd -a jakub
{
  # ── Mount ───────────────────────────────────────────────────────────────────
  fileSystems."/mnt/data" = {
    device  = "/dev/disk/by-uuid/d5b482c5-0856-487d-b07c-5394a3deef3d";
    fsType  = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # ── LVM ─────────────────────────────────────────────────────────────────────
  services.lvm.enable = true;

  # ── Samba ───────────────────────────────────────────────────────────────────
  services.samba = {
    enable   = true;
    settings = {
      global = {
        "workgroup"                = "WORKGROUP";
        "server string"            = "server";
        "server role"              = "standalone server";
        "map to guest"             = "never";
        "guest ok"                 = "no";
        "security"                 = "user";
      };

      data = {
        path            = "/mnt/data";
        browseable      = "yes";
        "read only"     = "no";
        "guest ok"      = "no";
        "create mask"   = "0664";
        "directory mask" = "0775";
        "valid users"   = "jakub";
        comment         = "Storage";
      };
    };
  };

  # ── Samba discovery (optional — lets macOS/Windows find the share) ──────────
  services.samba-wsdd = {
    enable    = true;
    openFirewall = true;
  };

  # ── Firewall ─────────────────────────────────────────────────────────────────
  networking.firewall = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

  # ── Create mount point ───────────────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /mnt/data 0775 jakub jakub -"
  ];
}
