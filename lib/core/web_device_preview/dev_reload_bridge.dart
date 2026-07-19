/// Hot reload / restart bridge for the web device-preview toolbar (debug web).
library;

export 'dev_bridge_status.dart';
export 'dev_reload_bridge_io.dart'
    if (dart.library.js_interop) 'dev_reload_bridge_web.dart';
