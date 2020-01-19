// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2, radians;

import 'package:text_to_path_maker/text_to_path_maker.dart';
import 'agent.dart';
import 'helpers.dart';
import 'clockpainter.dart';

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
 
  Timer _timer;
  int frameRate = 60;
  int frameCounter = 0;
  double pointsPerSecond;

  PMFont clockFont;
  List<Offset> mPath = new List();
  List<Offset> emptyPoints = new List();
  bool pathUpdated = false;
  List<Agent> agents = new List();

  int lastMinute = -1;
  bool initComplete = false;

  @override
  void initState() {
    super.initState();

//load the font
    rootBundle.load("assets/digital-7.ttf").then((ByteData data) {
      // Create a font reader
      var reader = PMFontReader();

      // Parse the font
      clockFont = reader.parseTTFAsset(data);

      //create initial path
      createNewPath();

      //declare complete
      initComplete = true;
    });

    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      //on weather and environment data change N.A.
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update each frame for updating the grahics and time
      _timer = Timer(
        //Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        Duration(milliseconds: (1000 ~/ frameRate)),
        _updateTime,
      );

      if (initComplete == true) {
        //every new minute the destiantion points need to be recalculated
        if (_now.minute != lastMinute) {
          agents.clear();
          createNewPath();
          //copy the list of points to know which spots are empty to fill
          emptyPoints = mPath.toList();
          emptyPoints.shuffle();
          pointsPerSecond = mPath.length / 30;
          lastMinute = _now.minute;
        }
        //release an agent
        if (frameCounter >= frameRate / pointsPerSecond) {
          if (emptyPoints.length > 0) {
            Offset target = emptyPoints.removeLast();
            
            //calculate the releasepoint
            //the release point is approximately the location
            //of the hand representing the seconds - should go clockwise around
            double direction = map(_now.second.toDouble(), 0, 60, 0, 360);
            var releasePoint = Offset.fromDirection(radians(direction - 90), 400) +
                Offset(320, 240);
            agents.add(new Agent(Vector2(releasePoint.dx, releasePoint.dy),
                Vector2(target.dx, target.dy)));
            frameCounter = 0;
          }
        }
     
        //activate gravity to remove dots from screen
        if (_now.second > 55) {
          agents.forEach((a) {
            a.fallDown();
          });
        }

        frameCounter++;
      }
    });
  }

  void createNewPath() {
   
    //This could be reworked to work easy with multiple fonts and space
    //Now it is more or less static
    int h1 = (DateTime.now().hour ~/ 10).toInt();
    int h2 = DateTime.now().hour % 10;

    int m1 = (DateTime.now().minute ~/ 10).toInt();
    int m2 = DateTime.now().minute % 10;
    
    double xOffset = 30.0;
    double correctionOffset = 80;
    double h1Offset;
    double h2Offset;
    double m1Offset;
    double m2Offset;
    double yOffset = 270;
    double distance = 130.0;
    double scale = 0.25;
    double precision = 0.035;
    mPath.clear();

    if (h1 == 1) {
      h1Offset = xOffset + correctionOffset;
    } else {
      h1Offset = xOffset;
    }
    var h1Path = clockFont.generatePathForCharacter(48 + h1);
    h1Path = PMTransform.moveAndScale(h1Path, h1Offset, yOffset, scale, scale);
    var h1Pieces = PMPieces.breakIntoPieces(h1Path, precision).points;
    xOffset = xOffset + distance;

    
    if (h2 == 1){
      h2Offset = xOffset + correctionOffset;
    }else {
      h2Offset = xOffset;
    }

    var h2Path = clockFont.generatePathForCharacter(48 + h2);
    h2Path = PMTransform.moveAndScale(h2Path, h2Offset, yOffset, scale, scale);
    var h2Pieces = PMPieces.breakIntoPieces(h2Path, precision).points;
    xOffset = xOffset + distance;

    var colonPath = clockFont.generatePathForCharacter(58);
    colonPath =
        PMTransform.moveAndScale(colonPath, xOffset, yOffset, scale, scale);
    var colonPieces = PMPieces.breakIntoPieces(colonPath, 0.1).points;
    xOffset = xOffset + 60;

    if (m1 == 1) {
      m1Offset = xOffset + correctionOffset;
    } else {
      m1Offset = xOffset;
    }

    var m1Path = clockFont.generatePathForCharacter(48 + m1);
    m1Path = PMTransform.moveAndScale(m1Path, m1Offset, yOffset, scale, scale);
    var m1Pieces = PMPieces.breakIntoPieces(m1Path, precision).points;
    xOffset = xOffset + distance;

    if (m2 == 1) {
      m2Offset = xOffset + correctionOffset;
    } else {
      m2Offset = xOffset;
    }
    var m2Path = clockFont.generatePathForCharacter(48 + m2);
    m2Path = PMTransform.moveAndScale(m2Path, m2Offset, yOffset, scale, scale);
    var m2Pieces = PMPieces.breakIntoPieces(m2Path, precision).points;

    mPath =
        new List.from(h1Pieces + h2Pieces + m1Pieces + m2Pieces + colonPieces);

    pathUpdated = true;
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hms().format(DateTime.now());
    
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        //color: customTheme.backgroundColor,
        color: Colors.black,
        child: Center(
            child: Container(
          color: Color.fromARGB(255, 60, 60, 60),
          //color : Colors.black,
          /*width: 640,
          height: 480,*/
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomPaint(
            painter: ClockPainter(_now.millisecond, mPath, agents),
          ),
        )),
      ),
    );
  }
}

