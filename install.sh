#! /bin/bash
if ! test -d ./agora_sdk; then
    wget https://download.agora.io/rtsasdk/release/Agora-RTC-x86_64-linux-gnu-v4.2.32-20240814_113547-328017.tgz
    tar xvf Agora-RTC-x86_64-linux-gnu-v4.2.30-20240202_172130-292462.tgz
    rm  Agora-RTC-x86_64-linux-gnu-v4.2.30-20240202_172130-292462.tgz
    mv agora_rtc_sdk/agora_sdk .
    rm -r agora_rtc_sdk
fi