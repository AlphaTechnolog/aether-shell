#!/usr/bin/env bash

Xephyr -br -ac -noreset -screen 1000x700 :1 &
sleep 1
DISPLAY=:1.0 awesome -c $(dirname $0)/../rc.lua
