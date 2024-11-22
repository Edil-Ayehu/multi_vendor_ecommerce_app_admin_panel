import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  final double height;
  final Color? color;

  const DottedDivider({
    super.key,
    this.height = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 5.0;
            const dashSpace = 4.0;
            final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

            return Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: List.generate(dashCount, (_) {
                return SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
