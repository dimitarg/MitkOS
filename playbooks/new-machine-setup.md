On a freshly installed NixOS system

1. Open Console
2. nix-shell -p git
3. export NIXPKGS_ALLOW_UNFREE=1
4. nix-shell -p vscode
5. git clone https://github.com/dimitarg/MitkOS.git
6. `cd MitkOS`, `code .` to be able to text edit the configurations
7. Another vscode instance for the current config, `cd /etc/nixos`. `code .`
8. In `/etc/nixos/configuration.nix`, change `networking.hostName = <something unique>` so it doesn't conflict with existing hosts in `MitkOS`, then `sudo nixos-rebuild switch` 
9. sudo systemctl restart systemd-hostnamed.service
10. In MitkOS, copy one of your existing hosts as a template, in this playbook run I've copied hosts/nixos to the new host i'm configuring, hosts/spare
11. Replace the new host's hardware-configuration.nix with the install-generated /etc/nixos/hardware-configuration.nix 
12. In `from-install.nix`, replace the only one in that file with the equivalent line residing in your current `/etc/nixos/configuration.nix`
13. In `default.nix`, review which config is applicable, and whether you need extra hardware config from `nixos-hardware`. In this playbook run example, i replaced alder lake with comet lake, since this spare machine is an older machine.
14. In flake.nix, declare the flake output for your new machine, using an existing one as a template.
15. In a new terminal (where the change of 8. and 9. has taken effect),
    - nix-shell -p git
    - git add .
    - git config user.email "dimitar.georgiev.bg@gmail.com"
    - git config user.name "Dimitar Georgiev"
    - git commit
    - ./deploy.sh
16. sudo rm /root/.nix-defexpr/channels
17. sudo rm /nix/var/nix/profiles/per-user/root/channels
18. For good measure, `reboot`
19. Provision any secrets, password managers, ssh keys needed
20. `git remote remove origin`, `git remote add origin git@github.com:dimitarg/MitkOS.git`
21. Commit and push the new config