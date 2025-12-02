import 'package:flutter/material.dart';

class XPLevelBar extends StatelessWidget {
  final int level;
  final int currentXP;
  final int xpNeeded;

  const XPLevelBar({
    super.key,
    required this.level,
    required this.currentXP,
    required this.xpNeeded,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpNeeded == 0 ? 0.0 : (currentXP / xpNeeded).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Nível $level', style: Theme.of(context).textTheme.titleMedium),
            Text('$currentXP / $xpNeeded XP', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}
