import 'package:background_fetch/background_fetch.dart';
import 'package:covid/App_localizations.dart';
import 'package:covid/Models/TextStyle.dart';
import 'package:covid/Models/HistoryModel.dart';
import 'package:intl/intl.dart';
import 'package:covid/Models/config/Configure.dart';
import 'package:covid/Models/config/env.dart';
import 'package:covid/Models/config/shared_events.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:covid/Models/util/dialog.dart' as util;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<HistoryPage> with TickerProviderStateMixin {
  TextStyleFormate styletext = TextStyleFormate();
  GoogleMapController _googleMapController;
  bool isSwitched = true;
  int id;
  String radioItem = '';
  Configure _configure = new Configure();
  List<Event> events = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isMoving;
  bool _enabled;
  String _motionActivity;
  String _odometer;
  String orgname;
  String username;
  List<History> historylist;
  var _config;
  HistoryModel historyModel;
  List<Event> list;
  List<RadioList> fList = [
    RadioList(
      index: 1,
      name: "Getting better",
    ),
    RadioList(
      index: 2,
      name: "Getting worse",
    ),
    RadioList(
      index: 3,
      name: "Remaining same",
    ),
  ];
  @override
  void initState() {
    super.initState();
    getJsondata();
    //_autoRegister();
    _isMoving = false;
    _enabled = false;
    _odometer = '0';
    //initPlatformState();
  }
Future<String> getJsondata() async { 
  _config = _configure.serverURL();
    String historyurl = _config.sit +
        "/history?userId=1";
    var historyresponse;
    try {
      historyresponse =
          await http.get(Uri.encodeFull(historyurl), headers: {
        "Accept": "*/*",
        //'Authorization': 'Bearer ',
        'x-api-key':_config.apikey
      });
    } catch (ex) {
      print('error $ex');
    }
    setState(() {
       historyModel = historyModelFromJson(historyresponse.body);
       historylist=historyModel.history;
    });
    return "Success";
  }

 
  @override
  Widget build(BuildContext context) {
    
    return Container(
        //color: Color.fromRGBO(20, 20, 20, 1.0),
        //color: Colors.white,
        padding: EdgeInsets.all(5.0),
        child:  historylist == null
                                  ? Center(
                                      child: Container(
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                              child:
                                                  const CircularProgressIndicator(
                                            strokeWidth: 3,
                                          ))),
                      
                                    )
                                  : RefreshIndicator(
                                      onRefresh: getJsondata,
                                      child: historylist.length == 0
                                          ? ListView(
                                              children: <Widget>[
                                                Container(
                                                  // color: Colors.red,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      1.4,
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                        'No history',
                                                        style: styletext
                                                            .emptylist()),
                                                  ),
                                                ),
                                              ],
                                            ):ListView.builder(
            itemCount: historylist.length,
            itemBuilder: (BuildContext context, int index) =>
            
            //  InputDecorator(
            //     decoration: InputDecoration(
            //         //contentPadding: EdgeInsets.only(left: 5.0, top: 0.0, bottom: 5.0),
            //        // isDense: true,
            //        // labelStyle: TextStyle(color: Colors.blue, fontSize: 24.0, fontWeight: FontWeight.bold),
            //        // labelText: historylist[index].israiseyourhand==true?'Raise your hand update':'Update health',
            //     ),
            //     child: 
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Column(children: <Widget>[
                      Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                             // dense: true,
                              // leading: Padding(
                              //   padding: const EdgeInsets.only(bottom: 30),
                              //   child: Icon(Icons.album),
                              // ),
                              title: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Wrap(children: <Widget>[
                                 historylist[index].israiseyourhand==true? Text(
                                    '${DateFormat.yMMMd().format(historylist[index].timestamp)} Raise your hand',
                                    style: styletext.cardfont(),
                                  ):Text('${DateFormat.yMMMd().format(historylist[index].timestamp)} Update health info',style:styletext.cardfont(),),
                                ]),
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, right: 0, bottom: 10),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                    ),
                                  historylist[index].ishealthupdated==true? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context).translate('cough'),
                                          style: styletext.placeholderStyle(),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                             historylist[index].hascough==true? Text(
                                                'Yes',
                                                style: styletext.labelfont(),
                                              ):Text(
                                                'No',
                                                style: styletext.labelfont(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ):Container(),
                                 historylist[index].ishealthupdated==true?   Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context).translate('fever'),
                                          style: styletext.placeholderStyle(),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                            child: Row(
                                          children: <Widget>[
                                             historylist[index].hasfever==true? Text(
                                                'Yes',
                                                style: styletext.labelfont(),
                                              ):Text(
                                                'No',
                                                style: styletext.labelfont(),
                                              ),
                                          ],
                                        )),
                                      ],
                                    ):Container(),
                                   historylist[index].ishealthupdated==true? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context).translate('chills'),
                                          style: styletext.placeholderStyle(),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                               historylist[index].haschills==true? Text(
                                                'Yes',
                                                style: styletext.labelfont(),
                                              ):Text(
                                                'No',
                                                style: styletext.labelfont(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ):Container(),
                                   historylist[index].ishealthupdated==true? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Do you have breathing difficulty ?',
                                          style: styletext.placeholderStyle(),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                               historylist[index].hasbreathingissue==true? Text(
                                                'Yes',
                                                style: styletext.labelfont(),
                                              ):Text(
                                                'No',
                                                style: styletext.labelfont(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ):Container(),
                                    historylist[index].israiseyourhand==true? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Contact quarantine officer',
                                          style: styletext.placeholderStyle(),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                               historylist[index].hasbreathingissue==true? Text(
                                                'Yes',
                                                style: styletext.labelfont(),
                                              ):Text(
                                                'No',
                                                style: styletext.labelfont(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ):Container(),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          AppLocalizations.of(context).translate('timestamp'),
                                          style: styletext.placeholderStyle(),
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                '${DateFormat.yMMMd().format(historylist[index].timestamp)}',
                                                style: styletext.labelfont(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      
                      

                      // SizedBox(height: 10,),
                    ]),
                  ),
                )
            )
        )
    );
  }
}

class RadioList {
  String name;
  int index;
  RadioList({this.name, this.index});
}
