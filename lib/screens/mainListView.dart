import 'dayView.dart';
import 'package:flutter/material.dart';
import '../models/timeBloc.dart';
import 'package:intl/intl.dart';
import 'newEvent.dart';


Widget createCard(timeBloc bloc, DateTime viewDate, int day){
  var code = bloc.getCode();
  var colr = (code.substring(0,1) == 'A')? Colors.green : Colors.redAccent;

  return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: colr),
        child: makeTile(bloc, viewDate, day),
      )
  );
}

Widget makeTile(timeBloc bloc, DateTime viewDate, int day){
  //deal with codes and text
  var codes = bloc.getCode().split(" ");
  bool off = (codes[0] == "D");
  var text = off? 'TV Off' : "Channel " + codes[1] + " at volume " + codes[2];

  //deal with times
  DateTime start = DateTime.parse(DateFormat("yyyy-MM-dd ").format(viewDate)
      + bloc.getStart() + ':00');
  DateTime end = DateTime.parse(DateFormat("yyyy-MM-dd ").format(viewDate)
      + bloc.getEnd() + ':00');
  start = new DateTime.utc(start.year, start.month, start.day, start.hour, start.minute);
  end = new DateTime.utc(end.year, end.month, end.day, end.hour, end.minute);

  var diff = end.difference(start);
  int tileHeight;
  if (off) tileHeight = 65;
  if (diff.inMinutes < 31) tileHeight = 80;
  else if (diff.inMinutes > 181) tileHeight = 230;
  else tileHeight = (90 + (diff.inMinutes - 30)*0.87).ceil();

  //deal with icons
  var iconVar;
  if (day == -1) iconVar = Icon(Icons.check, color: Colors.white70,);
  else if (day == 1) iconVar = Icon(Icons.calendar_today, color: Colors.white70,);
  else if (viewDate.isAfter(end)) iconVar = Icon(Icons.check, color: Colors.white70,);
  else if (viewDate.isBefore(start)) iconVar = Icon(Icons.calendar_today, color: Colors.white70,);
  else iconVar = Icon(Icons.schedule);


  return Container(
      height: tileHeight.toDouble(),
      alignment: Alignment(0, 0),
      child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          leading: iconVar,
          title: Text(text, style: TextStyle(fontWeight: FontWeight.bold),),
          trailing: Container(
            margin: EdgeInsets.symmetric(vertical: 0),
            width: 50,
            child: (off)? Container(
              alignment: Alignment.center,
              child: Text(DateFormat("Hm").format(start)),
              ) : Column(
                children: [
                  Container(
                    height: 20,
                    alignment: Alignment.topCenter,
                    child: Text(DateFormat("Hm").format(start)),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: (off)? Container(): Text(DateFormat("Hm").format(end)),
                    ))
                ]
            ),
          )

      )
  );

}
