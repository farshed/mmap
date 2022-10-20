// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:stdlibc/stdlibc.dart' as libc;

final O_RDWR = libc.O_RDWR;
final O_RDONLY = libc.O_RDONLY;
final O_WRONLY = libc.O_WRONLY;
final O_CREAT = libc.O_CREAT;

final PROT_EXEC = libc.PROT_EXEC;
final PROT_NONE = libc.PROT_NONE;
final PROT_READ = libc.PROT_READ;
final PROT_WRITE = libc.PROT_WRITE;

final MAP_FILE = libc.MAP_FILE;
final MAP_STACK = libc.MAP_STACK;
final MAP_FIXED = libc.MAP_FIXED;
final MAP_SHARED = libc.MAP_SHARED;
final MAP_LOCKED = libc.MAP_LOCKED;
final MAP_PRIVATE = libc.MAP_PRIVATE;
final MAP_POPULATE = libc.MAP_POPULATE;
final MAP_ANONYMOUS = libc.MAP_ANONYMOUS;

final MS_SYNC = libc.MS_SYNC;
final MS_ASYNC = libc.MS_ASYNC;

/// A buffer for memory-mapped I/O
///
/// [Mmap] provides easy abstractions for memory-mapped I/O
/// while sacrificing none of the lower-level control.
///
/// `String path`: Path to the file that'll be mapped memory.
///
/// `int offset`: Byte offset of file to begin mapping from. Defaults to 0.
///
/// `int? length`: Number of bytes to map. Defaults to file size if your map is file-backed.
///
/// `bool readAhead`: Should read-ahead the file or not.
/// Populates (prefault) page tables for mapping. Defaults to false.
///
/// `bool executable`: Whether buffer memory should be executable.
///
class MmapRaw {
  static Pointer<Void>? mmap({
    int? address,
    required int length,
    required int prot,
    required int flags,
    int fd = -1,
    int offset = 0,
  }) {
    final map = libc.mmap(
      address: address,
      prot: prot,
      flags: flags,
      length: length,
      fd: fd,
      offset: offset,
    );

    return map != null ? Pointer.fromAddress(map.address) : null;
  }

  static int coalesceFlags(List<int> flags) {
    return flags.fold(0, (acc, e) => (acc | e));
  }

  /// Returns a file descriptor for the given path
  static int open(String path, int? flags) => libc.open(path, flags: flags);

  /// Closes the file descriptor
  static void close(int fd) => libc.close(fd);

  late int _length;
  late libc.Mmap _map;

  int get length => _length;

  Pointer<Void> get ptr => Pointer.fromAddress(_map.address);

  // void advise() {
  //   libc.
  // }

  void flush() => libc.sync();

  // static void drop() {
  //   libc.munmap(_map);
  // }

  Uint8List asBytes() => asUint8List();

  Uint8List asUint8List() => ptr.cast<Uint8>().asTypedList(_length);
  Uint16List asUint16List() => ptr.cast<Uint16>().asTypedList(_length ~/ 2);
  Uint32List asUint32List() => ptr.cast<Uint32>().asTypedList(_length ~/ 4);
  Uint64List asUint64List() => ptr.cast<Uint64>().asTypedList(_length ~/ 8);

  Int8List asInt8List() => ptr.cast<Int8>().asTypedList(_length);
  Int16List asInt16List() => ptr.cast<Int16>().asTypedList(_length ~/ 2);
  Int32List asInt32List() => ptr.cast<Int32>().asTypedList(_length ~/ 4);
  Int64List asInt64List() => ptr.cast<Int64>().asTypedList(_length ~/ 8);

  Float32List asFloat32List() => ptr.cast<Float>().asTypedList(_length ~/ 4);
  Float64List asFloat64List() => ptr.cast<Double>().asTypedList(_length ~/ 8);
}
