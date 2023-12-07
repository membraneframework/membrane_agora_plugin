#! /bin/bash

if ! test -d ./agora_sdk; then
    wget -qO- $1 | tar xvz 
    mv agora_rtc_sdk/agora_sdk .
    rm -r agora_rtc_sdk
fi
