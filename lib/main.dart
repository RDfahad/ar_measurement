import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:practice/camera_position_scene.dart';
import 'package:practice/check_support_page.dart';
import 'package:practice/custom_animation_page.dart';
import 'package:practice/custom_light_page.dart';
import 'package:practice/custom_measurement.dart';
import 'package:practice/custom_object_page.dart';
import 'package:practice/distance_tracking_page.dart';
import 'package:practice/earth_page.dart';
import 'package:practice/face_detection_page.dart';
import 'package:practice/hello_world.dart';
import 'package:practice/image_detection_page.dart';
import 'package:practice/light_estimate_page.dart';
import 'package:practice/load_gltf.dart';
import 'package:practice/manipulation_page.dart';
import 'package:practice/measure_page.dart';
import 'package:practice/midas_page.dart';
import 'package:practice/network_image_detection.dart';
import 'package:practice/occlusion_image.dart';
import 'package:practice/panorama_updates.dart';
import 'package:practice/physics_page.dart';
import 'package:practice/plane_detection_page.dart';
import 'package:practice/real_time.dart';
import 'package:practice/snapshot_scene.dart';
import 'package:practice/tap_page.dart';
import 'package:practice/video_page.dart';
import 'package:practice/widget_projection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: AppStart(),
        // body: GestureDetector(
        //   onPanStart: (details){
        //     print('start');
        //   },
        //   // onPanUpdate: (details){
        //   //   print('updating');
        //   // },
        //   onLongPressStart: (details){
        //     Timer.periodic(Duration(milliseconds: 50), (timer) {
        //       print('longg press');
        //     });
        //   },
        //   child: Container(
        //     height: 200,
        //     width: 200,
        //     color: Colors.red,
        //     padding: EdgeInsets.all(100),
        //   ),
        // ),
      ),
    );
  }
}




