#pragma once

#include "AgoraBase.h"
#include <unifex/unifex.h>

using namespace agora;
using namespace agora::rtc;

class SampleVideoEncodedFrameObserver
    : public media::IVideoEncodedFrameObserver {
private:
  UnifexPid _destination;

public:
  SampleVideoEncodedFrameObserver(UnifexPid destination)
      : _destination(destination) {}

  bool onEncodedVideoFrameReceived(
      uid_t uid, const uint8_t *imageBuffer, size_t length,
      const EncodedVideoFrameInfo &videoEncodedFrameInfo) override;
};