#!/usr/bin/env bash

if mullvad status 2>/dev/null | grep -q "^Connected"; then
    mullvad disconnect
else
    mullvad connect
fi