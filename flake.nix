{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
    (system:
      let
        overlays = [(_: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        })];
        pkgs = import nixpkgs { inherit system overlays; };
        inherit (pkgs.lib.lists) optionals;
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            argocd
            unstable.awscli2
            dive
            exa
            gh
            unstable.google-cloud-sdk
            graphviz
            jsonnet
            k9s
            unstable.kubectl
            kubernetes-helm
            kubeseal
            kustomize
            minikube
            nodejs_20
            sccache
            skaffold
          ]
          ++ optionals stdenv.isDarwin [ darwin.libiconv watch ]
          ++ optionals stdenv.isLinux [ openssl_legacy ];
          shellHook = ''
            unset PYTHONPATH
            export _NIX_PROMPT="🧊️"

            # nicked from https://github.com/direnv/direnv/issues/443#issuecomment-642275550
            # and adapted for zsh use
            _nix_fpath_inputs=( "''${buildInputs[@]}" )
            _report=""
            for p in ''${_nix_fpath_inputs[@]}; do
                if [[ -d "$p/share/zsh/site-functions" ]]; then
                    _report="''${_report}''${_report+ }$(echo $p | cut -d- -f2-)"
                    _NIX_FPATH="''${_NIX_FPATH}''${_NIX_FPATH+:}$p/share/zsh/site-functions"
                fi
            done
            export _NIX_FPATH
            echo -e "\n\033[1m>> loading zsh site-functions for:\033[0;32m''${_report}\033[0m"
          '';
        };
      }
    );
}
