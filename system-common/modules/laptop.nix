{ config, lib, pkgs, osConfig, inputs, ... }:

{
  # this was originally added to fix suspend issues on Clevo; now common system config
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  
  # not recommended to use power-profiles-daemon together with tlp
  # additionally, this also comes with a UI switch to select between performance / balanced / powersave,
  # whereas we would prefer an UX where plugging or unplugging the AC cable "does the right thing"
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      # default is balance-power. see https://linrunner.de/tlp/settings/processor.html
      # i've not measured this actually achieves anything - we might retire this non-default setting in the future.
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    };
  };

  environment.systemPackages = with pkgs; [
    powertop # just the package / cli for monitoring purposes, not the service / auto-tuning functionality, as that conflicts with tlp
  ];
}