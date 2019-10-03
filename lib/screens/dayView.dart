import 'package:flutter/material.dart';
import '../models/timeBloc.dart';
import 'package:intl/intl.dart';
import 'mainListView.dart';
import 'newEvent.dart';

class dayView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _dayViewState();
  }
}


class _dayViewState extends State<dayView> {
  Future<fullSchedule> _schedule;
  String _dayName = 'Today';
  var todayDT = (new DateTime.now().toUtc()).subtract(Duration(hours: 3));
  var ViewDate = (new DateTime.now().toUtc()).subtract(Duration(hours: 3));


  _pressedChangeDay(int add) {
    setState(() {
      if (add == 1)
        ViewDate = ViewDate.add(Duration(days: 1));
      else
        ViewDate = ViewDate.subtract(Duration(days: 1));
      Duration tempDiff = ViewDate.difference(todayDT);
      Duration absDiff = tempDiff.abs();
      if (absDiff.inSeconds < 5) {
        _dayName = 'Today';
      }
      else if (tempDiff.inHours < -1) {
        if (tempDiff.inHours < -49)
          ViewDate = ViewDate.add(Duration(days: 1));
        else
          _dayName = (new DateFormat("EEEE, MMM d").format(ViewDate));
      }
      else if (tempDiff.inHours >= 1)
        _dayName = (new DateFormat("EEEE, MMM d").format(ViewDate));
    });
  }

  Widget switchFuture() {
    return FutureBuilder<fullSchedule>(
      future: _schedule,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Switch(
            value: snapshot.data.getStatus(),
            onChanged: (value) {
              _sendSwitchServer(context, value);
            },
            activeColor: Colors.green,);
        }
        return Switch(
          value: false,
          onChanged: null,
        );
      },
    );
  }

  Widget DayList() {
    Duration tempDiff = ViewDate.difference(todayDT);
    int day;
    if (tempDiff
        .abs()
        .inSeconds < 5)
      day = 0;
    else if (tempDiff.inHours < -1)
      day = -1;
    else
      day = 1;

    return FutureBuilder<fullSchedule>(
        future: _schedule,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildList(snapshot.data, ViewDate, day, context);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 10, maxWidth: 10),
            child: CircularProgressIndicator(),
          );
        }
    );
  }


  @override
  void initState() {
    super.initState();
    _schedule = fetchSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.5,
        title: Text('Security Remote'),
        actions: [
          switchFuture(),
        ],
      ),
      floatingActionButton: Builder(
          builder: (BuildContext Scaffcontext) {
            return FloatingActionButton(
              onPressed: () {
                _newEventPressed(Scaffcontext);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blueGrey,);
          }
      ),
      body: Column(children: [
        Container(
            decoration: new BoxDecoration(
                color: Color.fromRGBO(58, 66, 86, 1.0)),
            child:
            ListTileTheme(
              textColor: Colors.white,
              child: ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    onPressed: () {
                      _pressedChangeDay(0);
                    },
                  ),
                  title: Text(_dayName, textAlign: TextAlign.center,),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                    onPressed: () {
                      _pressedChangeDay(1);
                    },
                  )
              ),
            )
        ),
        DayList(),
      ]),
    );
  }


  _newEventPressed(BuildContext context) async{
    final result = await Navigator.push(context,
      new MaterialPageRoute(builder: (context) => new newEventViewStateless()),
    );
    if (result == null) return;

    var successful;
    fullSchedule OldSchedule;
    //update _schedule
    _schedule.then((schedule) {
      OldSchedule = schedule.copy();
      schedule.updateSchedule(result);
      successful = schedule.refreshSchedule(context);
    });

    while (successful.toString() == "null") await new Future.delayed(Duration(milliseconds: 100));

    successful.then((val) {

      if (val==true){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Added successfuly"),
                                                      duration: Duration(seconds: 3),));
      }
      else {
        setState(() {
          _schedule = Future<fullSchedule>.value(OldSchedule);
        });
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Could not reach server. Did not add task"),
          duration: Duration(seconds: 4),));
      }
    });
}

  _sendSwitchServer(BuildContext context, bool value)async{
    var successful;
    bool oldVal;
    _schedule.then((schedule) {
      oldVal = schedule.getStatus();
      setState(() {
        schedule.setStatus(value);
        successful = schedule.refreshSchedule(context);
      });

    });
    while (successful.toString() == "null") await new Future.delayed(Duration(milliseconds: 100));
    successful.then((val) {

      if (val==true){
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Successfully changed status!"),
          duration: Duration(seconds: 2),));
      }
      else {
        setState(() {
          _schedule.then((schedule){
            schedule.setStatus(oldVal);
          });
        });
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("Could not reach server. Did not change status!"),
          duration: Duration(seconds: 3),));
      }
    });
  }

  Widget buildList (fullSchedule schedule, DateTime viewDate, int day, BuildContext specialContext){
    String dayString = new DateFormat('dd/MM/yyyy').format(viewDate);
    var dayIndex = schedule.daysList.indexWhere((day) => day.date == dayString);
    var Position;
    if (dayIndex < 0) return Text('');
    else return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: schedule.daysList[dayIndex].blocList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTapDown: (pos) {
            Position = pos.globalPosition;
          },
          onLongPress: (){
            final RenderBox overlay = Overlay.of(context).context.findRenderObject();
            showMenu(
              context: context,
              position: RelativeRect.fromRect(
                  Position & Size(40, 40), // smaller rect, the touch area
                  Offset.zero & overlay.size   // Bigger rect, the entire screen
              ),
              items: <PopupMenuEntry>[
                PopupMenuItem(
                  value: index,
                  child:  Row(
                    children: <Widget>[
                      Icon(Icons.delete),
                      Text("Delete"),
                    ],
                  ),
                )
              ],
            ).then<void>((i){
              if (i == null) return;
              _deleteFromServer(dayIndex, i, specialContext);

            });
          },
          child: createCard(schedule.daysList[dayIndex].blocList[index], viewDate, day),
        );
      },
    );
  }

  _deleteFromServer(int dayIndex, int i, BuildContext specialContext)async{
    fullSchedule OldSchedule;
    var successful;
    _schedule.then((schedule){
      OldSchedule = schedule.copy();
      setState(() {
        schedule.daysList[dayIndex].blocList.removeAt(i);
        successful = schedule.refreshSchedule(context);
      });
    });

    while (successful.toString() == "null") await new Future.delayed(Duration(milliseconds: 100));
    successful.then((val) {

      if (val==true){
        Scaffold.of(specialContext).removeCurrentSnackBar();
        Scaffold.of(specialContext).showSnackBar(SnackBar(content: Text("Deleted successfully!"),
          duration: Duration(seconds: 1),));
      }
      else {
        setState(() {
          _schedule = Future<fullSchedule>.value(OldSchedule);
        });
        Scaffold.of(specialContext).removeCurrentSnackBar();
        Scaffold.of(specialContext).showSnackBar(SnackBar(content: Text("Could not reach server. Did not delete!"),
          duration: Duration(seconds: 4),));
      }
    });
  }

}