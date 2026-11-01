{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  # Tells Home Manager your exact username and home path
  home.username = "lolcraft2";
  home.homeDirectory = "/home/lolcraft2";

  # This value determines the Home Manager release that your configuration is
  # compatible with. You can leave this as is.
  home.stateVersion = "24.11";

  #Shortcut to rebuild and switch
  programs.bash = {
    enable = true;
    shellAliases = {
      sysup = "cd /etc/nixos && sudo git add . && sudo nixos-rebuild switch --flake .#nixos";
    };
  };

 # Install Apps
  home.packages = with pkgs; [
    #Terminal Stuffs
    git
    curl
    btop
    fastfetch
    yazi

    #Apps
    firefox
    kdePackages.dolphin
    equibop
    spotify

    #Customizations
    awww
  ];

  #Caelestia shell
  programs.caelestia = {
    enable = true;
    cli.enable = true;
    settings = {
       paths.wallpaperDir = "/home/lolcraft2/Pictures/Wallpapers";
       };
  };

  #-----Hyprland (declarative)--------
  wayland.windowManager.hyprland = {
    enable = true;
    # The system module (programs.hyprland.enable) already installs Hyprland
    package = null;
    portalPackage = null;

    settings = {
      "cursor:zoom_factor" = 1.0;
      "$mod" = "SUPER";
      "monitor" = "eDP-1, 1920x1200@180,0x0,1";
      exec-once = [
        "caelestia shell -d"
      ];

      # Minimal binds so the session is usable. Edit or extend these.
      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod SHIFT, M, exit"
      ];
    };
  };

  #-----Neovim + Configurations--------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    #Plugins
    plugins = with pkgs.vimPlugins; [
      vim-airline
      nvim-treesitter.withAllGrammars
    ];
  };

  #---------Kitty Configurations----------
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
