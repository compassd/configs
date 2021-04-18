{
  description =
    "A collaborated set of real world configuration files for dcompass";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    dcompass.url = "github:compassd/dcompass";
  };

  outputs = { nixpkgs, utils, dcompass, ... }:
    with nixpkgs.lib;
    let
      features = [ "geoip-maxmind" "geoip-cn" ];
      forEachFeature = f:
        builtins.listToAttrs (map (v:
          attrsets.nameValuePair "dcompass-${strings.removePrefix "geoip-" v}"
          (f v)) features);
      pkgSet = lib:
        forEachFeature (v:
          lib.buildPackage {
            name = "dcompass-${strings.removePrefix "geoip-" v}";
            version = "git";
            root = ./.;
            passthru.exePath = "/bin/dcompass";
            cargoBuildOptions = default:
              (default ++ [
                "--manifest-path ./dcompass/Cargo.toml"
                ''--features "${v}"''
              ]);
          });
    in utils.lib.eachSystem (utils.lib.defaultSystems) (system: rec {
      # `nix run`
      apps = {
        update = utils.lib.mkApp {
          drv = with import nixpkgs { system = "${system}"; };
            pkgs.writeShellScriptBin "configs-update-data" ''
              set -e
              export PATH=${pkgs.lib.strings.makeBinPath [ wget gzip ]}
              wget -O ./data/full.mmdb --show-progress https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
              wget -O ./data/cn.mmdb --show-progress https://github.com/Hackl0us/GeoIP2-CN/raw/release/Country.mmdb
              wget -O ./data/ipcn.txt --show-progress https://github.com/17mon/china_ip_list/raw/master/china_ip_list.txt
              gzip -f -k ./data/ipcn.txt
            '';
        };
        check = utils.lib.mkApp {
          drv = with import nixpkgs { system = "${system}"; };
            pkgs.writeShellScriptBin "configs-check" ''
              set -e
              export PATH=${
                pkgs.lib.strings.makeBinPath [
                  dcompass.packages."${system}".dcompass-maxmind
                  findutils
                ]
              }
              find ./configs -type f -name '*.yaml' -exec dcompass -v -c '{}' +
              find ./configs -type f -name '*.yml' -exec dcompass -v -c '{}' +
              find ./configs -type f -name '*.json' -exec dcompass -v -c '{}' +
            '';
        };
        commit = utils.lib.mkApp {
          drv = with import nixpkgs { system = "${system}"; };
            pkgs.writeShellScriptBin "configs-check" ''
              set -e
              export PATH=${
                pkgs.lib.strings.makeBinPath [ nixfmt findutils git ]
              }
              find . -type f -name '*.nix' -exec nixfmt '{}' +

              echo -n "Adding to git..."
              git add --all
              echo "Done."

              git status
              read -n 1 -s -r -p "Press any key to continue"

              echo "Commiting..."
              echo "Enter commit message: "
              read -r commitMessage
              git commit -m "$commitMessage"
              echo "Done."

              echo -n "Pushing..."
              git push
              echo "Done."

            '';
        };
      };
      defaultApp = apps.check;
    });
}
