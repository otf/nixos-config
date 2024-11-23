# copy from https://github.com/somasis/nixos/blob/13edfc1e5ac7628d86269f8ff049c20572c6b0bb/pkgs/json2nix/json2nix.sh
# shellcheck shell=sh

usage() {
    cat <<EOF
usage: json2nix [FILE]
       ... | json2nix
EOF
    exit 69
}

format() {
    if [ -t 1 ]; then
        nixfmt -w 120
    else
        cat
    fi
}

[ "$#" -le 1 ] || usage

path=${1:-}

case "${path}" in
    /*) : ;;
    - | '') path=/dev/stdin ;;

    # builtins.readFile only wants absolute paths
    *) path=$(readlink -f "${path}") ;;
esac

nix-instantiate --eval \
    --readonly-mode \
    --argstr path "${path}" \
    --expr '{ path }: builtins.fromJSON (builtins.readFile path)' \
    | format
