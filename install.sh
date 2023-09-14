#! /bin/bash

if ! test -d ./agora_sdk; then
    wget https://download.agora.io/sdk/release/Agora-RTC-x86_64-linux-gnu-v3.8.202.20-20220627_152601-214165.tgz
    tar xvf Agora-RTC-x86_64-linux-gnu-v3.8.202.20-20220627_152601-214165.tgz
    rm  Agora-RTC-x86_64-linux-gnu-v3.8.202.20-20220627_152601-214165.tgz
    mv agora_rtc_sdk/agora_sdk .
    rm -r agora_rtc_sdk
fi
