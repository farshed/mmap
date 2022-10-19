import 'package:flutter_test/flutter_test.dart';
import 'package:mmap/mmap.dart';
import 'package:mmap/mmap_platform_interface.dart';
import 'package:mmap/mmap_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMmapPlatform 
    with MockPlatformInterfaceMixin
    implements MmapPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MmapPlatform initialPlatform = MmapPlatform.instance;

  test('$MethodChannelMmap is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMmap>());
  });

  test('getPlatformVersion', () async {
    Mmap mmapPlugin = Mmap();
    MockMmapPlatform fakePlatform = MockMmapPlatform();
    MmapPlatform.instance = fakePlatform;
  
    expect(await mmapPlugin.getPlatformVersion(), '42');
  });
}
