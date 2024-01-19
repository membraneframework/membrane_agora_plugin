#include "../_generated/source.h"
#include "sample_video_encoded_frame_observer.h"
#include <unifex/payload.h>
#include <unifex/unifex.h>

bool SampleVideoEncodedFrameObserver::onEncodedVideoFrameReceived(
    uid_t uid, const uint8_t *imageBuffer, size_t length,
    const EncodedVideoFrameInfo &videoEncodedFrameInfo) {
  UnifexEnv *env = unifex_alloc_env(NULL);
  UnifexPayload payload;
  unifex_payload_alloc(env, UNIFEX_PAYLOAD_BINARY, length, &payload);
  memcpy(payload.data, imageBuffer, length);

  send_agora_video_payload(env, _destination, UNIFEX_SEND_THREADED, &payload,
                           uid);

  unifex_payload_release(&payload);
  unifex_free_env(env);
  return true;
}