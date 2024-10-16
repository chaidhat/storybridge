import 'package:flutter/foundation.dart';

const bool OVERRIDE_USE_RELEASE = true;

bool getOverridePaymentLocks() {
  if (kReleaseMode) {
    return false;
  } else {
    return true;
  }
}

String getServerUriScheme() {
  if (kReleaseMode || OVERRIDE_USE_RELEASE) {
    return "https";
  } else {
    return "http";
  }
}

String getServerUriHost() {
  if (kReleaseMode || OVERRIDE_USE_RELEASE) {
    return "server-singapore.scholarity.io";
  } else {
    return "localhost";
  }
}

int? getServerUriPort() {
  if (kReleaseMode || OVERRIDE_USE_RELEASE) {
    return null;
  } else {
    return 3000;
  }
}
