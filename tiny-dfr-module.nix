{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.services.tiny-dfr;
  tiny-dfr = (builtins.getFlake "github:LawsOfScience/tiny-dfr").packages.${pkgs.system}.default;
in
{
  options.services.tiny-dfr = {
    enable = mkEnableOption {};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ tiny-dfr ];

    systemd.services = {
      tiny-dfr = {
        description = "Tiny Apple TouchBar daemon";
        after = [
          "systemd-user-sessions.service"
          "getty@tty1.service"
          "plymouth-quit.service"
          "systemd-logind.service" 
        ];
        bindsTo = [ "dev-tiny_dfr_display.device" "dev-tiny_dfr_backlight.device" ];
        serviceConfig = {
          ExecStart = getExe' tiny-dfr "tiny-dfr";
          Restart = "always";
        };
      };
    };

    services.udev.packages = [ tiny-dfr ];
  };
}
