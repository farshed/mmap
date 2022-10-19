// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:stdlibc/stdlibc.dart' as libc;

/// Access modes for file-backed memory maps.
///
/// `readOnly`: File is read-only.
///
/// `writable`: Map is mutable and the changes are
/// carried through to the source file.
///
/// `copyOnWrite`: Updates are not written to the
/// underlying file but are held in memory/swap space.
enum AccessMode { readOnly, writable, copyOnWrite }

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

  late int _address;
  late ByteBuffer _data;

  /// Creates a memory mapped buffer from a file.
  ///
  /// `String filePath`: Path to the buffer's source file.
  ///
  /// `int offset`: Buffer is mapped from the `offset`-th
  /// byte of the file. Defaults to zero.
  ///
  /// `int? length`: Number of bytes to map. Defaults to file size.
  ///
  /// `AccessMode mode`: Access pattern for the buffer's underlying file.
  ///
  /// `bool readAhead`: Should read-ahead the file or not.
  /// Populates (prefault) page tables for mapping. Defaults to false.
  ///
  /// `bool executable`: Whether buffer memory should be executable.
  ///
  Mmap(
    String filePath, {
    int offset = 0,
    int? length,
    AccessMode mode = AccessMode.copyOnWrite,
    // bool shared = false,
    bool readAhead = false,
    bool executable = false,
  }) {
    final length = File(filePath).lengthSync();
    int prot = PROT_READ;
    if (mode != AccessMode.readOnly) prot |= PROT_WRITE;
    if (executable) prot |= PROT_EXEC;

    int flags = MAP_FILE;
    if (readAhead) flags |= MAP_POPULATE;
    if (mode == AccessMode.writable) flags |= MAP_SHARED;
    if (mode == AccessMode.copyOnWrite) flags |= MAP_PRIVATE;

    final map = libc.mmap(
      prot: prot,
      flags: flags,
      length: length,
      offset: offset,
      fd: libc.open(filePath, flags: 0),
    );

    if (map != null) {
      _data = map.data;
      _address = map.address;
    }
  }

  int get length => _data.lengthInBytes;

  /// Creates an anonymous memory buffer that is not backed by any file.
  ///
  /// `int length`: Length of the buffer.
  ///
  /// `bool shared`: Whether the map should be shareable with related processes.
  ///
  /// `bool markStack`: Hint kernel that an address mapping suitable for a process or thread stack.]
  ///
  Mmap.anonymous({
    required int length,
    bool shared = false,
    bool markStack = false,
  });

// Mmap.cow({})

  // static Future<Mmap> create(String fileName,
  //     {int prot: PROT_READ, int flags: MAP_SHARED, int offset: 0}) async {
  //   final file = File(fileName);
  //   final stat = await file.stat();
  //   final size = stat.size;
  //   return Mmap._(fileName, size, prot: prot, flags: flags, offset: offset);
  // }

  // factory Mmap(String fileName,
  //     {int prot: PROT_READ, int flags: MAP_SHARED, int offset: 0}) {
  //   final file = File(fileName);
  //   final stat = file.statSync();
  //   final size = stat.size;
  //   return Mmap._(fileName, size, prot: prot, flags: flags, offset: offset);
  // }

  // Mmap._(String fileName, int size,
  //     {int prot: PROT_READ, int flags: MAP_SHARED, int offset: 0}) {
  //   _fd = libc.open(fileName, 0, 0);
  //   _inner = MmapInner(size, _fd, prot, flags, offset);
  // }

  // int get length => _inner.len;

  MmapInner get inner => _inner;

  void close() {
    libc.close(_fd);
    _inner?.drop();
    _inner = null;
  }

  Uint8List asBytes() {
    return _inner.asBytes();
  }
}

class MmapInnerImpl implements MmapInner {
  int _ptrAddr;
  int _len;

  MmapInnerImpl._(
      this._len, int file_descriptor, int prot, int flags, int offset) {
    _ptrAddr =
        libc.mmap(nullptr, _len, prot, flags, file_descriptor, offset).address;

    if (_ptrAddr < 0) {
      throw Exception('mmap failed');
    }
  }

  Pointer<Void> get ptr => Pointer.fromAddress(_ptrAddr);

  void drop() {
    var alignment = ptr.address % libc.pageSize();
    if (alignment != 0) {
      var alignedPtr = Pointer<Void>.fromAddress(ptr.address - alignment);
      libc.munmap(alignedPtr, _len + alignment);
    } else {
      libc.munmap(ptr, _len);
    }
  }

  Uint8List asBytes() {
    var bytes = ptr.cast<Uint8>();
    return bytes.asTypedList(_len);
  }

  Uint8List asUint8List() {
    return ptr.cast<Uint8>().asTypedList(_len);
  }

  Uint16List asUint16List() {
    return ptr.cast<Uint16>().asTypedList(_len ~/ 2);
  }

  Uint32List asUint32List() {
    return ptr.cast<Uint32>().asTypedList(_len ~/ 4);
  }

  Uint64List asUint64List() {
    return ptr.cast<Uint64>().asTypedList(_len ~/ 8);
  }

  Int8List asInt8List() {
    return ptr.cast<Int8>().asTypedList(_len);
  }

  Int16List asInt16List() {
    return ptr.cast<Int16>().asTypedList(_len ~/ 2);
  }

  Int32List asInt32List() {
    return ptr.cast<Int32>().asTypedList(_len ~/ 4);
  }

  Int64List asInt64List() {
    return ptr.cast<Int64>().asTypedList(_len ~/ 8);
  }

  Float32List asFloat32List() {
    return ptr.cast<Float>().asTypedList(_len ~/ 4);
  }

  Float64List asFloat64List() {
    return ptr.cast<Double>().asTypedList(_len ~/ 8);
  }

  @override
  int get len => _len;
}

class EmptyMmapInner implements MmapInner {
  @override
  Uint8List asBytes() => Uint8List(0);

  @override
  Float32List asFloat32List() => Float32List(0);

  @override
  Float64List asFloat64List() => Float64List(0);

  @override
  Int16List asInt16List() => Int16List(0);

  @override
  Int32List asInt32List() => Int32List(0);

  @override
  Int64List asInt64List() => Int64List(0);

  @override
  Int8List asInt8List() => Int8List(0);

  @override
  Uint16List asUint16List() => Uint16List(0);

  @override
  Uint32List asUint32List() => Uint32List(0);

  @override
  Uint64List asUint64List() => Uint64List(0);

  @override
  Uint8List asUint8List() => Uint8List(0);

  @override
  void drop() {}

  @override
  int get len => 0;

  @override
  Pointer<Void> get ptr => nullptr;
}

abstract class MmapInner {
  factory MmapInner(
      int len, int file_descriptor, int prot, int flags, int offset) {
    if (len == 0) {
      return EmptyMmapInner();
    } else {
      return MmapInnerImpl._(len, file_descriptor, prot, flags, offset);
    }
  }

  int get len;

  Uint8List asBytes();
  Uint8List asUint8List();
  Uint16List asUint16List();
  Uint32List asUint32List();
  Uint64List asUint64List();

  Int8List asInt8List();
  Int16List asInt16List();
  Int32List asInt32List();
  Int64List asInt64List();

  Float32List asFloat32List();
  Float64List asFloat64List();

  void drop();

  Pointer<Void> get ptr;
}
