{
  flake.nixosModules.hostMain = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/f7bbe3de-4c48-4845-9019-c71f297bedcf";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/7BE9-8B5D";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    # fileSystems."/home/monad/org" =
    #   { device = "myDropBox3.1:OrgNotes2";
    #     fsType = "fuse.rclone";
    #   };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;




  };

}
