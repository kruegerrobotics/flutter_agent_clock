import 'package:flutter/material.dart';
import 'agent.dart';
import 'helpers.dart';

class ClockPainter extends CustomPainter {
  Paint _paint;

  int msValue;

  List<Offset> mPath;
  List<Agent> agents;

  ClockPainter(this.msValue, this.mPath, this.agents) {
    _paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width > 1.0 && size.height > 1.0) {
      SizeUtil.size = size;
    }

    //just for debug display the digits pure
    /*
    for (int i = 0; i < mPath.length; i++) {
      double x = SizeUtil.getAxisY(mPath[i].dx);
      double y = SizeUtil.getAxisY(mPath[i].dy);
      canvas.drawCircle(Offset(x, y), SizeUtil.getAxisBoth(2), _paint);
    }*/

    for (int i = 0; i < agents.length; i++) {
      agents[i].update();
      double x = SizeUtil.getAxisY(agents[i].pos.x);
      double y = SizeUtil.getAxisY(agents[i].pos.y);
      canvas.drawCircle(Offset(x, y), SizeUtil.getAxisBoth(3), _paint);
    }
  }

  @override
  bool shouldRepaint(ClockPainter old) {
    return old.msValue != msValue;
  }
}
