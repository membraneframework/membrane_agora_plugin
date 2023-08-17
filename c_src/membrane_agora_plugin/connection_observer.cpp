
#include "connection_observer.h"
#include "log.h"

void ConnectionObserver::waitUntilConnected() {
  std::unique_lock<std::mutex> unique_lock(_lock);

  while (!_is_connected) {
    _cv.wait(unique_lock);
  }
}

void ConnectionObserver::onConnected(
    const agora::rtc::TConnectionInfo &connectionInfo,
    agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) {
  AG_LOG(INFO, "onConnected: id %u, channelId %s, localUserId %s, reason %d\n",
         connectionInfo.id, connectionInfo.channelId.get()->c_str(),
         connectionInfo.localUserId.get()->c_str(), reason);

  std::unique_lock<std::mutex> unique_lock(_lock);
  _is_connected = true;
  _cv.notify_one();
}

void ConnectionObserver::onConnecting(
    const agora::rtc::TConnectionInfo &connectionInfo,
    agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) {
  AG_LOG(INFO, "onConnecting: id %u, channelId %s, localUserId %s, reason %d\n",
         connectionInfo.id, connectionInfo.channelId.get()->c_str(),
         connectionInfo.localUserId.get()->c_str(), reason);
}
