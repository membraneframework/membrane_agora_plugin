#include "sample_local_user_observer.h"

void SampleLocalUserObserver::onAudioTrackPublishSuccess(
    agora_refptr<ILocalAudioTrack> audioTrack) {}
void SampleLocalUserObserver::onLocalAudioTrackStateChanged(
    agora_refptr<ILocalAudioTrack> audioTrack, LOCAL_AUDIO_STREAM_STATE state,
    LOCAL_AUDIO_STREAM_ERROR errorCode) {}
void SampleLocalUserObserver::onLocalAudioTrackStatistics(
    const LocalAudioStats &stats) {}
void SampleLocalUserObserver::onRemoteAudioTrackStatistics(
    agora_refptr<IRemoteAudioTrack> audioTrack,
    const RemoteAudioTrackStats &stats) {}
void SampleLocalUserObserver::onUserAudioTrackSubscribed(
    user_id_t userId, agora_refptr<IRemoteAudioTrack> audioTrack) {}
void SampleLocalUserObserver::onUserAudioTrackStateChanged(
    user_id_t userId, agora_refptr<IRemoteAudioTrack> audioTrack,
    REMOTE_AUDIO_STATE state, REMOTE_AUDIO_STATE_REASON reason, int elapsed) {}
void SampleLocalUserObserver::onVideoTrackPublishSuccess(
    agora_refptr<ILocalVideoTrack> videoTrack) {}
void SampleLocalUserObserver::onLocalVideoTrackStateChanged(
    agora_refptr<ILocalVideoTrack> videoTrack, LOCAL_VIDEO_STREAM_STATE state,
    LOCAL_VIDEO_STREAM_ERROR errorCode) {}
void SampleLocalUserObserver::onLocalVideoTrackStatistics(
    agora_refptr<ILocalVideoTrack> videoTrack,
    const LocalVideoTrackStats &stats) {}
void SampleLocalUserObserver::onUserVideoTrackStateChanged(
    user_id_t userId, agora_refptr<IRemoteVideoTrack> videoTrack,
    REMOTE_VIDEO_STATE state, REMOTE_VIDEO_STATE_REASON reason, int elapsed) {}
void SampleLocalUserObserver::onFirstRemoteVideoFrameRendered(user_id_t userId,
                                                              int width,
                                                              int height,
                                                              int elapsed) {}
void SampleLocalUserObserver::onRemoteVideoTrackStatistics(
    agora_refptr<IRemoteVideoTrack> videoTrack,
    const RemoteVideoTrackStats &stats) {}
void SampleLocalUserObserver::onAudioSubscribeStateChanged(
    const char *channel, user_id_t userId, STREAM_SUBSCRIBE_STATE oldState,
    STREAM_SUBSCRIBE_STATE newState, int elapseSinceLastState) {}
void SampleLocalUserObserver::onVideoSubscribeStateChanged(
    const char *channel, user_id_t userId, STREAM_SUBSCRIBE_STATE oldState,
    STREAM_SUBSCRIBE_STATE newState, int elapseSinceLastState) {}
void SampleLocalUserObserver::onAudioPublishStateChanged(
    const char *channel, STREAM_PUBLISH_STATE oldState,
    STREAM_PUBLISH_STATE newState, int elapseSinceLastState) {}
void SampleLocalUserObserver::onVideoPublishStateChanged(
    const char *channel, STREAM_PUBLISH_STATE oldState,
    STREAM_PUBLISH_STATE newState, int elapseSinceLastState) {}
void SampleLocalUserObserver::onFirstRemoteAudioFrame(user_id_t userId,
                                                      int elapsed) {}
void SampleLocalUserObserver::onFirstRemoteAudioDecoded(user_id_t userId,
                                                        int elapsed) {}
void SampleLocalUserObserver::onFirstRemoteVideoDecoded(user_id_t userId,
                                                        int width, int height,
                                                        int elapsed) {}
void SampleLocalUserObserver::onAudioTrackPublicationFailure(
    agora_refptr<ILocalAudioTrack> audioTrack, ERROR_CODE_TYPE error) {}
void SampleLocalUserObserver::onVideoTrackPublicationFailure(
    agora_refptr<ILocalVideoTrack> videoTrack, ERROR_CODE_TYPE error) {}
void SampleLocalUserObserver::onAudioVolumeIndication(
    const AudioVolumeInformation *speakers, unsigned int speakerNumber,
    int totalVolume) {}
void SampleLocalUserObserver::onActiveSpeaker(user_id_t userId) {}
void SampleLocalUserObserver::onVideoSizeChanged(user_id_t userId, int width,
                                                 int height, int rotation) {}
void SampleLocalUserObserver::onFirstRemoteVideoFrame(user_id_t userId,
                                                      int width, int height,
                                                      int elapsed) {}

void SampleLocalUserObserver::onUserVideoTrackSubscribed(
    user_id_t userId, VideoTrackInfo trackInfo,
    agora_refptr<IRemoteVideoTrack> videoTrack) {}
