#pragma once

#include "AgoraBase.h"
#include <unifex/unifex.h>

using namespace agora;
using namespace agora::rtc;

class SampleAudioFrameObserver : public media::IAudioFrameObserverBase {
private:
  UnifexPid _destination;

public:
  SampleAudioFrameObserver(UnifexPid destination) : _destination(destination) {}

  bool onRecordAudioFrame(const char *channelId,
                          AudioFrame &audioFrame) override;
  bool onPlaybackAudioFrame(const char *channelId,
                            AudioFrame &audioFrame) override;
  bool onMixedAudioFrame(const char *channelId,
                         AudioFrame &audioFrame) override;
  bool onEarMonitoringAudioFrame(AudioFrame &audioFrame) override;

  bool onPlaybackAudioFrameBeforeMixing(const char *channelId,
                                        media::base::user_id_t uid,
                                        AudioFrame &audioFrame) override;
};