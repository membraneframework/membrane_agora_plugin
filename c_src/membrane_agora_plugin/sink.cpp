#include "sink.h"

UNIFEX_TERM create(UnifexEnv *env, char *appId, char *token, char *channelId, char *userId)
{
    SinkState *state = unifex_alloc_state(env);
    auto empty_state = SinkState();
    memcpy(state, &empty_state, sizeof(SinkState));

    state->service = createAgoraService();

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
    if (state->service->initialize(scfg) != agora::ERR_OK)
    {
        AG_LOG(ERROR, "Failed to initialize service");
        unifex_release_state(env, state);
        return create_result_error(env, "Failed to initialize service");
    }

    // Creates an IRtcConnection object
    agora::rtc::RtcConnectionConfiguration ccfg;
    ccfg.autoSubscribeAudio = false;
    ccfg.autoSubscribeVideo = false;
    ccfg.clientRoleType = agora::rtc::CLIENT_ROLE_BROADCASTER;
    state->connection = state->service->createRtcConnection(ccfg);

    // Calls registerObserver to listen to connection events
    auto connObserver = std::make_shared<SampleConnectionObserver>();
    state->connection->registerObserver(connObserver.get());

    // Calls connect to connect to an Agora <Vg k="VSDK" /> channel
    int connection_res = state->connection->connect(token, channelId, userId);
    if (connection_res)
    {
        AG_LOG(ERROR, "Failed to connect to Agora channel!");
        unifex_release_state(env, state);
        return create_result_error(env, "Failed to connect to Agora channel!");
    }

    // Creates an IMediaNodeFactory object.
    agora::agora_refptr<agora::rtc::IMediaNodeFactory> factory = state->service->createMediaNodeFactory();
    if (!factory)
    {
        AG_LOG(ERROR, "Failed to create media node factory!");
        unifex_release_state(env, state);
        return create_result_error(env, "Failed to create media node factory!");
    }

    // Creates a sender for encoded video
    state->videoEncodedFrameSender = factory->createVideoEncodedImageSender();
    if (!state->videoEncodedFrameSender)
    {
        AG_LOG(ERROR, "Failed to create encoded video frame sender!");
        unifex_release_state(env, state);
        return create_result_error(env, "Failed to create encoded video frame sender!");
    }

    agora::rtc::SenderOptions senderOptions;
    // Creates a custom video track that uses an encoded video stream sender
    state->customVideoTrack =
        state->service->createCustomVideoTrack(state->videoEncodedFrameSender, senderOptions);

    if (!state->customVideoTrack)
    {
        AG_LOG(ERROR, "Failed to create video track!");
        unifex_release_state(env, state);
        return create_result_error(env, "Failed to create video track!");
    }

    // Enables and publishes video track
    state->customVideoTrack->setEnabled(true);
    state->connection->getLocalUser()->publishVideo(state->customVideoTrack);

    // Wait until connected before sending media stream
    connObserver->waitUntilConnected(3000);
    state->connection->unregisterObserver(connObserver.get());
    connObserver.reset();
    UNIFEX_TERM res = create_result_ok(env, state);

    unifex_release_state(env, state);

    return res;
}

UNIFEX_TERM update_stream_format(UnifexEnv *env, int height, int width, int framesPerSecond, SinkState *state)
{
    state->height = height;
    state->width = width;
    state->framesPerSecond = framesPerSecond;
    return update_stream_format_result_ok(env, state);
}

UNIFEX_TERM write_data(UnifexEnv *env, UnifexPayload *payload, int isKeyframe, int pts, int dts,
                       SinkState *state)
{
    AG_LOG(INFO, "write_data START %d %d", isKeyframe, payload->size);

    agora::rtc::EncodedVideoFrameInfo videoEncodedFrameInfo;

    videoEncodedFrameInfo.width = state->width;
    videoEncodedFrameInfo.height = state->height;
    videoEncodedFrameInfo.framesPerSecond = state->framesPerSecond;

    videoEncodedFrameInfo.rotation = agora::rtc::VIDEO_ORIENTATION_0;
    videoEncodedFrameInfo.codecType = agora::rtc::VIDEO_CODEC_H264;

    videoEncodedFrameInfo.decodeTimeMs = dts;
    videoEncodedFrameInfo.captureTimeMs = pts;
    videoEncodedFrameInfo.frameType =
        (isKeyframe ? agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_KEY_FRAME
                    : agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_DELTA_FRAME);

    if (state->videoEncodedFrameSender->sendEncodedVideoImage(
            reinterpret_cast<uint8_t *>(payload->data), payload->size,
            videoEncodedFrameInfo) != true)
    {
        AG_LOG(ERROR, "Couldn't send frame");
        return write_data_result_error(env, "Couldn't send frame");
    }

    return write_data_result_ok(env);
}

void handle_destroy_state(UnifexEnv *env, SinkState *state)
{
    if (state->connection)
    {
        if (state->customVideoTrack)
        {
            state->connection->getLocalUser()->unpublishVideo(state->customVideoTrack);
            state->customVideoTrack = NULL;
        }

        if (state->connection->disconnect())
        {
            AG_LOG(ERROR, "Failed to disconnect from Agora channel!");
            return;
        }
        AG_LOG(INFO, "Disconnected from Agora channel successfully");
        state->connection = NULL;
    }

    if (state->service)
    {
        state->service->release();
        AG_LOG(INFO, "Agora service released successfully");
        state->service = NULL;
    }
}