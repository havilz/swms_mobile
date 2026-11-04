import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class ReportImageProvider extends ImageProvider<ReportImageKey> {
  const ReportImageProvider(this.url, {required this.headers});

  final String url;
  final Map<String, String> headers;

  @override
  Future<ReportImageKey> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(ReportImageKey(url, headers));

  @override
  ImageStreamCompleter loadImage(
    ReportImageKey key,
    ImageDecoderCallback decode,
  ) {
    final provider = NetworkImage(key.url, headers: key.headers);
    return provider.loadImage(provider, decode);
  }

  @override
  String toString() => 'ReportImageProvider("$url")';
}

@immutable
class ReportImageKey {
  const ReportImageKey(this.url, this.headers);

  final String url;
  final Map<String, String> headers;

  @override
  bool operator ==(Object other) =>
      other is ReportImageKey &&
      other.url == url &&
      mapEquals(other.headers, headers);

  @override
  int get hashCode =>
      Object.hash(url, Object.hashAllUnordered(headers.entries));

  @override
  String toString() => 'ReportImageKey("$url")';
}
