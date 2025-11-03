{
  description = "Xray-core build with russian geoip/geosite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    geodata-tag = "202511030401";
  in {
    packages.${system}.default = pkgs.buildGoModule rec {
      pname = "xray-russia";
      version = "25.10.15";

      src = pkgs.fetchFromGitHub {
        owner = "XTLS";
        repo = "Xray-core";
        rev = "v${version}";
        sha256 = "sha256-E3Ozd2pFLuoV1xc3rPIoh6+ErAN9MYquxwzVTvETMlA=";
      };

      vendorHash = "sha256-Dzml+y6KSCcRqgWk8rP3gGFE1UsGNhNpu2I5NkCBztw=";

      geoip = pkgs.fetchurl {
        url = "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/download/${geodata-tag}/geoip.dat";
        sha256 = "10b7jn1amjx7d3m6yaa6dazp0jyr6l5rn0qhf9x9yhk16a3kjn22";
      };

      geosite = pkgs.fetchurl {
        url = "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/download/${geodata-tag}/geosite.dat";
        sha256 = "08w2qkbf93cc4sg35ajsvzhpixghmnpikskx5j6aqzggrnbdbhq3";
      };

      doCheck = false;

      ldflags = [
        "-s"
        "-w"
      ];
      subPackages = [ "main" ];

      installPhase = ''
        runHook preInstall
        install -Dm755 $GOPATH/bin/main $out/bin/xray
        mkdir -p $out/usr/share/xray
        install -Dm644 ${geoip} $out/usr/share/xray/geoip.dat
        install -Dm644 ${geosite} $out/usr/share/xray/geosite.dat
        runHook postInstall
      '';

      meta = with pkgs.lib; {
        description = "Platform for building proxies to bypass network restrictions. A replacement for v2ray-core, with XTLS support and fully compatible configuration";
        mainProgram = "xray";
        homepage = "https://github.com/XTLS/Xray-core";
        license = with licenses; [ mpl20 ];
        maintainers = with maintainers; [ iopq ];
      };
    };
  };
}

