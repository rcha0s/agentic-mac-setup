{ config, pkgs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/github/agentic-mac-setup";
in
{
  home.username = "risawe";
  home.homeDirectory = "/Users/risawe";
  home.stateVersion = "23.11";
  home.language.base = "en_US.UTF-8";

  home.packages = with pkgs; [
    git
    curl
    wget
    jq
    fd
    fastfetch
    ripgrep
    killall
    lazygit
    tree
    bun
    rustup
    zip
    unzip
    nerd-fonts.hack
    roboto
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    # Kun-style workflow additions:
    tmux            # persistent session backbone (load-bearing)
    neovim          # editor
    stow            # symlink management fallback if we ever need it
    gh              # GitHub CLI (also needed by gh-axi/no-mistakes/firstmate)
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "Rohan Isawe";
        email = "rohanisawe2@gmail.com";
      };
      core.editor = "vim";
      color.ui = true;
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.updateRefs = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      command_timeout = 1000;
      add_newline = false;
      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$character";

      directory.style = "blue";

      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        stashed = "≡";
      };

      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      bindkey '^f' autosuggest-accept

      # Auto-attach to tmux 'main' session on interactive shell start.
      # tmux is the load-bearing session primitive in this setup — every shell
      # lives inside a tmux session so layouts survive terminal restarts.
      if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -z "$INSIDE_EMACS" ]] && [[ -z "$VSCODE_PID" ]] && command -v tmux >/dev/null 2>&1; then
        exec tmux new-session -A -s main
      fi
    '';
    shellAliases = {
      ".." = "cd ..";
      m = "git switch main";
      mst = "git switch master";
      pull = "git pull";
      push = "git push";
      pushf = "git push --force";
      add = "git add .";
      amend = "git commit --amend";
      reset = "git reset --soft HEAD^";
      rebasem = "git rebase -i main";
      rebasemst = "git rebase -i master";
      rebuild = "/run/current-system/sw/bin/darwin-rebuild switch --flake ~/github/agentic-mac-setup#mac";
      # Agent workflow shortcuts
      cc = "claude";
      gnfun = "gnhf";
      th = "treehouse";
      nm = "no-mistakes";
    };
  };

  home.file = {
    ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.config/wezterm";
    ".config/nvim".source    = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.config/nvim";
    ".tmux.conf".source      = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/files/.tmux.conf";
  };
}
