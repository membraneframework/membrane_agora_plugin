#! /bin/bash

if ! test -d ./agora_sdk; then
    if [[ $1 == http* ]]; then
        wget -qO- $1 | tar xvz 
    else
        tar xvf $1
    fi

    mv agora_rtc_sdk/agora_sdk .
    rm -r agora_rtc_sdk 
    
fi
