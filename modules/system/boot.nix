{ ... }:

# ── Boot & locale ──────────────────────────────────────────────────────────────
# Mirrors system/boot.nix on the PC.
{
  time.timeZone     = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap    = "pl2";

  services.xserver.xkb = { layout = "pl"; variant = ""; };

  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
