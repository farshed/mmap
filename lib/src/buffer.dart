import 'dart:typed_data';

abstract class MappedByteBuffer implements Comparable<ByteBuffer> {
  final ByteBuffer _data;
}
