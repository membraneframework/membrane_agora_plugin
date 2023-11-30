#include "source.h"

using namespace agora;
using namespace agora::rtc;


class SampleVideoEncodedFrameObserver : public agora::media::IVideoEncodedFrameObserver {
private:
  UnifexPid _destination;
public:
  SampleVideoEncodedFrameObserver(UnifexPid destination): _destination(destination){}

  bool OnEncodedVideoFrame(rtc::uid_t uid, const uint8_t * 	imageBuffer, size_t length, const rtc::EncodedVideoFrameInfo & 	videoEncodedFrameInfo)
  {
    printf("ENCODED VIDEO FRAME RECEIVED %d \n", uid);
    UnifexEnv *env = unifex_alloc_env(NULL);
    UnifexPayload payload;
    unifex_payload_alloc(env, UNIFEX_PAYLOAD_BINARY, length, &payload);
    memcpy(payload.data, imageBuffer, length);

    send_agora_video_payload(env, _destination, UNIFEX_SEND_THREADED, &payload);

    unifex_payload_release(&payload);
    unifex_free_env(env);
    return true;
  }	
};

class SampleAudioFrameObserver : public agora::media::IAudioFrameObserver {
private:
  UnifexPid _destination;
public:
  SampleAudioFrameObserver(UnifexPid destination): _destination(destination){}

  bool onRecordAudioFrame(const char* channelId, AudioFrame& audioFrame){return true;}
  bool onPlaybackAudioFrame(const char* channelId, AudioFrame& audioFrame){return true;}
  bool onMixedAudioFrame(const char* channelId, AudioFrame& audioFrame){return true;}
  bool onEarMonitoringAudioFrame(AudioFrame& audioFrame){return true;}

  bool onPlaybackAudioFrameBeforeMixing(const char* channelId, rtc::uid_t uid, AudioFrame& audioFrame) override
  {
    printf("ENCODED AUDIO FRAME RECEIVED %d \n", uid);
    
    UnifexEnv *env = unifex_alloc_env(NULL);
    UnifexPayload payload;
    unsigned int size = audioFrame.samplesPerChannel*audioFrame.bytesPerSample*audioFrame.channels;
    unifex_payload_alloc(env, UNIFEX_PAYLOAD_BINARY, size, &payload);
    memcpy(payload.data, audioFrame.buffer, size);

    auto res = send_agora_audio_payload(env, _destination, UNIFEX_SEND_THREADED, &payload);
    unifex_payload_release(&payload);
    unifex_free_env(env);
    return true;
  }	
};

class H264FrameReceiver : public agora::rtc::IVideoEncodedImageReceiver {
private:
  UnifexPid _destination;
public:
  H264FrameReceiver(UnifexPid destination): _destination(destination){}

  bool OnEncodedVideoImageReceived(
      const uint8_t *imageBuffer, size_t length,
      const agora::rtc::EncodedVideoFrameInfo &videoEncodedFrameInfo) override {
        return true;
      }
};

class SampleLocalUserObserver : public agora::rtc::ILocalUserObserver {
   private:
    std::shared_ptr<IVideoEncodedImageReceiver> receiver;
   
   public:
    SampleLocalUserObserver(UnifexPid destination) {
        receiver = std::make_shared<H264FrameReceiver>(destination);
    }
    ~SampleLocalUserObserver () {
        receiver.reset();
    }
    void onAudioTrackPublishSuccess (agora_refptr< ILocalAudioTrack > audioTrack){}
    void onLocalAudioTrackStateChanged (agora_refptr< rtc::ILocalAudioTrack > audioTrack, LOCAL_AUDIO_STREAM_STATE state, LOCAL_AUDIO_STREAM_ERROR errorCode) {}
    void onLocalAudioTrackStatistics (const LocalAudioStats &stats){}
    void onRemoteAudioTrackStatistics (agora_refptr< rtc::IRemoteAudioTrack > audioTrack, const RemoteAudioTrackStats &stats){}
    void onUserAudioTrackSubscribed (user_id_t userId, agora_refptr< rtc::IRemoteAudioTrack > audioTrack){}
    void onUserAudioTrackStateChanged (user_id_t userId, agora_refptr< rtc::IRemoteAudioTrack > audioTrack, REMOTE_AUDIO_STATE state, REMOTE_AUDIO_STATE_REASON reason, int elapsed){}
    void onVideoTrackPublishSuccess (agora_refptr< ILocalVideoTrack > videoTrack){}
    void onLocalVideoTrackStateChanged (agora_refptr< rtc::ILocalVideoTrack > videoTrack, LOCAL_VIDEO_STREAM_STATE state, LOCAL_VIDEO_STREAM_ERROR errorCode){}
    void onLocalVideoTrackStatistics (agora_refptr< rtc::ILocalVideoTrack > videoTrack, const LocalVideoTrackStats &stats){}
    void onUserVideoTrackStateChanged (user_id_t userId, agora_refptr< rtc::IRemoteVideoTrack > videoTrack, REMOTE_VIDEO_STATE state, REMOTE_VIDEO_STATE_REASON reason, int elapsed){}
    void onFirstRemoteVideoFrameRendered (user_id_t userId, int width, int height, int elapsed){}
    void onRemoteVideoTrackStatistics (agora_refptr< rtc::IRemoteVideoTrack > videoTrack, const RemoteVideoTrackStats &stats){}
    void onAudioSubscribeStateChanged (const char *channel, user_id_t userId, STREAM_SUBSCRIBE_STATE oldState, STREAM_SUBSCRIBE_STATE newState, int elapseSinceLastState){}
    void onVideoSubscribeStateChanged (const char *channel, user_id_t userId, STREAM_SUBSCRIBE_STATE oldState, STREAM_SUBSCRIBE_STATE newState, int elapseSinceLastState){}
    void onAudioPublishStateChanged (const char *channel, STREAM_PUBLISH_STATE oldState, STREAM_PUBLISH_STATE newState, int elapseSinceLastState){}
    void onVideoPublishStateChanged (const char *channel, STREAM_PUBLISH_STATE oldState, STREAM_PUBLISH_STATE newState, int elapseSinceLastState){}
    void onFirstRemoteAudioFrame (user_id_t userId, int elapsed){}
    void onFirstRemoteAudioDecoded (user_id_t userId, int elapsed){}
    void onFirstRemoteVideoDecoded (user_id_t userId, int width, int height, int elapsed){}
    void onAudioTrackPublicationFailure(agora_refptr<ILocalAudioTrack> audioTrack, ERROR_CODE_TYPE error){}
    void onVideoTrackPublicationFailure(agora_refptr<ILocalVideoTrack> videoTrack, ERROR_CODE_TYPE error){}
    void onAudioVolumeIndication(const AudioVolumeInformation* speakers, unsigned int speakerNumber, int totalVolume){}
    void onActiveSpeaker(user_id_t userId){}
    void onVideoSizeChanged(user_id_t userId, int width, int height, int rotation){}
    void onFirstRemoteVideoFrame(user_id_t userId, int width, int height, int elapsed){}
    
    void onUserVideoTrackSubscribed(agora::user_id_t userId, agora::rtc::VideoTrackInfo trackInfo, agora::agora_refptr<agora::rtc::IRemoteVideoTrack> videoTrack){
        videoTrack->registerVideoEncodedImageReceiver(receiver.get());
    }
};

UNIFEX_TERM create(UnifexEnv *env, char *appId, char *token, char *channelId, char *userId,
       UnifexPid destination) {

  // source's state native state initialization
  SourceState *state = unifex_alloc_state(env);
  auto empty_state = SourceState();
  memcpy((void *)state, (void *)&empty_state, sizeof(SourceState));
  // service creation and initialization
  state->service = createAgoraService();
  agora::base::AgoraServiceConfiguration scfg;
  scfg.appId = appId;
  scfg.enableAudioProcessor = true;
  scfg.enableAudioDevice = false;
  scfg.enableVideo = true;
  scfg.useStringUid = false;
  if (state->service->initialize(scfg) != agora::ERR_OK) {
    AG_LOG(ERROR, "Failed to initialize service");
    unifex_release_state(env, state);
    return create_result_error(env, "Failed to initialize service");
  }
  // connection configuration
  agora::rtc::RtcConnectionConfiguration ccfg;
  ccfg.autoSubscribeAudio = true;
  ccfg.autoSubscribeVideo = true;
  ccfg.clientRoleType = agora::rtc::CLIENT_ROLE_BROADCASTER;
  state->connection = state->service->createRtcConnection(ccfg);
  // connecting
  state->connObserver = std::make_shared<ConnectionObserver>(state->connection);
  state->connection->registerObserver(state->connObserver.get());
  
  int connection_res = state->connection->connect(token, channelId, userId);
  if (connection_res) {
    AG_LOG(ERROR, "Failed to connect to Agora channel!");
    unifex_release_state(env, state);
    return create_result_error(env, "Failed to connect to Agora channel!");
  }
  state->connObserver->waitUntilConnected();
  printf("Connected to AGORA channel\n");  
  agora::rtc::VideoSubscriptionOptions options;
  state->connection->getLocalUser()->subscribeAllVideo(options);
  state->connection->getLocalUser()->subscribeAllAudio();

  state->localUserObserver = std::make_shared<SampleLocalUserObserver>(destination);
  state->videoEncodedFrameObserver = std::make_shared<SampleVideoEncodedFrameObserver>(destination);
  state->audioFrameObserver = std::make_shared<SampleAudioFrameObserver>(destination);

  state->connection->getLocalUser()->registerLocalUserObserver(state->localUserObserver.get());
  state->connection->getLocalUser()->registerVideoEncodedFrameObserver(state->videoEncodedFrameObserver.get());
  state->connection->getLocalUser()->registerAudioFrameObserver(state->audioFrameObserver.get());

  UNIFEX_TERM res = create_result_ok(env, state);
  unifex_release_state(env, state);

  return res;
}

void handle_destroy_state(UnifexEnv *env, SourceState *state) {
  printf("AGORA: handle_destroy_state");

  state->connection->unregisterObserver(state->connObserver.get());
  state->connObserver.reset(); 

  state->connection->getLocalUser()->unregisterLocalUserObserver(state->localUserObserver.get());
  state->connection->getLocalUser()->unregisterVideoEncodedFrameObserver(state->videoEncodedFrameObserver.get());
  state->connection->getLocalUser()->unregisterAudioFrameObserver(state->audioFrameObserver.get());
  state->localUserObserver.reset();
  state->videoEncodedFrameObserver.reset();
  state->audioFrameObserver.reset();

  UNUSED(env);
  if (state->connection) {
    if (state->connection->disconnect()) {
      AG_LOG(ERROR, "Failed to disconnect from Agora channel!");
      return;
    }
    AG_LOG(INFO, "Disconnected from Agora channel successfully");
    state->connection = NULL;
  }

  if (state->service) {
    state->service->release();
    AG_LOG(INFO, "Agora service released successfully");
    state->service = NULL;
  }

  
}