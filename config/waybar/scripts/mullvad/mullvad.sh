#!/usr/bin/env bash

status=$(mullvad status 2>/dev/null)

if echo "$status" | grep -q "^Connected"; then
    echo '{"text":" VPN ON","tooltip":"Mullvad connected","class":"connected"}'
else
    echo '{"text":" VPN OFF","tooltip":"Mullvad disconnected","class":"disconnected"}'
fi