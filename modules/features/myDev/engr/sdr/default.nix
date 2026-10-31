{ ... }:

{
  flake.nixosModules.sdr = {pkgs, ...}:
    {

      hardware.rtl-sdr.enable = true;

      environment.systemPackages = with pkgs; [
        # Primary SDR graphical interfaces
        sdrpp
        gqrx

        # RF and DSP experimentation
        gnuradio
        inspectrum

        # Signal decoders
        rtl_433

        # Hardware diagnostics
        usbutils

        # Aircraft ADS-B decoding
        dump1090-fa

      ];

    };
}
