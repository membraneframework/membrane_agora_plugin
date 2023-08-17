#pragma once

#include <atomic>
#include <condition_variable>
#include <mutex>

#include "NGIAgoraRtcConnection.h"

#include "log.h"

class ConnectionObserver : public agora::rtc::IRtcConnectionObserver {
public:
  ConnectionObserver() : _is_connected(false) {}

  void waitUntilConnected();

public: // IRtcConnectionObserver
  void onConnected(const agora::rtc::TConnectionInfo &connectionInfo,
                   agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void
  onConnecting(const agora::rtc::TConnectionInfo &connectionInfo,
               agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {}

  void
  onDisconnected(const agora::rtc::TConnectionInfo &connectionInfo,
                 agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {}

  void
  onReconnecting(const agora::rtc::TConnectionInfo &connectionInfo,
                 agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {}

  void
  onReconnected(const agora::rtc::TConnectionInfo &connectionInfo,
                agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {}

  void
  onConnectionLost(const agora::rtc::TConnectionInfo &connectionInfo) override {
  }

  void onLastmileQuality(const agora::rtc::QUALITY_TYPE quality) override {}

  void onTokenPrivilegeWillExpire(const char *token) override {}

  void onTokenPrivilegeDidExpire() override {}

  void onConnectionFailure(
      const agora::rtc::TConnectionInfo &connectionInfo,
      agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {}

  void onUserJoined(agora::user_id_t userId) override {}

  void onUserLeft(agora::user_id_t userId,

                  agora::rtc::USER_OFFLINE_REASON_TYPE reason) override {}

  void onTransportStats(const agora::rtc::RtcStats &stats) override {}

  void onLastmileProbeResult(
      const agora::rtc::LastmileProbeResult &result) override {}

  void onChannelMediaRelayStateChanged(int state, int code) override {}

private:
  std::atomic<bool> _is_connected;
  std::condition_variable _cv;
  std::mutex _lock;
};
