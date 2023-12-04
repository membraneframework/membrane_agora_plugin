#pragma once

#include "AgoraBase.h"
#include <unifex/unifex.h>

using namespace agora;

class SampleVideoEncodedFrameObserver
    : public media::IVideoEncodedFrameObserver {
private:
  UnifexPid _destination;

public:
  SampleVideoEncodedFrameObserver(UnifexPid destination)
      : _destination(destination) {}

  bool OnEncodedVideoFrame(
      rtc::uid_t uid, const uint8_t *imageBuffer, size_t length,
      const rtc::EncodedVideoFrameInfo &videoEncodedFrameInfo) override;
};