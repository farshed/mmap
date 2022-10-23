import 'dart:ffi';
import 'dart:typed_data';
import 'unix.dart';

/// A fixed-length memory-mapped byte buffer that may or may not be backed by a file
abstract class MappedByteBuffer implements Comparable<ByteBuffer> {
  int _len;
  Pointer<Void> _ptr;

  // MappedByteBuffer.readable();

  // MappedByteBuffer.writable();

  // MappedByteBuffer.anonymous();

  /// Wraps a raw Mmap inside a [MapppedByteBuffer] interface
  MappedByteBuffer.from(Mmap mmap)
      : assert(mmap.rawPtr != null, "Invalid Mmap. rawPtr must not be null"),
        _len = mmap.length,
        _ptr = mmap.rawPtr!;

  Uint8List asBytes() => asUint8List();

  Uint8List asUint8List() => _ptr.cast<Uint8>().asTypedList(_len);
  Uint16List asUint16List() => _ptr.cast<Uint16>().asTypedList(_len ~/ 2);
  Uint32List asUint32List() => _ptr.cast<Uint32>().asTypedList(_len ~/ 4);
  Uint64List asUint64List() => _ptr.cast<Uint64>().asTypedList(_len ~/ 8);

  Int8List asInt8List() => _ptr.cast<Int8>().asTypedList(_len);
  Int16List asInt16List() => _ptr.cast<Int16>().asTypedList(_len ~/ 2);
  Int32List asInt32List() => _ptr.cast<Int32>().asTypedList(_len ~/ 4);
  Int64List asInt64List() => _ptr.cast<Int64>().asTypedList(_len ~/ 8);

  Float32List asFloat32List() => _ptr.cast<Float>().asTypedList(_len ~/ 4);
  Float64List asFloat64List() => _ptr.cast<Double>().asTypedList(_len ~/ 8);
}
