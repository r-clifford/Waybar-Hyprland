{
  description = "Waybar flake with hyprland workspace support";

  outputs = {
    self,
    nixpkgs,
  }: let
    # to work with older version of flakes
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

    # Generate a user-friendly version number.
    version = builtins.substring 0 8 lastModifiedDate;

    # System types to support.
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];

    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    lib = nixpkgs.lib;

    # Nixpkgs instantiated for supported system types.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      });
  in {
    # A Nixpkgs overlay.
    overlay = final: prev: {
      waybar-hyprland = with final;
        stdenv.mkDerivation rec {
          name = "waybar-hyprland-${version}";

          src = ./.;

          nativeBuildInputs = [
          howard-hinnant-date
          python311 
          wayland-protocols autoreconfHook ninja meson pkg-config cmake fmt_8 spdlog gtkmm3 libdbusmenu-gtk3 jsoncpp libsigcxx libinput libnl playerctl libpulseaudio udev libmpdclient libxkbcommon libjack2 wireplumber sndio upower libevdev gtk-layer-shell scdoc catch2_3
          glib
          python3.pkgs.pygobject3
          wrapGAppsHook
          ];
          mesonFlags = (lib.mapAttrsToList
          (option: enable: "-D${option}=${if enable then "enabled" else "disabled"}")
    {
      dbusmenu-gtk = true;
      jack = true;
      libinput = true;
      libnl = true;
      libudev = true;
      mpd = true;
      pulseaudio = true;
      rfkill = true;
      sndio = true;
      tests = true;
      upower_glib = true;
      wireplumber = true;
      systemd = false;
          })++["--prefix=/usr" "--buildtype=plain" "-Dexperimental=true"];
          };
    };

    # Provide some binary packages for selected system types.
    packages = forAllSystems (system: {
      inherit (nixpkgsFor.${system}) waybar-hyprland;
    });

    # The default package for 'nix build'. This makes sense if the
    # flake provides only one package or there is a clear "main"
    # package.
    defaultPackage = forAllSystems (system: self.packages.${system}.waybar-hyprland);

    # A NixOS module, if applicable (e.g. if the package provides a system service).
    nixosModules.waybar-hyprland = {pkgs, ...}: {
      nixpkgs.overlays = [self.overlay];

      environment.systemPackages = [pkgs.waybar-hyprland];

      #systemd.services = { ... };
    };

    # Tests run by 'nix flake check' and by Hydra.
  };
}
