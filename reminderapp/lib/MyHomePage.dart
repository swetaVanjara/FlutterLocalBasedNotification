import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:reminderapp/MainHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
as bg;

import 'Animation/FadeAnimation.dart';
// constants in shareable preferences
final homeLocationKey = 'my_home_location';
final homeLatitudeKey = 'my_home_latitude';
final homeLongitudeKey = 'my_home_longitude';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

const kGoogleApiKey = 'AIzaSyAPmqapIjR7x9eUarQs__5e-rnthnAbBiI';
GoogleMapsPlaces _places;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _infoController;
  TextEditingController _locationController;

  String _locationText;
  String _info = 'Unknown';
  double _homeLatitude;
  double _homeLongitude;

  Future<Map> _init() async {


    // Initialize local notifications plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);


    _infoController=TextEditingController();
    _locationController=TextEditingController();

    final prefs = await SharedPreferences.getInstance();
    final result = {
      'homeLocation': prefs.getString(homeLocationKey) ?? 'Unknown',
      'homeLatitude': prefs.getDouble(homeLatitudeKey) ?? null,
      'homeLongitude': prefs.getDouble(homeLongitudeKey) ?? null
    };
    return result;
  }

  // this is called when user selects new address from the Google PlacesAutoComplete widget
  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      var address = await Geocoder.local.findAddressesFromQuery(p.description);
      // update the state and update the values in shared preferences for persistence
      setState(() {
        _homeLatitude = detail.result.geometry.location.lat;
        _homeLongitude = detail.result.geometry.location.lng;
        _locationController.text=p.description;

      });
      await _saveHomeLocation();

      // update the geofence
      //  _addGeofence();
    }
  }

  // error handler for PlacesAutoComplete
  void onError(PlacesAutocompleteResponse response) {
    print('onError:');
    print(response.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill
                      )
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeAnimation(1, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-1.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(1.3, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/light-2.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(1.5, Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/images/clock.png')
                              )
                          ),
                        )),
                      ),
                      Positioned(
                        child: FadeAnimation(1.6, Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text("REMINDERS", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(1.8, Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(143, 148, 251, .2),
                                  blurRadius: 20.0,
                                  offset: Offset(0, 10)
                              )
                            ]
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey[100]))
                              ),
                              child: TextField(
                                controller: _infoController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter an info",
                                    hintStyle: TextStyle(color: Colors.grey[400])
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap:() async {
                                _places = new GoogleMapsPlaces(apiKey: kGoogleApiKey);
                                //PlacesSearchResponse response = await places.searchByText("123 Main Street");

                                Prediction p = await PlacesAutocomplete.show(
                                    context: context,
                                    apiKey: kGoogleApiKey,
                                    onError: onError,
                                    mode: Mode.overlay);

                                await displayPrediction(p);
                              } ,
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _locationController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Select Location",
                                      hintStyle: TextStyle(color: Colors.grey[400])
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                      SizedBox(height: 30,),
                      GestureDetector(
                        onTap: _addReminder,
                        child: FadeAnimation(2, Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(143, 148, 251, 1),
                                    Color.fromRGBO(143, 148, 251, .6),
                                  ]
                              )
                          ),
                          child: Center(
                            child: Text("Add Reminder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          ),
                        )),
                      ),
                      SizedBox(height: 70,),

                    ],
                  ),
                )
              ],
            ),
          ),
        )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();


    // This is the proper place to make the async calls
    // This way they only get called once

    // read saved values from shared preferences and assign them to the app variables
    _init().then((result) {
      setState(() {
        _info = result['homeLocation'];
        _homeLatitude = result['homeLatitude'];
        _homeLongitude = result['homeLongitude'];
      });

      // add geofence if coordinates are set
      if (_homeLatitude != null && _homeLongitude != null) {
        _addGeofence();
      }
    });

    // set background geolocation events
    bg.BackgroundGeolocation.onGeofence(_onGeofence);


    // Configure the plugin and call ready
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: false, // true
        logLevel: bg.Config.LOG_LEVEL_OFF // bg.Config.LOG_LEVEL_VERBOSE
    ))
        .then((bg.State state) {
      if (!state.enabled) {
        // start the plugin
        // bg.BackgroundGeolocation.start();

        // start geofences only
        bg.BackgroundGeolocation.startGeofences();
      }
    });
  }

  //button click of reminder
  void _addReminder() async {
    // _latitudeController.text="21.2316168";
    // _longitudeController.text="72.9000297";

    if(_infoController.text!=null && _locationController.text!=null){
      _info = _infoController.text;
      _saveHomeLocation();
      // update the geofence
      _addGeofence();
      _infoController.text="";
      _locationController.text="";

      Fluttertoast.showToast(
          msg: "Reminder added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );

    }

  }
 //Show local notification when you at in desired location
  void _onGeofence(bg.GeofenceEvent event) {
    print('onGeofence $event');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics, iOS: IOSNotificationDetails());
    flutterLocalNotificationsPlugin
        .show(0, 'You have arrived Target -the address', 'Don\'t forget to ' +_info+"!", platformChannelSpecifics)
        .then((result) {})
        .catchError((onError) {
      print('[flutterLocalNotificationsPlugin.show] ERROR: $onError');
    });
  }
  // update values in shared preferences
  Future<void> _saveHomeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('my_home_location', _infoController.text);
    prefs.setDouble('my_home_latitude', _homeLatitude);
    prefs.setDouble('my_home_longitude',_homeLongitude);
  }

   // It's work in backgroound to check if you are in at location   // update the geofence
  void _addGeofence() {
    bg.BackgroundGeolocation.addGeofence(bg.Geofence(
      identifier: _info,
      radius: 500,
      latitude: _homeLatitude,
      longitude: _homeLongitude,
      notifyOnEntry: true, // only notify on entry
      notifyOnExit: false,
      notifyOnDwell: false,
      loiteringDelay: 30000, // 30 seconds
    )).then((bool success) {
      print('[addGeofence] success with $_homeLatitude and $_homeLongitude');
    }).catchError((error) {
      print('[addGeofence] FAILURE: $error');
    });
  }
}