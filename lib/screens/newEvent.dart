import 'dayView.dart';
import 'package:flutter/material.dart';
import '../models/timeBloc.dart';
import 'package:intl/intl.dart';
import 'mainListView.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

class newEventViewStateless extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return newEventView();
  }
}

class newEventView extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _newEventState();
  }
}

class _newEventState extends State<newEventView>{

  bool _tvOn = true;
  bool createOFF = true;
  DateTime now = (new DateTime.now().toUtc()).subtract(Duration(hours: 3));
  DateTime date1 = (new DateTime.now().toUtc()).subtract(Duration(hours: 3));
  DateTime date2 = (new DateTime.now().toUtc()).subtract(Duration(hours: 3));
  int channel;
  int volume;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("New Event"),
        actions: [
          RaisedButton(
            onPressed: (){
              returnPage(context);
            },
            child: Text("Save", style: TextStyle(fontSize: 18,
                                    color: Colors.blueAccent),),
            color: Color.fromRGBO(58, 66, 86, 1.0),
          )
        ],
      ),
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      body: Form(
        key: _formKey,
        child: _createColumn(),
      ),
    );
  }

  Widget _createColumn(){
    return ListView(
      children: [
        _row1(),
        _row2(),
        _row3(),
        _checkRow23(),
        _row4(),
        _row5(),
        //_debugRow(),
      ],
    );
  }


  Widget _row1(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          child: Text("TV  ", style:
                  TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Switch(
            value: _tvOn,
            activeColor: Colors.green,
            inactiveThumbColor: Colors.redAccent,
            onChanged: (value){
              setState(() {
                _tvOn = value;
                if (value == false){
                  createOFF = false;
                }
              });

            },
          ),
        )
      ]
    );
  }

  Widget _row2(){
    return DateTimePickerWidget(
      minDateTime: now,
      maxDateTime: DateTime.now().toUtc().add(Duration(days: 100)),
      initDateTime: date1,
      dateFormat: "EEEE, MMM d H:mm",
      locale: DATETIME_PICKER_LOCALE_DEFAULT,
      pickerTheme: DateTimePickerTheme(
          title: Column(
            children: [
              Text("Start", style:
                TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
            ],
          ),
          backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
          pickerHeight: 140,
          itemTextStyle: TextStyle(fontSize: 15, color: Colors.white, fontStyle: FontStyle.italic),
      ),

      onChange: (date_time, ints){
        setState(() {
          date1 = date_time;
        });
      },
    );
  }

  Widget _row3(){
    return DateTimePickerWidget(
      minDateTime: now,
      maxDateTime: DateTime.now().toUtc().add(Duration(days: 100)),
      initDateTime: date2,
      dateFormat: "EEEE, MMM d H:mm",
      locale: DATETIME_PICKER_LOCALE_DEFAULT,
      pickerTheme: DateTimePickerTheme(
        title: Column(
          children: [
            Text("End", style:
            TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
          ],
        ),
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        pickerHeight: 140,
        itemTextStyle: TextStyle(fontSize: 15, color: Colors.white, fontStyle: FontStyle.italic),
      ),

      onChange: (date_time, ints){
        setState(() {
          date2 = date_time;
        });
      },
    );
  }

  Widget _row4(){
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 5, 20),
            child: Text("Channel:  ", style:
            TextStyle(fontSize: 20, color: (_tvOn)? Colors.white : Colors.grey, fontWeight: FontWeight.bold),),
            alignment: Alignment.center,
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              width: 80,
              child: TextFormField(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  hintText: ' #',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  border: UnderlineInputBorder(),
                ),
                cursorColor: Colors.white70,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                validator: (value) {
                  var c = int.tryParse(value);
                  if (value.isEmpty || (c == null) || (int.parse(value) > 1800)
                      || (int.parse(value) < 100)) {
                    return 'Invalid';
                  }
                  setState(() {
                    channel = c;
                  });
                },
                maxLines: 1,
                keyboardType: TextInputType.number,

              ),
          )),
          Container(
            margin: EdgeInsets.fromLTRB(15, 20, 5, 20),
            child: Text("Volume:  ", style:
              TextStyle(fontSize: 20, color: (_tvOn)? Colors.white : Colors.grey, fontWeight: FontWeight.bold),),
          alignment: Alignment.center,
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
              width: 60,
              child: TextFormField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(5),
                hintText: ' #',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  ),
                ),
              cursorColor: Colors.white70,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                ),
              validator: (value) {
                var v = int.tryParse(value);
                if (value.isEmpty || (v == null) || (int.parse(value) > 100)) {
                  return 'Invalid';
                  }
                setState(() {
                  volume = v;
                });
                },
              maxLines: 1,
              keyboardType: TextInputType.number,
              ),
            ))
        ]
    );
  }

  Widget _checkRow23(){
    if ((date1.year != date2.year) ||
        (date1.month != date2.month) ||
        (date1.day != date2.day)){
      return Container(
        alignment: Alignment.center,
        child: Text("An event must start and end on the same day!", style:
              TextStyle(fontSize: 13, color: Colors.red),),
      );
    }
    else if ((date1.hour > date2.hour) ||
        ((date1.hour == date2.hour)&&(date1.minute > date2.minute))){
      return Container(
        alignment: Alignment.center,
        child: Text("The event must start before it has finished (jokes on you)", style:
        TextStyle(fontSize: 13, color: Colors.red),),
      );
    }
    else return Text('');
  }
  
  Widget _row5(){
    return Row(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(5, 20, 5, 0),
          child: Checkbox(
            tristate: false,
            value: createOFF,
            onChanged: (value){
            setState(() {
              createOFF = value;
              if (_tvOn == false) createOFF = false;
              });
            },
            activeColor: Colors.green,
            checkColor: Color.fromRGBO(58, 66, 86, 1.0),
            ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(10, 20, 0, 0),
          child: Text('Turn off after the event has finished',
                    style: TextStyle(fontSize: 15, color: Colors.white, fontStyle: FontStyle.italic),),
        )
      ],
    );
  }

  Widget _debugRow(){
    return Text(channel.toString() + "   " + volume.toString());
  }

  returnPage(BuildContext context){
    bool valid = (_formKey.currentState.validate() &&
        (date1.year == date2.year) &&
            (date1.month == date2.month) &&
            (date1.day == date2.day) &&
              ((date1.hour < date2.hour) ||
                  ( (date1.hour == date2.hour)&&(date1.minute < date2.minute) )));

    bool validOff = ((date1.year == date2.year) &&
        (date1.month == date2.month) &&
        (date1.day == date2.day) &&
        (   (date1.hour < date2.hour) ||
            ((date1.hour == date2.hour)&&(date1.minute < date2.minute))   ) &&
            (!_tvOn));
    if (valid || validOff){
      //create the necessary timeblocs and then add them to a day bloc
      //create main time bloc
      String code;
      if (!_tvOn){
        code = "D 0000 00";
      } else {
        code = "A " + channel.toString() + " " + volume.toString();
      }
      String progress = "0";
      String start = DateFormat("HH:mm").format(date1);
      String end = DateFormat("HH:mm").format(date2);
      if (_tvOn && (date2.hour==23) && (date2.minute > 58)){
        date2.subtract(Duration(minutes: 2));
      }

      var temp = timeBloc(code, start, end, progress);

      var templist = <timeBloc>[];
      templist.add(temp);

      //if create tv off, create another timebloc
      if (createOFF){
        String addEnd = DateFormat("HH:mm").format(date2.add(Duration(minutes: 1)));
        var temp2 = timeBloc("D 0000 00", end, addEnd, "0");
        templist.add(temp2);
      }

      //create dayBloc
      String date = DateFormat("dd/MM/yyyy").format(date1);
      var tempDay = dayBloc(date, templist);

      Navigator.pop(context, tempDay);
    }
  }

}