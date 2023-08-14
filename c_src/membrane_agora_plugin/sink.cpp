#include "sink.h"
UNIFEX_TERM create(UnifexEnv *env, char *appId, char *token, char *channelId)
{
    std::string userId = "someuser";
    auto service = createAgoraService();
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
        return -1;
    }

    // Creates an IRtcConnection object
    agora::rtc::RtcConnectionConfiguration ccfg;
    ccfg.autoSubscribeAudio = false;
    ccfg.autoSubscribeVideo = false;
    ccfg.clientRoleType = agora::rtc::CLIENT_ROLE_BROADCASTER;
    agora::agora_refptr<agora::rtc::IRtcConnection> connection = service->createRtcConnection(ccfg);

    // Calls registerObserver to listen to connection events
    // auto connObserver = std::make_shared<SampleConnectionObserver>();
    // connection->registerObserver(connObserver.get());

    // Calls connect to connect to an Agora <Vg k="VSDK" /> channel
    if (connection->connect(appId, channelId, userId.c_str()))
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
    agora::agora_refptr<agora::rtc::IVideoEncodedImageSender> videoEncodedFrameSender =
        factory->createVideoEncodedImageSender();

    if (!videoEncodedFrameSender)
    {
        AG_LOG(ERROR, "Failed to create encoded video frame sender!");
        return -1;
    }

    agora::rtc::SenderOptions senderOptions;
    // Creates a custom video track that uses an encoded video stream sender
    agora::agora_refptr<agora::rtc::ILocalVideoTrack> customVideoTrack =
        service->createCustomVideoTrack(videoEncodedFrameSender, senderOptions);

    if (!customVideoTrack)
    {
        AG_LOG(ERROR, "Failed to create video track!");
        return -1;
    }

    // Enables and publishes video track
    customVideoTrack->setEnabled(true);
    connection->getLocalUser()->publishVideo(customVideoTrack);

    SinkState *state = unifex_alloc_state(env);
    state->videoEncodedFrameSender = videoEncodedFrameSender;

    UNIFEX_TERM res;
    res =
        create_result_ok(env, state);

    if (state)
    {
        unifex_release_state(env, state);
    }
    return res;
}

UNIFEX_TERM write_data(UnifexEnv *env, UnifexPayload *payload, bool isKeyframe,
                       SinkState *state)
{
    int frameRate = 30;
    agora::rtc::EncodedVideoFrameInfo videoEncodedFrameInfo;
    videoEncodedFrameInfo.rotation = agora::rtc::VIDEO_ORIENTATION_0;
    videoEncodedFrameInfo.codecType = agora::rtc::VIDEO_CODEC_H264;
    videoEncodedFrameInfo.framesPerSecond = 30;
    videoEncodedFrameInfo.frameType =
        (isKeyframe ? agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_KEY_FRAME
                    : agora::rtc::VIDEO_FRAME_TYPE::VIDEO_FRAME_TYPE_DELTA_FRAME);

    state->videoEncodedFrameSender->sendEncodedVideoImage(
        reinterpret_cast<uint8_t *>(payload->data), payload->size,
        videoEncodedFrameInfo);

    return write_data_result_ok(env);
}