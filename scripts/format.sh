#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#stylua --command bash

echo $(realpath $(dirname $0)/../) | xargs \
  stylua -g "*.lua" -g "!*.spec.lua" --

echo "Formatting went well."