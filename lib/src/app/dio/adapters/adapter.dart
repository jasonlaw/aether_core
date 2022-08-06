export 'stub_adapter.dart'
    if (dart.library.html) 'browser_adapter.dart'
    if (dart.library.io) 'io_adapter.dart';
