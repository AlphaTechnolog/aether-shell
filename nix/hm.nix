{pkgs}: {config, ...}: let
  inherit (pkgs) lib;

  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    getExe
  ;

  configHelpers = import ./configHelpers.nix {
    inherit lib pkgs;
  };

  inherit (configHelpers)
    defaultConfiguration
  ;
in {
  options.programs.aetherShell = {
    enable = mkEnableOption "aetherShell";

    autostart = mkOption rec {
      type = types.listOf types.str;
      default = defaultConfiguration.autostart;
      example = default;
    };

    general-behavior = mkOption rec {
      default = defaultConfiguration.general-behavior;
      example = default;

      type = types.submoduleWith {
        modules = [{
          options = {
            sloppy_focus = mkOption rec {
              type = types.bool;
              default = defaultConfiguration.general-behavior.sloppy_focus;
              example = default;
            };

            tag_icons = mkOption rec {
              type = types.listOf types.str;
              default = defaultConfiguration.general-behavior.tag_icons;
              example = default;
            };

            num_tags = mkOption {
              type = types.int;
              default = defaultConfiguration.general-behavior.num_tags;
            };
          };
        }];
      };
    };

    user-likes = mkOption rec (let
      optgenerator = type: default: mkOption rec {
        inherit type default;
        example = default;
      };

      strtype = optgenerator types.str;
      booltype = optgenerator types.bool;
      inttype = optgenerator types.int;

      inherit (defaultConfiguration) user-likes;
    in {
      default = user-likes;
      example = default;

      type = types.submoduleWith {
        modules = [{
          options = {
            modkey = strtype user-likes.modkey;
            navigator = strtype user-likes.navigator;
            terminal = strtype user-likes.terminal;
            launcher = strtype user-likes.launcher;
            explorer = strtype user-likes.explorer;

            wallpaper = mkOption rec {
              default = user-likes.wallpaper;
              example = default;

              type = types.submoduleWith {
                modules = [{
                  options = {
                    filename = strtype user-likes.wallpaper.filename;

                    rounded_corners = types.submoduleWith {
                      modules = [{
                        options = let
                          inherit (user-likes.wallpaper) rounded_corners;
                        in {
                          top_left = booltype rounded_corners.top_left;
                          top_right = booltype rounded_corners.top_right;
                          bottom_left = booltype rounded_corners.bottom_left;
                          bottom_right = booltype rounded_corners.bottom_right;
                          roundness = inttype rounded_corners.roundness;
                        };
                      }];
                    };
                  };
                }];
              };
            };

            theme = mkOption rec {
              default = user-likes.theme;
              example = default;

              type = types.submoduleWith {
                modules = [{
                  options = let
                    inherit (user-likes) theme;
                  in {
                    scheme = strtype theme.scheme;

                    accents = mkOption rec {
                      default = theme.accents;
                      example = default;

                      type = types.submoduleWith {
                        modules = [{
                          options = {
                            primary = strtype theme.accents.primary;
                            secondary = strtype theme.accents.secondary;
                          };
                        }];
                      };
                    };

                    colors = mkOption rec {
                      default = theme.colors;
                      example = default;

                      type = types.submoduleWith {
                        modules = [{
                          options = let
                            inherit (theme) colors;
                          in {
                            background = strtype colors.background;
                            foreground = strtype colors.foreground;
                            black = strtype colors.black;
                            hovered_black = strtype colors.hovered_black;
                            red = strtype colors.red;
                            green = strtype colors.green;
                            yellow = strtype colors.yellow;
                            blue = strtype colors.blue;
                            magenta = strtype colors.magenta;
                            cyan = strtype colors.cyan;
                            white = strtype colors.white;
                          };
                        }];
                      };
                    };
                  };
                }];
              };
            };
          };
        }];
      };
    });
  };

  config = let
    cfg = config.programs.aetherShell;
    jsonFormat = pkgs.formats.json {};
  in mkIf (cfg != null && cfg != { }) {
    # install the aether shell configuration on hm activation
    home.activation = mkIf cfg.enable {
      installAetherShell = let
        git = getExe pkgs.git;
      in ''
        if ! test -d ~/.config/awesome; then
          ${git} clone https://github.com/alphatechnolog/aether-shell.git \
            --recurse-submodules \
            ~/.config/awesome || true
        fi
      '';
    };

    # generating configuration files
    xdg.configFile = {
      "aether-shell/user-likes.json" = mkIf (cfg.user-likes != { }) {
        source = jsonFormat.generate "user-likes.json" cfg.user-likes;
      };

      "aether-shell/autostart.json" = mkIf (cfg.autostart != [ ]) {
        source = jsonFormat.generate "autostart.json" cfg.autostart;
      };

      "aether-shell/general-behavior.json" = mkIf (cfg.autostart != { }) {
        source = jsonFormat.generate "general-behavior.json" cfg.general-behavior;
      };
    };

    # Installing needed fonts
    fonts.fontconfig = {
      enable = true;
    };

    home.packages = with pkgs; [
      roboto
      material-symbols
    ];
  };
}
