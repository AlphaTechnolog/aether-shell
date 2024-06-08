#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#stylua --command bash

root=$(realpath $(dirname $0))/../

echo $root | xargs \
  stylua -g "*.lua" -g "!*.spec.lua" --

echo "Formatting went well."

# reverting in submodules
declare -a submodules=("bling" "color" "json")

cd $root/extern

# shut up!
xpushd() {
  pushd ${@} >/dev/null 2>&1
}

xpopd() {
  popd ${@} >/dev/null 2>&1
}

for x in ${submodules[@]}; do
  xpushd $x
    git restore .
  xpopd
done

echo "Reverting submodules modifications completed."
