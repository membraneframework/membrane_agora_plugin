#pragma once

#include <unifex/unifex.h>
#include <optional>
#include "AgoraBase.h"
#include "NGIAgoraLocalUser.h"

using namespace agora;
using namespace agora::rtc;

class SampleLocalUserObserver : public ILocalUserObserver {
public:
  SampleLocalUserObserver():  _destination(std::nullopt){}
  SampleLocalUserObserver(UnifexPid destination):  _destination(destination) {}
  ~SampleLocalUserObserver() {}
  void onAudioTrackPublishSuccess(
      agora_refptr<ILocalAudioTrack> audioTrack) override;
  void onLocalAudioTrackStatistics(const LocalAudioStats &stats) override;
  void
  onRemoteAudioTrackStatistics(agora_refptr<IRemoteAudioTrack> audioTrack,
                               const RemoteAudioTrackStats &stats) override;
  void onUserAudioTrackSubscribed(
      user_id_t userId, agora_refptr<IRemoteAudioTrack> audioTrack) override;
  void onUserAudioTrackStateChanged(user_id_t userId,
                                    agora_refptr<IRemoteAudioTrack> audioTrack,
                                    REMOTE_AUDIO_STATE state,
                                    REMOTE_AUDIO_STATE_REASON reason,
                                    int elapsed) override;
  void onVideoTrackPublishSuccess(
      agora_refptr<ILocalVideoTrack> videoTrack) override;
  void
  onLocalVideoTrackStateChanged(agora_refptr<ILocalVideoTrack> videoTrack,
                                LOCAL_VIDEO_STREAM_STATE state,
                                LOCAL_VIDEO_STREAM_ERROR errorCode) override;
  void onLocalVideoTrackStatistics(agora_refptr<ILocalVideoTrack> videoTrack,
                                   const LocalVideoTrackStats &stats) override;
  void onUserVideoTrackStateChanged(user_id_t userId,
                                    agora_refptr<IRemoteVideoTrack> videoTrack,
                                    REMOTE_VIDEO_STATE state,
                                    REMOTE_VIDEO_STATE_REASON reason,
                                    int elapsed) override;
  void onFirstRemoteVideoFrameRendered(user_id_t userId, int width, int height,
                                       int elapsed) override;
  void
  onRemoteVideoTrackStatistics(agora_refptr<IRemoteVideoTrack> videoTrack,
                               const RemoteVideoTrackStats &stats) override;
  void onAudioSubscribeStateChanged(const char *channel, user_id_t userId,
                                    STREAM_SUBSCRIBE_STATE oldState,
                                    STREAM_SUBSCRIBE_STATE newState,
                                    int elapseSinceLastState) override;
  void onVideoSubscribeStateChanged(const char *channel, user_id_t userId,
                                    STREAM_SUBSCRIBE_STATE oldState,
                                    STREAM_SUBSCRIBE_STATE newState,
                                    int elapseSinceLastState) override;
  void onAudioPublishStateChanged(const char *channel,
                                  STREAM_PUBLISH_STATE oldState,
                                  STREAM_PUBLISH_STATE newState,
                                  int elapseSinceLastState) override;
  void onVideoPublishStateChanged(const char *channel,
                                  STREAM_PUBLISH_STATE oldState,
                                  STREAM_PUBLISH_STATE newState,
                                  int elapseSinceLastState) override;
  void onFirstRemoteAudioFrame(user_id_t userId, int elapsed) override;
  void onFirstRemoteAudioDecoded(user_id_t userId, int elapsed) override;
  void onFirstRemoteVideoDecoded(user_id_t userId, int width, int height,
                                 int elapsed) override;
  void onAudioTrackPublicationFailure(agora_refptr<ILocalAudioTrack> audioTrack,
                                      ERROR_CODE_TYPE error) override;
  void onVideoTrackPublicationFailure(agora_refptr<ILocalVideoTrack> videoTrack,
                                      ERROR_CODE_TYPE error) override;
  void onAudioVolumeIndication(const AudioVolumeInformation *speakers,
                               unsigned int speakerNumber,
                               int totalVolume) override;
  void onActiveSpeaker(user_id_t userId) override;
  void onVideoSizeChanged(user_id_t userId, int width, int height,
                          int rotation) override;
  void onFirstRemoteVideoFrame(user_id_t userId, int width, int height,
                               int elapsed) override;

  void onUserVideoTrackSubscribed(
      user_id_t userId, VideoTrackInfo trackInfo,
      agora_refptr<IRemoteVideoTrack> videoTrack) override;

  void onVideoTrackUnpublished(agora_refptr<ILocalVideoTrack> videoTrack) override;
  void onVideoTrackPublishStart(agora_refptr<ILocalVideoTrack> videoTrack) override;
  void onAudioTrackUnpublished(agora_refptr<ILocalAudioTrack> audioTrack) override;
  void onAudioTrackPublishStart(agora_refptr<ILocalAudioTrack> audioTrack) override;

  private:
    std::optional<UnifexPid> _destination;
};