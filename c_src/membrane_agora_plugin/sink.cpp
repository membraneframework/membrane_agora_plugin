#include "sink.h"
UNIFEX_TERM create(UnifexEnv *env, char *appId, char *token, char *channelId, char *userId)
{
    SinkState *state = unifex_alloc_state(env);

    auto empty_state = SinkState();
    memcpy(state, &empty_state, sizeof(SinkState));

    state->service = createAgoraService();

    auto &service = state->service;

    // Initializes the IAgoraService object
    agora::base::AgoraServiceConfiguration scfg;
    // Sets Agora App ID
    scfg.appId = appId;
    // Enables the audio processing module
    scfg.enableAudioProcessor = false;
    // Disables the audio device module (Normally we do not directly connect audio capture or playback devices to a server)
    scfg.enableAudioDevice = false;
    // Whether to enable video
    scfg.enableVideo = true;
    // Disables user IDs in string format (the character can be digits, letters, or special symbols) so that user ID can only contain digits
    scfg.useStringUid = false;
    if (service->initialize(scfg) != agora::ERR_OK)
    {
        AG_LOG(ERROR, "Failed to initialize service");
    }

    // Creates an IRtcConnection object
    agora::rtc::RtcConnectionConfiguration ccfg;
    ccfg.autoSubscribeAudio = false;
    ccfg.autoSubscribeVideo = false;
    ccfg.clientRoleType = agora::rtc::CLIENT_ROLE_BROADCASTER;
    state->connection = service->createRtcConnection(ccfg);

    auto &connection = state->connection;
    // Calls registerObserver to listen to connection events
    auto connObserver = std::make_shared<SampleConnectionObserver>();
    connection->registerObserver(connObserver.get());

    // Calls connect to connect to an Agora <Vg k="VSDK" /> channel
    int connection_res = connection->connect(token, channelId, userId);
    if (connection_res)
    {
        AG_LOG(ERROR, "Failed to connect to Agora channel!");
    }

    // Creates an IMediaNodeFactory object.
    agora::agora_refptr<agora::rtc::IMediaNodeFactory> factory = service->createMediaNodeFactory();
    if (!factory)
    {
        AG_LOG(ERROR, "Failed to create media node factory!");
    }
    // Creates a sender for encoded video

    // agora::agora_refptr<agora::rtc::IVideoEncodedImageSender> videoEncodedFrameSender =
    state->videoEncodedFrameSender = factory->createVideoEncodedImageSender();
    if (!state->videoEncodedFrameSender)
    {
        AG_LOG(ERROR, "Failed to create encoded video frame sender!");
    }

    agora::rtc::SenderOptions senderOptions;
    // Creates a custom video track that uses an encoded video stream sender
    state->customVideoTrack =
        service->createCustomVideoTrack(state->videoEncodedFrameSender, senderOptions);

    if (!state->customVideoTrack)
    {
        AG_LOG(ERROR, "Failed to create video track!");
    }

    // Enables and publishes video track
    state->customVideoTrack->setEnabled(true);
    connection->getLocalUser()->publishVideo(state->customVideoTrack);

    // Wait until connected before sending media stream
    connObserver->waitUntilConnected(2000);
    connection->unregisterObserver(connObserver.get());
    connObserver.reset();
    UNIFEX_TERM res = create_result_ok(env, state);

    unifex_release_state(env, state);

    return res;
}

UNIFEX_TERM write_data(UnifexEnv *env, UnifexPayload *payload, int isKeyframe,
                       SinkState *state)
{
    AG_LOG(INFO, "write_data START");
    int frameRate = 30;

    agora::rtc::EncodedVideoFrameInfo videoEncodedFrameInfo;
    videoEncodedFrameInfo.rotation = agora::rtc::VIDEO_ORIENTATION_0;
    videoEncodedFrameInfo.codecType = agora::rtc::VIDEO_CODEC_H264;
    videoEncodedFrameInfo.framesPerSecond = frameRate;
    videoEncodedFrameInfo.frameType =
        (isKeyframe ? agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_KEY_FRAME
                    : agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_DELTA_FRAME);

    state->videoEncodedFrameSender->sendEncodedVideoImage(
        reinterpret_cast<uint8_t *>(payload->data), payload->size,
        videoEncodedFrameInfo);
    auto res = write_data_result_ok(env);
    AG_LOG(INFO, "write_data END");
    return res;
}

void handle_destroy_state(UnifexEnv *env, SinkState *state)
{
    AG_LOG(INFO, "handle_destroy_state START");
    state->connection->getLocalUser()->unpublishVideo(state->customVideoTrack);
    if (state->connection->disconnect())
    {
        AG_LOG(ERROR, "Failed to disconnect from Agora channel!");
        return;
    }
    AG_LOG(INFO, "Disconnected from Agora channel successfully");
    state->connection = nullptr;
    state->service->release();
    state->service = nullptr;
    AG_LOG(INFO, "handle_destroy_state END");
}