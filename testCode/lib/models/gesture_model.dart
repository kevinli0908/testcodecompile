import 'package:flutter/material.dart';

class GestureModel {
  final String name;
  final String description;
  final IconData icon;
  final String? assignedAction;

  const GestureModel({
    required this.name,
    required this.description,
    required this.icon,
    this.assignedAction,
  });

  factory GestureModel.doubleTap() {
    return const GestureModel(
      name: 'Double Tap',
      description: 'Tap twice, quickly',
      icon: Icons.touch_app,
      assignedAction: 'Take Screenshot',
    );
  }

  factory GestureModel.longPress() {
    return const GestureModel(
      name: 'Long Press',
      description: 'Press and hold',
      icon: Icons.touch_app,
      assignedAction: 'Open Menu',
    );
  }

  factory GestureModel.swipeUp() {
    return const GestureModel(
      name: 'Swipe Up + Hold 3s',
      description: 'Swipe up, then hold for 3 seconds',
      icon: Icons.swipe_up,
      assignedAction: 'Volume Up',
    );
  }

  factory GestureModel.swipeDown() {
    return const GestureModel(
      name: 'Swipe Down + Hold 3s',
      description: 'Swipe down, then hold for 3 seconds',
      icon: Icons.swipe_down,
      assignedAction: 'Volume Down',
    );
  }

  factory GestureModel.swipeLeft() {
    return const GestureModel(
      name: 'Swipe Left + Hold 3s',
      description: 'Swipe left, then hold for 3 seconds',
      icon: Icons.swipe_left,
      assignedAction: 'Previous Track',
    );
  }

  factory GestureModel.swipeRight() {
    return const GestureModel(
      name: 'Swipe Right + Hold 3s',
      description: 'Swipe right, then hold for 3 seconds',
      icon: Icons.swipe_right,
      assignedAction: 'Next Track',
    );
  }

  static List<GestureModel> defaultGestures() {
    return [
      GestureModel.doubleTap(),
      GestureModel.longPress(),
      GestureModel.swipeUp(),
      GestureModel.swipeDown(),
      GestureModel.swipeLeft(),
      GestureModel.swipeRight(),
    ];
  }

  GestureModel copyWith({String? assignedAction}) {
    return GestureModel(
      name: name,
      description: description,
      icon: icon,
      assignedAction: assignedAction ?? this.assignedAction,
    );
  }
}