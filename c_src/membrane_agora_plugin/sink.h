#pragma once

#include <csignal>
#include <cstring>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>
#include <unistd.h>

#include "IAgoraService.h"
#include "NGIAgoraRtcConnection.h"

#include "log.h"
#include "sample_connection_observer.h"

#include "NGIAgoraAudioTrack.h"
#include "NGIAgoraLocalUser.h"
#include "NGIAgoraMediaNode.h"
#include "NGIAgoraMediaNodeFactory.h"
#include "NGIAgoraVideoTrack.h"

typedef struct _SinkState {
  agora::agora_refptr<agora::rtc::IVideoEncodedImageSender>
      videoEncodedFrameSender;
  agora::agora_refptr<agora::rtc::IAudioEncodedFrameSender> audioFrameSender;
  agora::base::IAgoraService *service = NULL;
  agora::agora_refptr<agora::rtc::IRtcConnection> connection;
  agora::agora_refptr<agora::rtc::ILocalVideoTrack> customVideoTrack;
  agora::agora_refptr<agora::rtc::ILocalAudioTrack> customAudioTrack;
  int framesPerSecond;
  int width;
  int height;

} SinkState;

#include "_generated/sink.h"
