#pragma once

#include <atomic>
#include <condition_variable>
#include <mutex>

#include "NGIAgoraRtcConnection.h"

#include "common.h"

class ConnectionObserver : public agora::rtc::IRtcConnectionObserver {
public:
  ConnectionObserver() : _is_connected(false) {}

  void waitUntilConnected();

public: // IRtcConnectionObserver
  void onConnected(const agora::rtc::TConnectionInfo &connectionInfo,
                   agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override;

  void
  onConnecting(const agora::rtc::TConnectionInfo &connectionInfo,
               agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {
    UNUSED(connectionInfo);
    UNUSED(reason);
  }

  void
  onDisconnected(const agora::rtc::TConnectionInfo &connectionInfo,
                 agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {
    UNUSED(connectionInfo);
    UNUSED(reason);
  }

  void
  onReconnecting(const agora::rtc::TConnectionInfo &connectionInfo,
                 agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {
    UNUSED(connectionInfo);
    UNUSED(reason);
  }

  void
  onReconnected(const agora::rtc::TConnectionInfo &connectionInfo,
                agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {
    UNUSED(connectionInfo);
    UNUSED(reason);
  }

  void
  onConnectionLost(const agora::rtc::TConnectionInfo &connectionInfo) override {
    UNUSED(connectionInfo);
  }

  void onLastmileQuality(const agora::rtc::QUALITY_TYPE quality) override {
    UNUSED(quality);
  }

  void onTokenPrivilegeWillExpire(const char *token) override { UNUSED(token); }

  void onTokenPrivilegeDidExpire() override {}

  void onConnectionFailure(
      const agora::rtc::TConnectionInfo &connectionInfo,
      agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) override {
    UNUSED(connectionInfo);
    UNUSED(reason);
  }

  void onUserJoined(agora::user_id_t userId) override { UNUSED(userId); }

  void onUserLeft(agora::user_id_t userId,

                  agora::rtc::USER_OFFLINE_REASON_TYPE reason) override {
    UNUSED(userId);
    UNUSED(reason);
  }

  void onTransportStats(const agora::rtc::RtcStats &stats) override {
    UNUSED(stats);
  }

  void onLastmileProbeResult(
      const agora::rtc::LastmileProbeResult &result) override {
    UNUSED(result);
  }

  void onChannelMediaRelayStateChanged(int state, int code) override {
    UNUSED(state);
    UNUSED(code);
  }

private:
  std::atomic<bool> _is_connected;
  std::condition_variable _cv;
  std::mutex _lock;
};
