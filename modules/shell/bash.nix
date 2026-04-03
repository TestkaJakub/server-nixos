{ config, pkgs, ... }:

# ── Bash ───────────────────────────────────────────────────────────────────────
# Mirrors shell/bash.nix on the PC — same prompt colors, same zoxide setup,
# same micro+glow binding. Desktop-only tools (wl-clipboard, grim, etc.) omitted.
let
  user = config.profile.username;
in
{
  home-manager.users.${user} = {
    home.packages = with pkgs; [ zoxide ];

    programs.zoxide = {
      enable                = true;
      enableBashIntegration = true;
    };

    programs.bash = {
      enable           = true;
      enableCompletion = true;

      shellAliases = {
        cd   = "z";
        ll   = "ls -lah";
        dps  = "docker ps";
        dlog = "docker logs -f";
        # grab server config into PC clipboard — mirrors cpc workflow
        # add scpc = "ssh jakub@server cpc | wl-copy" on your PC instead
      };

      initExtra = ''
        # ── Prompt ──────────────────────────────────────────────────────────
        # Mirrors the PC PS1: user@host date path > (same pink/purple colors)
        if [[ $- == *i* ]]; then
          _build_ps1() {
            local date_str
            date_str=$(date '+%d-%m-%Y %H:%M:%S')
            PS1="\[\033[38;2;255;105;180m\]\u\[\033[38;2;102;102;204m\]@\[\033[38;2;255;105;180m\]\h\[\033[0m\] $date_str \w \[\033[38;2;102;102;204m\]bash >\[\033[0m\] "
          }
          PROMPT_COMMAND=_build_ps1
        fi
      '';
    };

    # micro + glow preview — mirrors dev-tools/misc.nix on the PC
    xdg.configFile."micro/init.lua".text = ''
      local config = import("micro/config")
      local shell  = import("micro/shell")

      function init()
        config.TryBindKey("Ctrl-m", "lua:initlua.glowPreview", true)
      end

      function glowPreview(bp)
        local path = bp.Buf.Path
        shell.RunInteractiveShell("${pkgs.glow}/bin/glow " .. path .. " | less -R", true, false)
      end
    '';

    # bat config — mirrors editors/neovim.nix on the PC
    home.file.".config/bat/config".text = ''
      --theme="Nord"
      --style="numbers,changes,grid"
      --paging=auto
    '';
  };
}
