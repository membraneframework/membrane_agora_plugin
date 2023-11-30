#pragma once

#include <csignal>
#include <cstring>
#include <sstream>
#include <string>
#include <thread>
#include <unistd.h>

#include "AgoraBase.h"
#include "IAgoraService.h"
#include "NGIAgoraAudioTrack.h"
#include "NGIAgoraLocalUser.h"
#include "NGIAgoraMediaNode.h"
#include "NGIAgoraMediaNodeFactory.h"
#include "NGIAgoraRtcConnection.h"
#include "NGIAgoraVideoTrack.h"

#include "common.h"
#include "connection_observer.h"

typedef struct {
  // Agora SDK
  agora::base::IAgoraService *service = NULL;
  agora::agora_refptr<agora::rtc::IRtcConnection> connection;
  std::shared_ptr<ConnectionObserver> connObserver;
  std::shared_ptr<agora::rtc::ILocalUserObserver> localUserObserver;
  std::shared_ptr<agora::media::IVideoEncodedFrameObserver> videoEncodedFrameObserver;
  std::shared_ptr<agora::media::IAudioFrameObserver> audioFrameObserver;
} SourceState;

#include "_generated/source.h"
