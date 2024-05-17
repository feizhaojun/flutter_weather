import 'dart:async';
import 'package:flutter/material.dart';

// abstract class TODO:
mixin StreamSubController {
  final _subList = <StreamSubscription>[];

  void _bindSub(StreamSubscription sub) {
    _subList.add(sub);
  }

  @protected
  void subDispose() {
    _subList.forEach((v) => v.cancel());
    _subList.clear();
  }
}

extension SubscriptionExt on StreamSubscription {
  void bindLife(StreamSubController controller) {
    controller._bindSub(this);
  }
}

extension ControllerExt<T> on StreamController<T> {
  void safeAdd(T data) {
    // debugPrint("safeAdd: ${data} ${DateTime.now()}");
    if (this.isClosed) return;

    this.add(data);
  }
}
