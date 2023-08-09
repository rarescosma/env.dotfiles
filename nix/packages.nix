{pkgs, ...}: {
  devShells.default = let
    nativeBuildInputs = with pkgs; let
      inherit (pkgs.lib.lists) optionals;
      unstable_gcloud = (
        unstable.google-cloud-sdk.withExtraComponents
        [unstable.google-cloud-sdk.components.gke-gcloud-auth-plugin]
      );
    in
      [
        argocd
        dive
        exa
        gh
        graphviz
        jsonnet
        k9s
        kubernetes-helm
        kubeseal
        kustomize
        mariadb-connector-c
        minikube
        nodejs_20
        nodePackages_latest.yarn
        sccache
        skaffold
      ]
      ++ [unstable.awscli2 unstable_gcloud unstable.kubectl]
      ++ optionals stdenv.isDarwin [darwin.apple_sdk.frameworks.Security pkgconfig openssl darwin.libiconv watch]
      ++ optionals stdenv.isLinux [openssl_legacy];

    inherit (builtins) getAttr filter pathExists toString;
    inherit (pkgs.lib.strings) concatStringsSep;
    inherit (pkgs.lib.lists) naturalSort;

    mkZshSf = pkg: {
      path = pkg + "/share/zsh/site-functions";
      name = pkg.name;
    };
    ZshSfs = filter (p: pathExists p.path) (map mkZshSf nativeBuildInputs);
    Zconcat = sep: key: concatStringsSep sep (naturalSort (map (getAttr key) ZshSfs));
  in
    pkgs.mkShell {
      inherit nativeBuildInputs;
      shellHook = ''
        unset PYTHONPATH
        export _NIX_PROMPT="🧊️"
        export _NIX_FPATH="${Zconcat ":" "path"}"
        echo -e "\n\033[1m>> loading zsh site-functions for: \033[0;32m${Zconcat " " "name"}\033[0m"
        export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/local/share:/usr/share"
      '';
    };
}
