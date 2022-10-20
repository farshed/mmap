// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:stdlibc/stdlibc.dart' as libc;

/// Some common properties on constructors.
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
class Mmap {
  static final PROT_EXEC = libc.PROT_EXEC;
  static final PROT_NONE = libc.PROT_NONE;
  static final PROT_READ = libc.PROT_READ;
  static final PROT_WRITE = libc.PROT_WRITE;

  static final MAP_FILE = libc.MAP_FILE;
  static final MAP_STACK = libc.MAP_STACK;
  static final MAP_FIXED = libc.MAP_FIXED;
  static final MAP_SHARED = libc.MAP_SHARED;
  static final MAP_LOCKED = libc.MAP_LOCKED;
  static final MAP_PRIVATE = libc.MAP_PRIVATE;
  static final MAP_POPULATE = libc.MAP_POPULATE;
  static final MAP_ANONYMOUS = libc.MAP_ANONYMOUS;

  /// Creates a read-only memory-mapped buffer from a file.
  Mmap.readOnly(
    String path, {
    int offset = 0,
    int? length,
    bool readAhead = false,
    bool executable = false,
  }) {
    final len = length ?? File(path).lengthSync();
    int prot = PROT_READ;
    if (executable) prot |= PROT_EXEC;

    int flags = MAP_FILE;
    if (readAhead) flags |= MAP_POPULATE;

    final map = _mmap(null, len, prot, flags, path, offset);
    if (map != null) _map = map;
  }

  /// Creates a mutable memory-mapped buffer from a file.
  ///
  /// [copyOnWrite]: By default, any changes to the buffer's content
  /// are synced and carried through to the underlying file.
  /// Setting [copyOnWrite] to 'true' allows you to edit the buffer
  ///  without causing any changes in the source file.
  /// All the changes are instead held in memory/swap space.
  ///
  Mmap.writable(
    String path, {
    int offset = 0,
    int? length,
    bool readAhead = false,
    bool executable = false,
    bool copyOnWrite = false,
  }) {
    final len = length ?? File(path).lengthSync();
    int prot = PROT_READ | PROT_WRITE;
    if (executable) prot |= PROT_EXEC;

    int flags = MAP_FILE | (copyOnWrite ? MAP_PRIVATE : MAP_SHARED);
    if (readAhead) flags |= MAP_POPULATE;

    final map = _mmap(null, len, prot, flags, path, offset);
    if (map != null) _map = map;
  }

  /// Creates a memory-mapped buffer that is not backed by any file.
  ///
  /// [length]: Explicit length is required anonymous mappings.
  ///
  /// [shared]`: Should the map be shareable with other processes.
  ///
  /// [stack]`: Hint to kernel that an address mapping suitable
  /// for a process or thread stack is needed.
  ///
  Mmap.anonymous({
    required int length,
    bool shared = true,
    bool stack = false,
    bool executable = false,
  }) {
    int prots = PROT_READ | PROT_WRITE;
    if (executable) prots |= PROT_EXEC;

    int flags = MAP_ANONYMOUS | MAP_SHARED;
    if (stack) flags |= MAP_STACK;

    final map = _mmap(null, length, prots, flags, null, 0);
    if (map != null) _map = map;
  }

  /// Creates a custom memory-mapped buffer.
  ///
  /// This constructor closely mirrors Unix's `mmap()` syscall to allow more detailed control.
  ///
  /// `address`: Preffered address for the buffer.
  ///
  /// `prot`: Memory protection for the mapping.
  ///
  /// `flags`: Flags allow fine control over mapping's behavior.
  ///
  /// `fileDesc`: A File object that refers to the source file
  ///  (If this map is file-backed).
  ///
  Mmap.custom({
    int? address,
    required int length,
    required int prot,
    required int flags,
    File? fileDesc,
    int offset = 0,
  }) {
    final map = _mmap(address, length, prot, flags, fileDesc?.path, offset);
    if (map != null) _map = map;
  }

  late int _length;
  late libc.Mmap _map;

  int get length => _length;

  Pointer<Void> get ptr => Pointer.fromAddress(_map.address);

  libc.Mmap? _mmap(
      int? addr, int len, int prot, int flags, String? fp, int offset) {
    final fd = fp == null ? -1 : libc.open(fp, flags: 0);
    _length = len;

    final map = libc.mmap(
      address: addr,
      prot: prot,
      flags: flags,
      length: len,
      offset: offset,
      fd: fd,
    );

    if (fd > -1) libc.close(fd);
    return map;
  }

  // void advise() {
  //   libc.
  // }

  void flush() => libc.sync();

  void close() {
    libc.munmap(_map);
  }

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
