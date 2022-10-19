
import 'mmap_platform_interface.dart';

class Mmap {
  Future<String?> getPlatformVersion() {
    return MmapPlatform.instance.getPlatformVersion();
  }
}
