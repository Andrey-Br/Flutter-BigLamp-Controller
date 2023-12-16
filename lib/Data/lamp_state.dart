import 'package:flutter/material.dart';

class LampState {
  const LampState(
      {this.bright = 50, this.color = Colors.white, this.power = false});
  final int bright;
  final Color color;
  final bool power;

  factory LampState.fromJson(dynamic json) {
    assert(json is Map<String, dynamic>);
    final map = json as Map<String, dynamic>;
    assert(map.containsKey('bright'));
    assert(map.containsKey('color'));
    assert(map.containsKey('power'));

    late Color color;
    late bool power;
    late int bright;

    assert(map['bright'] is int);
    bright = map['bright'] as int;

    assert(map['color'] is String);
    final intColors = (map['color'] as String)
        .split(',')
        .map<int>((el) => int.parse(el))
        .toList();
    color = Color.fromARGB(255, intColors[0], intColors[1], intColors[2]);

    assert(map['power'] is int);
    power = (map['power'] as int) == 1;

    return LampState(bright: bright, power: power, color: color);
  }

  Map<String, dynamic> toJson() {
    final stringColor = '${color.red},${color.green},${color.blue}';
    return {'bright': bright, 'color': stringColor, 'power': power ? 1 : 0};
  }

  LampState copyWith({int? bright, Color? color, bool? power}) => LampState(
      bright: bright ?? this.bright,
      color: color ?? this.color,
      power: power ?? this.power);

  @override
  bool operator ==(Object other) {
    if (other is! LampState) {
      return false;
    }

    if (identical(this, other)) {
      return true;
    }

    final identityColor = color == other.color;
    final identityBright = bright == other.bright;
    final identityPower = power == other.power;

    return identityColor && identityBright && identityPower;
  }

  @override
  int get hashCode => color.hashCode ^ power.hashCode ^ bright.hashCode;
}
