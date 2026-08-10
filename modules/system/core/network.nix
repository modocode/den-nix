{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.network = {
    pkgs,
    lib,
    ...
  }:


    {
      networking.networkmanager.enable = true;
      security.sudo.enable = true;

      # networking.wg-quick.interfaces = {
      #     surfshark = {
      #       # Use the 'Address' from your downloaded Surfshark .conf
      #       address = [ "10.14.0.2/16" ];
            
      #       # Use the 'DNS' from your downloaded Surfshark .conf
      #       dns = [ "162.252.172.57" "149.154.159.92" ];

      #       # Path to a file containing your Private Key. 
      #       # Storing it in a file prevents it from being in the world-readable /nix/store.
      #       privateKeyFile = "/etc/nixos/surfshark_private.key";

      #       peers = [
      #         {
      #           # Use 'PublicKey' and 'Endpoint' from the downloaded .conf
      #           publicKey = "6C8O3L/Li0JOO5aWvL6PrciiZOOaRBtWmempOUENLQs=";
      #           allowedIPs = [ "0.0.0.0/0" "::/0" ];
      #           endpoint = "mx-qro.prod.surfshark.com:51820";
                
      #           # Keeps the connection alive through NAT
      #           persistentKeepalive = 25;
      #         }
      #       ];
      #   };


      #};
      
    



    };

}

