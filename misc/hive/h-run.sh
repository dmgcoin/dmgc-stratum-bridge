#!/usr/bin/env bash

[[ ! -e ./config.yaml ]] && echo "missing config.yaml" && pwd && exit 1

dmgc_bridge  $(< dmgc_bridge.conf)| tee --append $CUSTOM_LOG_BASENAME.log
