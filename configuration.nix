# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

let
  wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";

  # The greeter UI. Edit this QML to change anything about the login screen.
  greeterQml = pkgs.writeText "greeter.qml" ''
    import QtQuick
    import QtQuick.Controls
    import QtQuick.Layouts
    import Quickshell
    import Quickshell.Services.Greetd

    FloatingWindow {
      id: win
      visible: true
      color: "#11111b"

      property string errorText: ""
      property bool busy: false

      SystemClock {
        id: clock
        precision: SystemClock.Seconds
      }

      Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
          if (responseRequired) {
            Greetd.respond(password.text);
            password.text = "";
          }
        }

        function onAuthFailure(message) {
          win.busy = false;
          win.errorText = "Wrong password";
          password.forceActiveFocus();
        }

        function onReadyToLaunch() {
          Greetd.launch(["start-hyprland"]);
        }
      }

      function login() {
        if (busy) return;
        errorText = "";
        busy = true;
        Greetd.createSession(username.text);
      }

      // Wallpaper
      Image {
        anchors.fill: parent
        source: "file://${wallpaper}"
        fillMode: Image.PreserveAspectCrop
      }

      // Dark overlay
      Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
      }

      // Clock
      Column {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 90
        spacing: 4

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDateTime(clock.date, "HH:mm")
          color: "#cdd6f4"
          font.pixelSize: 96
          font.family: "JetBrainsMono Nerd Font"
          font.bold: true
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
          color: "#a6adc8"
          font.pixelSize: 22
          font.family: "JetBrainsMono Nerd Font"
        }
      }

      // Login card
      Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 60
        width: 380
        height: 270
        radius: 20
        color: "#cc1e1e2e"
        border.color: "#44ffffff"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 28
          spacing: 14

          Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Welcome back"
            color: "#cdd6f4"
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
          }

          TextField {
            id: username
            Layout.fillWidth: true
            text: "lolcraft2"
            placeholderText: "Username"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color: "#cdd6f4"
            background: Rectangle {
              radius: 10
              color: "#313244"
            }
            onAccepted: password.forceActiveFocus()
          }

          TextField {
            id: password
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: TextInput.Password
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color: "#cdd6f4"
            enabled: !win.busy
            focus: true
            background: Rectangle {
              radius: 10
              color: "#313244"
              border.color: win.errorText !== "" ? "#f38ba8" : "transparent"
              border.width: 1
            }
            onAccepted: win.login()
            Component.onCompleted: forceActiveFocus()
          }

          Text {
            Layout.alignment: Qt.AlignHCenter
            text: win.errorText
            color: "#f38ba8"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            visible: win.errorText !== ""
          }

          Button {
            Layout.fillWidth: true
            text: win.busy ? "Logging in..." : "Log in"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            enabled: !win.busy
            onClicked: win.login()
            contentItem: Text {
              text: parent.text
              color: "#11111b"
              font: parent.font
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
              radius: 10
              color: parent.down ? "#74c7ec" : "#89b4fa"
            }
          }
        }
      }

      // Power buttons
      Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30
        spacing: 12

        Button {
          text: "Reboot"
          onClicked: Quickshell.execDetached(["systemctl", "reboot"])
        }
        Button {
          text: "Power off"
          onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
        }
      }
    }
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # GPU RELATED
  # (nvidia_drm.modeset=1 is already set by hardware.nvidia.modesetting.enable)
  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "nixos"; # Define your hostname.

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Custom Commands
  programs.bash.enable = true;
  home-manager.backupFileExtension = "backup";

  # Set your time zone.
  time.timeZone = "Asia/Kathmandu";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."lolcraft2" = {
    isNormalUser = true;
    description = "LoLCraft2";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.editor = false;

  # Fix GPU names for hyprland
  services.udev.extraRules = ''
    KERNEL=="card*", SUBSYSTEM=="drm", KERNELS=="0000:64:00.0", SYMLINK+="dri/amd-igpu"
    KERNEL=="card*", SUBSYSTEM=="drm", KERNELS=="0000:01:00.0", SYMLINK+="dri/nvidia-dgpu"
  '';

  # Configure Hybrid GPU
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:100:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Hyprland (system level: installs it, registers the session, sets up portals)
  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # greetd running a custom Quickshell greeter inside the cage compositor
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.cage}/bin/cage -s -- ${pkgs.quickshell}/bin/quickshell -p ${greeterQml}";
        user = "greeter";
      };
    };
  };

  # Make the greeter's compositor use the AMD iGPU, not the NVIDIA card.
  systemd.services.greetd.environment = {
    WLR_DRM_DEVICES = "/dev/dri/amd-igpu";
  };

  # Fonts used by the greeter
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Apps
  environment.systemPackages = with pkgs; [
    kitty
    rofi
    waybar
    pciutils
    quickshell
 ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
