#pragma once

#include <csignal>
#include <cstring>
#include <sstream>
#include <string>
#include <thread>
#include <unistd.h>

#include "IAgoraService.h"
#include "NGIAgoraRtcConnection.h"

#include "connection_observer.h"
#include "log.h"

#include "NGIAgoraAudioTrack.h"
#include "NGIAgoraLocalUser.h"
#include "NGIAgoraMediaNode.h"
#include "NGIAgoraMediaNodeFactory.h"
#include "NGIAgoraVideoTrack.h"

typedef struct _SinkState {
  // Agora SDK handlers
  agora::base::IAgoraService *service = NULL;
  agora::agora_refptr<agora::rtc::IRtcConnection> connection;
  agora::agora_refptr<agora::rtc::IVideoEncodedImageSender>
      videoEncodedFrameSender;
  agora::agora_refptr<agora::rtc::IAudioEncodedFrameSender>
      audioEncodedFrameSender;
  agora::agora_refptr<agora::rtc::ILocalVideoTrack> customVideoTrack;
  agora::agora_refptr<agora::rtc::ILocalAudioTrack> customAudioTrack;

  // video track parameters
  int width;
  int height;

  // audio track parameters
  int sampleRate;
  int numberOfChannels;
  int samplesPerChannelPerFrame;
} SinkState;

#include "_generated/sink.h"
