import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color color;

  // ignore: use_key_in_widget_constructors
  const Badge({this.value, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                // ignore: unnecessary_null_comparison
                color: Color != null ? color : Theme.of(context).colorScheme),
            constraints: const BoxConstraints(minHeight: 16, minWidth: 16),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
