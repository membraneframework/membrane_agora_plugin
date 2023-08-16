#pragma once

#include <csignal>
#include <cstring>
#include <sstream>
#include <string>
#include <thread>
#include <unistd.h>
#include <iostream>

#include "IAgoraService.h"
#include "NGIAgoraRtcConnection.h"

#include "log.h"
#include "sample_connection_observer.h"

#include "NGIAgoraAudioTrack.h"
#include "NGIAgoraLocalUser.h"
#include "NGIAgoraMediaNodeFactory.h"
#include "NGIAgoraMediaNode.h"
#include "NGIAgoraVideoTrack.h"

typedef struct _SinkState
{
  agora::agora_refptr<agora::rtc::IVideoEncodedImageSender> videoEncodedFrameSender;
  agora::base::IAgoraService *service = NULL;
  agora::agora_refptr<agora::rtc::IRtcConnection> connection;
  agora::agora_refptr<agora::rtc::ILocalVideoTrack> customVideoTrack;
  int framerate;

} SinkState;

#include "_generated/sink.h"
