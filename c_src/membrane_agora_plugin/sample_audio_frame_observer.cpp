#include "_generated/source.h"
#include "sample_audio_frame_observer.h"
#include "source.h"
#include <unifex/payload.h>

bool SampleAudioFrameObserver::onRecordAudioFrame(const char *channelId,
                                                  AudioFrame &audioFrame) {
  printf("frame1");
  return true;
}
bool SampleAudioFrameObserver::onPlaybackAudioFrame(const char *channelId,
                                                    AudioFrame &audioFrame) {
  printf("frame2");
  return true;
}
bool SampleAudioFrameObserver::onMixedAudioFrame(const char *channelId,
                                                 AudioFrame &audioFrame) {
  printf("frame3");
  return true;
}
bool SampleAudioFrameObserver::onEarMonitoringAudioFrame(
    AudioFrame &audioFrame) {
  printf("frame4");
  return true;
}

bool SampleAudioFrameObserver::onPlaybackAudioFrameBeforeMixing(
    const char *channelId, rtc::uid_t uid, AudioFrame &audioFrame) {
  printf("ENCODED AUDIO FRAME RECEIVED %d \n", uid);

  UnifexEnv *env = unifex_alloc_env(NULL);
  UnifexPayload payload;
  unsigned int size = audioFrame.samplesPerChannel * audioFrame.bytesPerSample *
                      audioFrame.channels;
  unifex_payload_alloc(env, UNIFEX_PAYLOAD_BINARY, size, &payload);
  memcpy(payload.data, audioFrame.buffer, size);

  auto res = send_agora_audio_payload(env, _destination, UNIFEX_SEND_THREADED,
                                      &payload, uid);
  unifex_payload_release(&payload);
  unifex_free_env(env);
  return true;
}