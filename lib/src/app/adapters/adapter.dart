export 'adapter_stub.dart'
    if (dart.library.html) 'adapter_web.dart'
    if (dart.library.io) 'adapter_io.dart';
