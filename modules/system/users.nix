{ pkgs, config, lib, ... }:

# ── Users ──────────────────────────────────────────────────────────────────────
{
  users.users.${config.profile.username} = {
    isNormalUser = true;
    group        = config.profile.username;
    extraGroups  = [ "wheel" "docker" ];
    shell        = pkgs.bash;
  };

  users.groups.${config.profile.username} = {};

  # Allow jakub to copy server config to clipboard from the main machine via cpcs
  security.sudo.extraRules = [
    {
      users    = [ config.profile.username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/find /root/server-nixos *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager = {
    useGlobalPkgs       = true;
    useUserPackages     = true;
    backupFileExtension = "bak";

    users.${config.profile.username} = { lib, ... }: {
      home.stateVersion = config.profile.stateVersion;

      home.activation.syncAuthorizedKeys =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          secrets="$HOME/secrets/ssh-authorized-keys"
          dest="$HOME/.ssh/authorized_keys"
          mkdir -p "$HOME/.ssh"
          chmod 700 "$HOME/.ssh"
          if [ -f "$secrets" ]; then
            install -m 600 "$secrets" "$dest"
          else
            echo "WARNING: $secrets not found — authorized_keys not updated"
          fi
        '';

      home.activation.syncGithubKey =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          key="$HOME/secrets/github-ssh-key"
          dest="$HOME/.ssh/github"
          mkdir -p "$HOME/.ssh"
          chmod 700 "$HOME/.ssh"
          if [ -f "$key" ]; then
            install -m 600 "$key" "$dest"
          else
            echo "WARNING: $key not found — GitHub SSH key not deployed"
          fi
        '';

		home.activation.syncGitIdentity =
		  lib.hm.dag.entryAfter [ "writeBoundary" ] ''
		    identity="$HOME/secrets/git-identity"
		    if [ -f "$identity" ]; then
		      source "$identity"
		      ${pkgs.git}/bin/git config --global user.name "$GIT_NAME"
		      ${pkgs.git}/bin/git config --global user.email "$GIT_EMAIL"
		    else
		      echo "WARNING: $identity not found — git identity not configured"
		    fi
		  '';
    };
  };
}
