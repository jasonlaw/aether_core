/// Generates UUID v1
library uuid;

import 'dart:typed_data';
import 'dart:math';

/// uuid for Dart
/// Author: Yulian Kuncheff
/// Released under MIT License.
/// https://github.com/Daegalus/dart-uuid

class Uuid {
  static final _random = Random();

  // Easy number <-> hex conversion
  static final List<String> _byteToHex = List<String>.generate(256, (i) {
    return i.toRadixString(16).padLeft(2, '0');
  });

  static final _stateExpando = Expando<Map<String, dynamic>>();
  Map<String, dynamic> get _state => _stateExpando[this] ??= {
        'seedBytes': null,
        'node': null,
        'clockSeq': null,
        'mSecs': 0,
        'nSecs': 0,
        'hasInitV1': false
      };

  const Uuid();

  /// Unparses a [buffer] of bytes and outputs a proper UUID string.
  /// An optional [offset] is allowed if you want to start at a different point
  /// in the buffer.
  /// Throws an exception if the buffer does not have a length of 16
  static String unparse(List<int> buffer, {int offset = 0}) {
    if (buffer.length != 16) {
      throw Exception('The provided buffer needs to have a length of 16.');
    }
    var i = offset;
    return '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}-'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}-'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}-'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}-'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}'
        '${_byteToHex[buffer[i++]]}${_byteToHex[buffer[i++]]}';
  }

  void _initV1() {
    if (!(_state['hasInitV1']! as bool)) {
      var seedBytes = _mathRNG();

      _state['seedBytes'] ??= seedBytes;
      // Per 4.5, create a 48-bit node id (47 random bits + multicast bit = 1)
      var nodeId = [
        seedBytes[0] | 0x01,
        seedBytes[1],
        seedBytes[2],
        seedBytes[3],
        seedBytes[4],
        seedBytes[5]
      ];
      _state['node'] ??= nodeId;

      // Per 4.2.2, randomize (14 bit) clockseq
      var clockSeq = (seedBytes[6] << 8 | seedBytes[7]) & 0x3ffff;
      _state['clockSeq'] ??= clockSeq;

      _state['mSecs'] = 0;
      _state['nSecs'] = 0;
      _state['hasInitV1'] = true;
    }
  }

  /// v1() Generates a time-based version 1 UUID
  ///
  /// By default it will generate a string based off current time, and will
  /// return a string.
  ///
  /// The first argument is an options map that takes various configuration
  /// options detailed in the readme.
  ///
  /// http://tools.ietf.org/html/rfc4122.html#section-4.2.2
  String v1() {
    var i = 0;
    var buf = Uint8List(16);

    _initV1();
    var clockSeq = _state['clockSeq'] as int;

    // UUID timestamps are 100 nano-second units since the Gregorian epoch,
    // (1582-10-15 00:00). Time is handled internally as 'msecs' (integer
    // milliseconds) and 'nsecs' (100-nanoseconds offset from msecs) since unix
    // epoch, 1970-01-01 00:00.
    var mSecs = (DateTime.now()).millisecondsSinceEpoch;

    // Per 4.2.1.2, use count of uuid's generated during the current clock
    // cycle to simulate higher resolution clock
    var nSecs = (_state['nSecs']! as int) + 1;

    // Time since last uuid creation (in msecs)
    var dt = (mSecs - _state['mSecs']) + (nSecs - _state['nSecs']) / 10000;

    // Per 4.2.1.2, Bump clockseq on clock regression
    if (dt < 0) {
      clockSeq = clockSeq + 1 & 0x3fff;
    }

    // Reset nsecs if clock regresses (new clockseq) or we've moved onto a new
    // time interval
    if ((dt < 0 || mSecs > _state['mSecs'])) {
      nSecs = 0;
    }

    // Per 4.2.1.2 Throw error if too many uuids are requested
    if (nSecs >= 10000) {
      throw Exception('uuid.v1(): Can\'t create more than 10M uuids/sec');
    }

    _state['mSecs'] = mSecs;
    _state['nSecs'] = nSecs;
    _state['clockSeq'] = clockSeq;

    // Per 4.1.4 - Convert from unix epoch to Gregorian epoch
    mSecs += 12219292800000;

    // time Low
    var tl = ((mSecs & 0xfffffff) * 10000 + nSecs) % 0x100000000;
    buf[i++] = tl >> 24 & 0xff;
    buf[i++] = tl >> 16 & 0xff;
    buf[i++] = tl >> 8 & 0xff;
    buf[i++] = tl & 0xff;

    // time mid
    var tmh = (mSecs / 0x100000000 * 10000).floor() & 0xfffffff;
    buf[i++] = tmh >> 8 & 0xff;
    buf[i++] = tmh & 0xff;

    // time high and version
    buf[i++] = tmh >> 24 & 0xf | 0x10; // include version
    buf[i++] = tmh >> 16 & 0xff;

    // clockSeq high and reserved (Per 4.2.2 - include variant)
    buf[i++] = (clockSeq & 0x3F00) >> 8 | 0x80;

    // clockSeq low
    buf[i++] = clockSeq & 0xff;

    // node
    var node = _state['node'];
    for (var n = 0; n < 6; n++) {
      buf[i + n] = node[n];
    }

    return unparse(buf);
  }

  String digits(int size, {int seed = -1}) {
    final rand = (seed == -1) ? _random : Random(seed);
    final maxNr = pow(10, size) - 1;
    return rand.nextInt(maxNr.toInt()).toString().padLeft(size, '0');
  }

  static Uint8List _mathRNG({int seed = -1}) {
    final b = Uint8List(16);
    final rand = (seed == -1) ? _random : Random(seed);

    for (var i = 0; i < 16; i++) {
      b[i] = rand.nextInt(256);
    }

    return b;
  }
}
