import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class fullSchedule {
  bool _status;
  var daysList = <dayBloc>[];

  fullSchedule(Map<String, dynamic> jsonMap){
    _status = (jsonMap['status'] == "enabled")? true : false;
    Map tempMap = jsonMap['schedule'];
    tempMap.forEach((k,v) {
      daysList.add(dayBloc.fromJson(k, v));
    });

  }

  Map getJson(){
    var map = Map<String, dynamic>();
    map["status"] = (_status)? "enabled" : "disabled";
    var daysMap = Map<String, dynamic>();

    //first perform maintenance on daysList
    for (int i = 0; i < daysList.length; i++){
      if (daysList[i].blocList.isEmpty){
        daysList.removeAt(i);
        continue;
      }
      DateTime now = (new DateTime.now().toUtc()).subtract(Duration(hours: 3));
      String DayString = daysList[i].date;
      DateTime day = new DateTime.utc(int.parse(DayString.split('/')[2]),
                                      int.parse(DayString.split('/')[1]),
                                      int.parse(DayString.split('/')[0]));
      var diff = day.difference(now);
      if (diff.inDays < -2) daysList.removeAt(i);
    }

    //create json object
    for (int i = 0; i < daysList.length; i++){
      daysMap.addAll(daysList[i].getJson());
    }
    map["schedule"] = daysMap;
    return map;
  }

  factory fullSchedule.fromJson(Map<String, dynamic> json){
    return fullSchedule(json);
  }

  fullSchedule copy(){
    Map temp = this.getJson();
    return fullSchedule(temp);
  }

  bool updateSchedule(dayBloc newBloc){
    var dateString = newBloc.date;
    var dayIndex = this.daysList.indexWhere((day) => day.date == dateString);
    if (dayIndex < 0){
      print("added new day "+ newBloc.date);
      this.daysList.add(newBloc);
      return true;
    }
    else{
      var blocList = this.daysList[dayIndex].blocList;
      for (var i = 0; i < blocList.length; i++){
        //check if bloc we wish to insert comes before or after this bloc
        var startStr = blocList[i].getStart().split(":");
        var insStartStr = newBloc.blocList[0].getStart().split(":");
        var start = new DateTime.utc(0, 0, 0, int.parse(startStr[0]), int.parse(startStr[1]));
        var insStart = new DateTime.utc(0, 0, 0, int.parse(insStartStr[0]), int.parse(insStartStr[1]));
        if (insStart == start) return false;
        if (insStart.isAfter(start)) continue;
        else {
          blocList.insert(i, newBloc.blocList[0]);
          if (newBloc.blocList.length == 2) blocList.insert(i+1, newBloc.blocList[1]);
          this.daysList[dayIndex].blocList = blocList;
          return true;
        }
      }
      //if blocList is empty or if all other blocs are before  new one, add new one
      blocList.add(newBloc.blocList[0]);
      if (newBloc.blocList.length == 2) blocList.add(newBloc.blocList[1]);
      this.daysList[dayIndex].blocList = blocList;
      return true;
    }
  }

  Future<bool> refreshSchedule(BuildContext contextIn)async{
    //call function to begin parsing and then send the data to API
    Map JsonBody = this.getJson();
    String body = "1 "+json.encode(JsonBody);

    showDialog(
        context: contextIn,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Container(
            child: CircularProgressIndicator(),
            height: 40,
            width: 40,
            alignment: Alignment.center,
          );
        }
      );
    fullSchedule temp = await sendFetchSchedule(body);
    if (temp != null){
      this.daysList = temp.daysList;
      this.setStatus(temp.getStatus());
      Navigator.of(contextIn).pop();
      return Future.value(true);
    }
    else {
      Navigator.of(contextIn).pop();
      return Future.value(false);
    }
  }

  bool getStatus() => this._status;
  setStatus(bool status){
    _status = status;
  }

}

Future<fullSchedule> sendFetchSchedule(String JsonText) async{
  try{
    final response = await http.post('http://securityremote.ddns.net/api/setStatus.php',body: JsonText);
    if (response.statusCode != 201) {return null;}
    final response2 = await http.get('http://securityremote.ddns.net/api/getStatus.php');
    if (response2.statusCode == 200){
      await Future.delayed(Duration(seconds: 2));
      return fullSchedule.fromJson(json.decode(response2.body.substring(2)));
    }
    else {
      return null;
    }} catch(_){
     return null;
  }

}

Future<fullSchedule> fetchSchedule() async {
  final response = await http.get('http://securityremote.ddns.net/api/getStatus.php');
  if (response.statusCode == 200){
    return fullSchedule.fromJson(json.decode(response.body.substring(2)));
  }
  else {
    throw Exception('Failed to load from server');
  }
}



//this class contains information of each time block
class timeBloc {
  String _code, _start, _end, _progress;

  timeBloc(this._code, this._start, this._end, this._progress);
  timeBloc.fromJson(Map<String, dynamic> timeMap){
    _code = timeMap['code'];
    _start = timeMap['start'];
    _end = timeMap['end'];
    _progress = timeMap['progress'];
  }

  String getCode() => this._code;
  String getStart() => this._start;
  String getEnd() => this._end;
  String getProgress() => this._progress;

  Map getJson(){
    var tempMap = Map<String, dynamic>();
    tempMap["code"] = _code;
    tempMap["start"] = _start;
    tempMap["end"] = _end;
    tempMap["progress"] = _progress;
    return tempMap;
  }
}


//this class contains all blocks for a single day

class dayBloc {
  String date;
  var blocList = <timeBloc>[];

  dayBloc(this.date, this.blocList);

  dayBloc.fromJson(String d, List<dynamic> dayList){
    date = d;
    for (var i = 0; i < dayList.length; i++){
      blocList.add(timeBloc.fromJson(dayList[i]));
    }
  }

  Map getJson(){
    var list = List<Map>();
    for (var i = 0; i < blocList.length; i++){
      list.add(blocList[i].getJson());
    }
    var map = Map<String, dynamic>();
    map[date] = list;
    return map;
  }
}

