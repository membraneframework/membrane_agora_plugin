#pragma once

#include <csignal>
#include <cstring>
#include <sstream>
#include <string>
#include <thread>
#include <unistd.h>

#include "AgoraBase.h"
#include "IAgoraService.h"
#include "NGIAgoraLocalUser.h"
#include "NGIAgoraRtcConnection.h"

#include "connection_observer.h"

typedef struct {
  agora::base::IAgoraService *service = NULL;
  agora::agora_refptr<agora::rtc::IRtcConnection> connection;
  std::shared_ptr<ConnectionObserver> connObserver;
  std::shared_ptr<agora::media::IVideoEncodedFrameObserver>
      videoEncodedFrameObserver;
  std::shared_ptr<agora::media::IAudioFrameObserverBase> audioFrameObserver;
} SourceState;

#include "_generated/source.h"
