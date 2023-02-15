export 'http_adapter_stub.dart'
    if (dart.library.html) 'http_adapter_browser.dart'
    if (dart.library.io) 'http_adapter_io.dart';
