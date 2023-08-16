#include "sink.h"
UNIFEX_TERM create(UnifexEnv *env, char *_appId, char *_token, char *_channelId)
{
    SinkState *state = unifex_alloc_state(env);
    std::string appId = "18d3bcdafc734c9280b8b6e504b25fc8";
    std::string channelId = "test_channel";
    std::string token = "007eJxTYDh9ao1A3PSPMxJ3fjJWMefc1Woqkmzw4bRRqzHv16wo+SkKDIYWKcZJySmJacnmxibJlkYWBkkWSWappgYmSUamackWVg9upjQEMjK0/TnCwsgAgSA+D0NJanFJfHJGYl5eag4DAwBbUiNa";
    std::string userId = "0";

    auto empty_state = SinkState();
    memcpy(state, &empty_state, sizeof(SinkState));
    // state->connection.ptr_ = NULL;
    // state->videoEncodedFrameSender.ptr_ = NULL;
    state->service = createAgoraService();

    auto &service = state->service;

    // Initializes the IAgoraService object
    agora::base::AgoraServiceConfiguration scfg;
    // Sets Agora App ID
    scfg.appId = appId.c_str();
    //   Enables the audio processing module
    scfg.enableAudioProcessor = false;
    // Disables the audio device module (Normally we do not directly connect audio capture or playback devices to a server)
    scfg.enableAudioDevice = false;
    // Whether to enable video
    scfg.enableVideo = true;
    // Disables user IDs in string format (the character can be digits, letters, or special symbols) so that user ID can only contain digits
    scfg.useStringUid = false;
    if (service->initialize(scfg) != agora::ERR_OK)
    {
        return -1;
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
    int connection_res = connection->connect(token.c_str(), channelId.c_str(), userId.c_str());
    if (connection_res)
    {
        AG_LOG(ERROR, "Failed to connect to Agora channel!");
        return -1;
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
        return -1;
    }

    agora::rtc::SenderOptions senderOptions;
    // Creates a custom video track that uses an encoded video stream sender
    agora::agora_refptr<agora::rtc::ILocalVideoTrack> customVideoTrack =
        service->createCustomVideoTrack(state->videoEncodedFrameSender, senderOptions);

    if (!customVideoTrack)
    {
        AG_LOG(ERROR, "Failed to create video track!");
        return -1;
    }

    // Enables and publishes video track
    customVideoTrack->setEnabled(true);
    connection->getLocalUser()->publishVideo(customVideoTrack);

    // Wait until connected before sending media stream
    connObserver->waitUntilConnected(1000);

    UNIFEX_TERM res;
    res = create_result_ok(env, state);

    unifex_release_state(env, state);

    return res;
}

UNIFEX_TERM write_data(UnifexEnv *env, UnifexPayload *payload, int isKeyframe,
                       SinkState *state)
{
    std::cout << "XD" << std::endl;
    // bool isKeyframe = true;
    int frameRate = 30;
    agora::rtc::EncodedVideoFrameInfo videoEncodedFrameInfo;
    videoEncodedFrameInfo.rotation = agora::rtc::VIDEO_ORIENTATION_0;
    videoEncodedFrameInfo.codecType = agora::rtc::VIDEO_CODEC_H264;
    videoEncodedFrameInfo.framesPerSecond = 30;
    videoEncodedFrameInfo.frameType =
        (isKeyframe ? agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_KEY_FRAME
                    : agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_DELTA_FRAME);

    std::cout << "BEFORE " << payload->size << std::endl;
    state->videoEncodedFrameSender->sendEncodedVideoImage(
        reinterpret_cast<uint8_t *>(payload->data), payload->size,
        videoEncodedFrameInfo);
    std::cout << "AFTER" << std::endl;

    return write_data_result_ok(env);
}

void handle_destroy_state(UnifexEnv *env, SinkState *state)
{
    std::cout << "handle destroy" << std::endl;
    if (state->connection->disconnect())
    {
        AG_LOG(ERROR, "Failed to disconnect from Agora channel!");
        return;
    }
    AG_LOG(INFO, "Disconnected from Agora channel successfully");
    state->connection = nullptr;
    state->service->release();
    state->service = nullptr;
}