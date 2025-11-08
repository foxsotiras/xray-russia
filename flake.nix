{
  description = "Xray-core build with russian geoip/geosite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    geodata-tag = "202511080938";
  in {
    packages.${system}.xray-russia = pkgs.buildGoModule rec {
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
        sha256 = "1wn8wmlkbdbpfnhnjk5d23g9lgcwipa3860rjqiwzqxf8nf8qp1l";
      };

      geosite = pkgs.fetchurl {
        url = "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/download/${geodata-tag}/geosite.dat";
        sha256 = "004a72zd7kiw9x3dlxy9fdqri680dyyfyf5lxc9cl55vcggkzpnm";
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
        install -Dm644 ${geoip} $out/bin/geoip.dat
        install -Dm644 ${geosite} $out/bin/geosite.dat
        runHook postInstall
      '';
    };
  };
}

