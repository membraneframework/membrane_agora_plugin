#pragma once

#include <atomic>
#include <condition_variable>
#include <mutex>

#include "NGIAgoraLocalUser.h"
#include "NGIAgoraRtcConnection.h"

#include "common.h"

using namespace agora;

class ConnectionObserver : public rtc::IRtcConnectionObserver {
public:
  // ConnectionObserver() : _is_connected(false) {}
  ConnectionObserver(agora_refptr<rtc::IRtcConnection> connection)
      : _is_connected(false), _connection(connection) {}

  void waitUntilConnected();

public: // IRtcConnectionObserver
  void onConnected(const rtc::TConnectionInfo &connectionInfo,
                   rtc::CONNECTION_CHANGED_REASON_TYPE reason);

  void onConnecting(const rtc::TConnectionInfo &connectionInfo,
                    rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onDisconnected(const rtc::TConnectionInfo &connectionInfo,
                      rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onReconnecting(const rtc::TConnectionInfo &connectionInfo,
                      rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onReconnected(const rtc::TConnectionInfo &connectionInfo,
                     rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onConnectionLost(const rtc::TConnectionInfo &connectionInfo) override;
  void onLastmileQuality(const rtc::QUALITY_TYPE quality) override;

  void onTokenPrivilegeWillExpire(const char *token) override;

  void onTokenPrivilegeDidExpire() override;

  void onConnectionFailure(const rtc::TConnectionInfo &connectionInfo,
                           rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void onUserJoined(user_id_t userId) override;

  void onUserLeft(user_id_t userId,
                  rtc::USER_OFFLINE_REASON_TYPE reason) override;

  void onTransportStats(const rtc::RtcStats &stats) override;

  void onLastmileProbeResult(const rtc::LastmileProbeResult &result) override;

  void onChannelMediaRelayStateChanged(int state, int code) override;

private:
  std::atomic<bool> _is_connected;
  std::condition_variable _cv;
  std::mutex _lock;
  agora_refptr<rtc::IRtcConnection> _connection;
};
