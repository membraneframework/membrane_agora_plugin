# Membrane Agora Plugin

This repository contains Membrane Agora Plugin, which wraps:
[Agora Server Gateway](https://docs.agora.io/en/server-gateway/overview/product-overview?platform=linux-cpp).
Currently only `Membrane.Agora.Sink` is available.

## Installation
Clone this repository:
```
git clone https://github.com/membraneframework-labs/membrane_agora_plugin
```
and download the Agora Server Gateway SDK:
```
# Get SDK
wget https://download.agora.io/sdk/release/Agora-RTC-x86_64-linux-gnu-v3.8.202.20-20220627_152601-214165.tgz
tar xvf Agora-RTC-x86_64-linux-gnu-v3.8.202.20-20220627_152601-214165.tgz
```
Then copy the `agora_sdk` directory from the `agora_rtc_sdk` (it's the directory you have just extracted the files you had downloaded)
to the membrane_agora_plugin directory:
```
cp -r agora_rtc_sdk/agora_sdk membrane_agora_plugin/
```

Later update the `LD_LIBRARY_PATH`:
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path to the agora_sdk directory>
```

Finally, you can use the cloned repository as a dependency in `mix.exs` of your project:
```
deps() do
    ... 
    {:membrane_agora_plugin, path: <path to the cloned repository>},
    ...
end
```
and use the `Membrane.Agora.Sink` element.

## Usage
You can run the `example.exs` script with an exemplary pipeline to see `Membrane.Agora.Sink` in action.
First, you need to configure the following Agora's specific environmental variables:
```bash
  export AGORA_CHANNEL_NAME=<the name of the channel for which you have generated the temporary RTC token>
  export AGORA_TOKEN=<your Agora's temporary RTC token>
  export AGORA_APP_ID=<your Agora's application ID>
  export AGORA_USER_ID=<any string consisting only of ciphers (0-9)>
```
[Here](https://docs.agora.io/en/server-gateway/reference/manage-agora-account?platform=linux-cpp) you can read how to obtain these values.

Then run the exemplary [web demo application](https://webdemo.agora.io/basicVideoCall/index.html) (you can read about it [here](https://docs.agora.io/en/server-gateway/get-started/integrate-sdk?platform=linux-cpp#use-the-client-to-receive-streams-sent-from-the-server)).
Remember that you need to use the same Agora parameters as you have specified in the `example.exs`.

Finaly, type:
```
mix run example.exs
```
and observe the web demo application.
Once the pipeline is started, audio and video should start playing.