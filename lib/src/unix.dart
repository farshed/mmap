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

typedef _Mmap = libc.Mmap;

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
class Mmap {
  late int _len;
  _Mmap? _map;

  Mmap.raw({
    int? address,
    required int length,
    required int prot,
    required int flags,
    int fd = -1,
    int offset = 0,
  }) {
    _len = length;
    _map = libc.mmap(
      address: address,
      prot: prot,
      flags: flags,
      length: length,
      fd: fd,
      offset: offset,
    );
    assert(_map != null, "Failed to create Mmap");
  }

  /// Number of bytes in memory mapping
  int get length => _len;

  /// A pointer to the newly created memory-mapped buffer
  Pointer<Void>? get rawPtr =>
      _map != null ? Pointer.fromAddress(_map!.address) : null;

  /// Coalesce multiple bitflags into a single integer
  static int coalesceFlags(List<int> flags) {
    return flags.fold(0, (acc, e) => (acc | e));
  }

  /// Returns a file descriptor for the given path
  static int openFile(String path, int? flags) => libc.open(path, flags: flags);

  /// Closes a given file descriptor
  static void close(int fd) => libc.close(fd);

  // void advise() {
  //   libc
  // }

  void flush() => libc.sync();

  void drop() {
    if (_map != null) libc.munmap(_map!);
  }

  Uint8List asBytes() => asUint8List();

  Uint8List asUint8List() => rawPtr!.cast<Uint8>().asTypedList(_len);
  Uint16List asUint16List() => rawPtr!.cast<Uint16>().asTypedList(_len ~/ 2);
  Uint32List asUint32List() => rawPtr!.cast<Uint32>().asTypedList(_len ~/ 4);
  Uint64List asUint64List() => rawPtr!.cast<Uint64>().asTypedList(_len ~/ 8);

  Int8List asInt8List() => rawPtr!.cast<Int8>().asTypedList(_len);
  Int16List asInt16List() => rawPtr!.cast<Int16>().asTypedList(_len ~/ 2);
  Int32List asInt32List() => rawPtr!.cast<Int32>().asTypedList(_len ~/ 4);
  Int64List asInt64List() => rawPtr!.cast<Int64>().asTypedList(_len ~/ 8);

  Float32List asFloat32List() => rawPtr!.cast<Float>().asTypedList(_len ~/ 4);
  Float64List asFloat64List() => rawPtr!.cast<Double>().asTypedList(_len ~/ 8);
}
