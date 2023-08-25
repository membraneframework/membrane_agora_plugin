
#include "connection_observer.h"

void ConnectionObserver::waitUntilConnected() {
  std::unique_lock<std::mutex> unique_lock(_lock);

  while (!_is_connected) {
    _cv.wait(unique_lock);
  }
}

void ConnectionObserver::onConnected(
    const agora::rtc::TConnectionInfo &connectionInfo,
    agora::rtc::CONNECTION_CHANGED_REASON_TYPE reason) {
  UNUSED(connectionInfo);
  UNUSED(reason);
  std::unique_lock<std::mutex> unique_lock(_lock);
  _is_connected = true;
  _cv.notify_one();
}
