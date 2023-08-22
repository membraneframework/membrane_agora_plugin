# Membrane Agora Plugin

This repository contains Membrane Agora Plugin, which wraps:
[Agora Server Gateway](https://docs.agora.io/en/server-gateway/overview/product-overview?platform=linux-cpp).
Currently only `Membrane.Agora.Sink` is available.

## Installation
The Agora's Gateway server SDK is available only for linux plafrom, and so is membrane_agora_plugin.

Clone this repository:
```
git clone https://github.com/membraneframework-labs/membrane_agora_plugin
cd membrane_agora_plugin
```

Then install the required Agora Server Gateway's SDK with:
```
chmod a+x install.sh
./install.sh
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
Before running any of the projects that use membrane_agora_plugin, make sure to set the `LD_LIBRARY_PATH`:
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path to membrane_agora_plugin repository>/agora_sdk
```
You need to download all the elixir dependencies with:
```
mix deps.get
```

As an example, you can run the `example.exs` script to see `Membrane.Agora.Sink` in action.
First, you need to configure the following Agora's specific environmental variables:
```bash
  export AGORA_CHANNEL_NAME=<the name of the channel for which you have generated the temporary RTC token>
  export AGORA_TOKEN=<your Agora's temporary RTC token>
  export AGORA_APP_ID=<your Agora's application ID>
  export AGORA_USER_ID=<any string consisting only of ciphers (0-9)>
```
[Here](https://docs.agora.io/en/server-gateway/reference/manage-agora-account?platform=linux-cpp) you can read how to obtain these values.

Then run the exemplary [web demo application](https://webdemo.agora.io/basicVideoCall/index.html) (you can read about it [here](https://docs.agora.io/en/server-gateway/get-started/integrate-sdk?platform=linux-cpp#use-the-client-to-receive-streams-sent-from-the-server)).
Remember that you need to use the same Agora parameters as you have specified in the environmental variables.

Finaly, type:
```
mix run example.exs
```
and observe the web demo application.
Once the pipeline is started, audio and video should start playing.