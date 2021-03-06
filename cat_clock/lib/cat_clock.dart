import 'dart:async';

import 'package:cat_clock/animation_controllers/sky_controller.dart';
import 'package:cat_clock/config.dart';
import 'package:cat_clock/utils/weather_condition.dart';
import 'package:cat_clock/widgets/text/clock_face_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

class CatClock extends StatefulWidget {
  const CatClock(this.model);

  final ClockModel model;

  @override
  _CatClockState createState() => _CatClockState();
}

class _CatClockState extends State<CatClock> with WidgetsBindingObserver {
  SkyController _skyController;
  Timer _clockTimer;
  DateTime _clockDateTime;

  @override
  void initState() {
    super.initState();

    _clockDateTime = DateTime.now();
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _clockDateTime = _clockDateTime.add(Duration(seconds: 1));
      });
    });

    WidgetsBinding.instance.addObserver(this);
    _skyController = SkyController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer.cancel();
    super.dispose();
  }

  Widget temperature(double heightUnit) {
    double temperature = widget.model.temperature;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: <Widget>[
        ClockFaceText(
          "${temperature.round()}",
          heightUnit,
          fontWeight: FontWeight.w400,
          fontSize: heightUnit,
        ),
        ClockFaceText(
          "°",
          heightUnit,
          fontWeight: FontWeight.w300,
          fontSize: heightUnit,
        ),
        Icon(
          widget.model.weatherCondition.weatherIcon(),
          color: Colors.white,
          size: heightUnit * 0.5,
        ),
      ],
    );
  }

  Widget address(double heightUnit) {
    return Expanded(
      child: ClockFaceText(
        widget.model.location,
        heightUnit,
        fontWeight: FontWeight.w400,
        fontSize: heightUnit * 0.5,
      ),
    );
  }

  Widget date(double heightUnit) {
    return ClockFaceText(
      "${DateFormat("EEE").format(_clockDateTime)} ${DateFormat("MM-dd").format(_clockDateTime)}",
      heightUnit,
      fontWeight: FontWeight.w300,
      fontSize: heightUnit * 0.6,
    );
  }

  Widget partOfDay(double heightUnit) {
    String partOfDayString = "";
    if (_clockDateTime.hour < 12) {
      partOfDayString = "AM";
    } else {
      partOfDayString = "PM";
    }
    return ClockFaceText(
      partOfDayString,
      heightUnit,
      fontWeight: FontWeight.w400,
      fontSize: heightUnit * 0.5,
    );
  }

  Widget time(double heightUnit) {
    return ClockFaceText(
      "${DateFormat(widget.model.is24HourFormat ? "HH:mm" : "hh:mm").format(_clockDateTime)}",
      heightUnit,
      fontWeight: FontWeight.w400,
      fontSize: heightUnit * 1.7,
    );
  }

  Widget frontWidgets(double heightUnit) {
    return Padding(
      padding: EdgeInsets.all(heightUnit * 0.5),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              temperature(heightUnit),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[date(heightUnit)],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              address(heightUnit),
              if (!widget.model.is24HourFormat) partOfDay(heightUnit),
              SizedBox(width: heightUnit * 0.2),
              time(heightUnit),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FlareActor(
                "assets/riva/Sky.flr",
                controller: _skyController,
                fit: BoxFit.cover,
              ),
              frontWidgets(constraints.biggest.height / heightUnitRatio),
            ],
          ),
        );
      },
    );
  }

  // WidgetsBindingObserver
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _skyController.refreshTime();
      setState(() {
        _clockDateTime = DateTime.now();
      });
    }
    super.didChangeAppLifecycleState(state);
  }
}
