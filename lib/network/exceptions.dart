class UnknownException implements Exception {
  String devDescription;
  UnknownException(this.devDescription);
  String toString() => "We're unsure what happened, but we're looking into it.";
}

class ConnectivityException implements Exception {
  String toString() => 'You are not connected to the internet at this time.';
}

class RetryFailureException implements Exception {
  String toString() =>
      'There is a problem with the internet connection, please retry later.';
}

class UnexpectedResponseException implements Exception {
  dynamic response;
  UnexpectedResponseException(this.response);
  String toString() => "There is an unexpected issue. Please try again later.";
}

class SyncException implements Exception {
  String devDescription;
  SyncException(this.devDescription);
  String toString() => devDescription;
}
