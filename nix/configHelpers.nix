{ pkgs, lib, ... }: {
  defaultConfiguration = {
    autostart = let
      wrapEntry = command: "bash -c '${command}'";
      notRunning = query: command: "pgrep -x ${query} || ${command}";
    in [
      (wrapEntry (notRunning "pulseaudio" "pulseaudio -b"))
      (wrapEntry (notRunning "picom" "picom -b"))
    ];

    general-behavior = {
      sloppy_focus = true;
      tag_labels = [ "net" "dev" "term" "fs" "music" "chat" ];
      num_tags = 6;
    };

    user-likes = let
      inherit (lib) getExe;
    in {
      modkey = "Mod4";
      navigator = getExe pkgs.firefox;
      terminal = getExe pkgs.alacritty;
      launcher = "${getExe pkgs.rofi} -show drun";
      explorer = getExe pkgs.xfce.thunar;

      wallpaper = {
        filename = ../assets/wallpaper.png;
        enable_default_splash = true;
      };

      theme = {
        scheme = "dark";

        accents = {
          primary = "blue";
          secondary = "cyan";
        };

        colors = {
          background = "#131313";
          foreground = "#b6beca";
          black = "#202020";
          hovered_black = "#2c2c2c";
          red = "#c6797c";
          green = "#8cc7a9";
          yellow = "#dcc89f";
          blue = "#89a8d2";
          magenta = "#c29eda";
          cyan = "#8bb8d2";
          white = "#e0e1e4";
        };
      };
    };
  };
}
