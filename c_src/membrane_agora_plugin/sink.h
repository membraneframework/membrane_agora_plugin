#pragma once

#include <csignal>
#include <cstring>
#include <sstream>
#include <string>
#include <thread>
#include <unistd.h>

#include "IAgoraService.h"
#include "NGIAgoraAudioTrack.h"
#include "NGIAgoraLocalUser.h"
#include "NGIAgoraMediaNode.h"
#include "NGIAgoraMediaNodeFactory.h"
#include "NGIAgoraRtcConnection.h"
#include "NGIAgoraVideoTrack.h"

#include "connection_observer.h"
#include "log.h"

typedef struct _SinkState {
  // Agora SDK
  agora::base::IAgoraService *service = NULL;
  agora::agora_refptr<agora::rtc::IRtcConnection> connection;
  agora::agora_refptr<agora::rtc::IVideoEncodedImageSender>
      videoEncodedFrameSender;
  agora::agora_refptr<agora::rtc::IAudioEncodedFrameSender>
      audioEncodedFrameSender;
  agora::agora_refptr<agora::rtc::ILocalVideoTrack> customVideoTrack;
  agora::agora_refptr<agora::rtc::ILocalAudioTrack> customAudioTrack;

  // video track parameters
  unsigned int width;
  unsigned int height;

  // audio track parameters
  unsigned int sampleRate;
  unsigned int numberOfChannels;
  unsigned int samplesPerChannelPerFrame;
} SinkState;

#include "_generated/sink.h"
