#pragma once

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <optional>

#include <unifex/unifex.h>

#include "NGIAgoraLocalUser.h"
#include "NGIAgoraRtcConnection.h"

#include "common.h"

using namespace agora;
using namespace agora::rtc;

class ConnectionObserver : public IRtcConnectionObserver {
public:
  ConnectionObserver(agora_refptr<IRtcConnection> connection)
      : _is_connected(false), _connection(connection),
        _destination(std::nullopt) {}

  ConnectionObserver(agora_refptr<IRtcConnection> connection,
                     UnifexPid destination)
      : _is_connected(false), _connection(connection),
        _destination(destination) {}

  void waitUntilConnected();

public: // IRtcConnectionObserver
  void onConnected(const TConnectionInfo &connectionInfo,
                   CONNECTION_CHANGED_REASON_TYPE reason);

  void onConnecting(const TConnectionInfo &connectionInfo,
                    CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onDisconnected(const TConnectionInfo &connectionInfo,
                      CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onReconnecting(const TConnectionInfo &connectionInfo,
                      CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onReconnected(const TConnectionInfo &connectionInfo,
                     CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onConnectionLost(const TConnectionInfo &connectionInfo) override;
  void onLastmileQuality(const QUALITY_TYPE quality) override;

  void onTokenPrivilegeWillExpire(const char *token) override;

  void onTokenPrivilegeDidExpire() override;

  void onConnectionFailure(const TConnectionInfo &connectionInfo,
                           CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onUserJoined(user_id_t userId) override;

  void onUserLeft(user_id_t userId, USER_OFFLINE_REASON_TYPE reason) override;

  void onTransportStats(const RtcStats &stats) override;

  void onLastmileProbeResult(const LastmileProbeResult &result) override;

  void onChannelMediaRelayStateChanged(int state, int code) override;
  void onIntraRequestReceived() override;

private:
  std::atomic<bool> _is_connected;
  std::condition_variable _cv;
  std::mutex _lock;
  agora_refptr<IRtcConnection> _connection;
  std::optional<UnifexPid> _destination;
};
