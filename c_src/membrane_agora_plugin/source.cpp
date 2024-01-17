#include "source.h"
#include "source/sample_audio_frame_observer.h"
#include "source/sample_local_user_observer.h"
#include "source/sample_video_encoded_frame_observer.h"

UNIFEX_TERM create(UnifexEnv *env, char *appId, char *token, char *channelId,
                   char *userId, UnifexPid destination) {

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
  ccfg.audioRecvMediaPacket = false;
  ccfg.audioRecvEncodedFrame = false;
  ccfg.clientRoleType = agora::rtc::CLIENT_ROLE_AUDIENCE;
  ccfg.enableAudioRecordingOrPlayout = true;
  state->connection = state->service->createRtcConnection(ccfg);

  state->connObserver =
      std::make_shared<ConnectionObserver>(state->connection, destination);
  state->connection->registerObserver(state->connObserver.get());
  // connecting
  int connection_res = state->connection->connect(token, channelId, userId);
  if (connection_res) {
    AG_LOG(ERROR, "Failed to connect to Agora channel!");
    unifex_release_state(env, state);
    return create_result_error(env, "Failed to connect to Agora channel!");
  }

  state->connObserver->waitUntilConnected();

  agora::rtc::VideoSubscriptionOptions options;
  state->connection->getLocalUser()->subscribeAllVideo(options);
  state->connection->getLocalUser()->subscribeAllAudio();

  state->localUserObserver = std::make_shared<SampleLocalUserObserver>();
  state->videoEncodedFrameObserver =
      std::make_shared<SampleVideoEncodedFrameObserver>(destination);
  state->audioFrameObserver =
      std::make_shared<SampleAudioFrameObserver>(destination);

  state->connection->getLocalUser()->registerLocalUserObserver(
      state->localUserObserver.get());

  state->connection->getLocalUser()->registerVideoEncodedFrameObserver(
      state->videoEncodedFrameObserver.get());

  state->connection->getLocalUser()
      ->setPlaybackAudioFrameBeforeMixingParameters(2, 44100);

  state->connection->getLocalUser()->registerAudioFrameObserver(
      state->audioFrameObserver.get());

  UNIFEX_TERM res = create_result_ok(env, state);
  unifex_release_state(env, state);

  return res;
}

void handle_destroy_state(UnifexEnv *env, SourceState *state) {
  state->connection->unregisterObserver(state->connObserver.get());
  state->connObserver.reset();

  state->connection->getLocalUser()->unregisterLocalUserObserver(
      state->localUserObserver.get());
  state->connection->getLocalUser()->unregisterVideoEncodedFrameObserver(
      state->videoEncodedFrameObserver.get());
  state->connection->getLocalUser()->unregisterAudioFrameObserver(
      state->audioFrameObserver.get());

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