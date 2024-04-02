# Membrane Agora Plugin

[![Hex.pm](https://img.shields.io/hexpm/v/membrane_agora_plugin.svg)](https://hex.pm/api/packages/membrane_agora_plugin)
[![Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/membrane_agora_plugin/)
[![CircleCI](https://circleci.com/gh/membraneframework/bundlex.svg?style=svg)](https://circleci.com/gh/membraneframework/bundlex)

This repository contains Membrane Agora Plugin, which wraps:
[Agora Server Gateway](https://docs.agora.io/en/server-gateway/overview/product-overview?platform=linux-cpp).
Currently only `Membrane.Agora.Sink` is available.

## Installation
The Agora's Gateway server SDK is available only for Ubuntu (14.04 or higher) and
CentOS (6.6 or higher) operating systems, and so is membrane_agora_plugin.
The required CPU architecture is arm64 or x86-64.

You can use the `membraneframeworklabs/docker_membrane` docker image (in version `v2.2.0-rc2` or higher) as a running environment:
```
docker run -it membraneframeworklabs/docker_membrane
```

To use that plugin in your project, add the following line to your deps in `mix.exs`:
```
	{:membrane_agora_plugin, "~> 0.2.2"}
```

Run `mix deps.get`.

Then you need to set the LD_LIBRARY_PATH:
```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path to your dependencies directory>/membrane_agora_plugin/agora_sdk
```

As an example, you can run the `example.exs` script to see `Membrane.Agora.Sink` in action.
First you need to configure the following Agora's specific environmental variables:
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
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path to your dependencies directory>/membrane_agora_plugin/agora_sdk
elixir example.exs
```
and observe the web demo application.
Once the pipeline is started, audio and video should start playing.

## Provide your own SDK

By default, the plugin will attempt to download the correct SDK for your system. However, if you want to bundle the SDK code yourself, you can provide the environment variable `AGORA_SDK_PRESENT` set to "true". This flag will prevent the bundlex config from pulling the SDK during build time. However, it is up to you to set the correct paths to the SDK for build and compile time using the correct flags for your C compiler.


## Copyright and License

Copyright 2022, [Software Mansion](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

[![Software Mansion](https://logo.swmansion.com/logo?color=white&variant=desktop&width=200&tag=membrane-github)](https://swmansion.com/?utm_source=git&utm_medium=readme&utm_campaign=membrane_template_plugin)

Licensed under the [Apache License, Version 2.0](LICENSE)
