import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
// import 'package:nfc_manager/nfc_manager.dart';

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
      home: const AppStart(),
    );
  }
}

class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  late ARKitController arkitController;
  ARKitPlane? plane;
  ARKitNode? node;
  String? anchorId;
  vector.Vector3? lastPosition;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Distance Tracking Sample')),
    body: Container(
      child: ARKitSceneView(
        showFeaturePoints: true,
        planeDetection: ARPlaneDetection.horizontal,
        onARKitViewCreated: onARKitViewCreated,
        enableTapRecognizer: true,
      ),
    ),
  );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      final planeTap = ar.firstWhere(
            (tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent,
      );
      if (planeTap != null) {
        _onPlaneTapHandler(planeTap.worldTransform);
      }
    };
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (!(anchor is ARKitPlaneAnchor)) {
      return;
    }
    _addPlane(arkitController, anchor);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor.identifier != anchorId) {
      return;
    }
    final planeAnchor = anchor as ARKitPlaneAnchor;
    node!.position =
        vector.Vector3(planeAnchor.center.x, 0, planeAnchor.center.z);
    plane?.width.value = planeAnchor.extent.x;
    plane?.height.value = planeAnchor.extent.z;
  }

  void _addPlane(ARKitController controller, ARKitPlaneAnchor anchor) {
    anchorId = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.z,
      materials: [
        ARKitMaterial(
          transparency: 0.5,
          diffuse: ARKitMaterialProperty.color(Colors.white),
        )
      ],
    );

    node = ARKitNode(
      geometry: plane,
      position: vector.Vector3(anchor.center.x, 0, anchor.center.z),
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
    );
    controller.add(node!, parentNodeName: anchor.nodeName);
  }

  void _onPlaneTapHandler(Matrix4 transform) {
    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );
    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.constant,
      diffuse: ARKitMaterialProperty.color(Color.fromRGBO(255, 153, 83, 1)),
    );
    final sphere = ARKitSphere(
      radius: 0.003,
      materials: [material],
    );
    final node = ARKitNode(
      geometry: sphere,
      position: position,
    );
    arkitController.add(node);
    if (lastPosition != null) {
      final line = ARKitLine(
        fromVector: lastPosition!,
        toVector: position,
      );
      final lineNode = ARKitNode(geometry: line);
      arkitController.add(lineNode);

      final distance = _calculateDistanceBetweenPoints(position, lastPosition!);
      final point = _getMiddleVector(position, lastPosition!);
      _drawText(distance, point);
    }
    lastPosition = position;
  }

  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  vector.Vector3 _getMiddleVector(vector.Vector3 A, vector.Vector3 B) {
    return vector.Vector3((A.x + B.x) / 2, (A.y + B.y) / 2, (A.z + B.z) / 2);
  }

  void _drawText(String text, vector.Vector3 point) {
    final textGeometry = ARKitText(
      text: text,
      extrusionDepth: 1,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.red),
        )
      ],
    );
    const scale = 0.001;
    final vectorScale = vector.Vector3(scale, scale, scale);
    final node = ARKitNode(
      geometry: textGeometry,
      position: point,
      scale: vectorScale,
    );
    arkitController
        .getNodeBoundingBox(node)
        .then((List<vector.Vector3> result) {
      final minVector = result[0];
      final maxVector = result[1];
      final dx = (maxVector.x - minVector.x) / 2 * scale;
      final dy = (maxVector.y - minVector.y) / 2 * scale;
      final position = vector.Vector3(
        node.position.x - dx,
        node.position.y - dy,
        node.position.z,
      );
      node.position = position;
    });
    arkitController.add(node);
  }
}

// class AppStart extends StatefulWidget {
//   const AppStart({super.key});
//
//   @override
//   State<AppStart> createState() => _AppStartState();
// }
//
// class _AppStartState extends State<AppStart> {
//
//   ARKitController? arKitController;
//   ARKitPlane? arKitPlane;
//   ARKitNode? arKitNode;
//   vector.Vector3? lastPosition;
//   String? anchorId;
//
//   void addAnchor(ARKitAnchor arKitAnchor){
//     if(!(arKitAnchor is ARKitPlane)){
//       return;
//     }
//     addPlane(arKitController!, arKitAnchor as ARKitPlaneAnchor);
//   }
//
//   void addPlane(ARKitController arKitController, ARKitPlaneAnchor arKitPlaneAnchor){
//     anchorId = arKitPlaneAnchor.identifier;
//     arKitPlane = ARKitPlane(
//       width: arKitPlaneAnchor.extent.x,
//       height: arKitPlaneAnchor.extent.z,
//       materials: [
//         ARKitMaterial(
//           transparency: 0.5,
//           diffuse: ARKitMaterialProperty.color(Colors.white)
//         )
//       ]
//     );
//
//     arKitNode = ARKitNode(
//       geometry: arKitPlane,
//       position: vector.Vector3(arKitPlaneAnchor.center.x, 0 , arKitPlaneAnchor.center.z),
//       rotation: vector.Vector4(1,0,0,-math.pi / 2)
//     );
//
//     arKitController.add(arKitNode! , parentNodeName: arKitPlaneAnchor.nodeName);
//   }
//
//   updateAnchor(ARKitAnchor arKitPlaneAnchor){
//     // if(arKitPlaneAnchor.identifier != anchorId){
//     //   return;
//     // }
//
//     final ARKitPlaneAnchor arKitPlaneAnc = arKitPlaneAnchor as ARKitPlaneAnchor;
//     arKitNode!.position = vector.Vector3(arKitPlaneAnc.center.x, 0 , arKitPlaneAnc.center.z);
//     arKitPlane?.width.value = arKitPlaneAnc.extent.x;
//     arKitPlane?.height.value = arKitPlaneAnc.extent.z;
//   }
//
//   onTapHandler(Matrix4 transform){
//     final position = vector.Vector3(
//       transform.getColumn(3).x,
//       transform.getColumn(3).y,
//       transform.getColumn(3).z,
//     );
//
//     final material = ARKitMaterial(
//       lightingModelName: ARKitLightingModel.constant,
//       diffuse: ARKitMaterialProperty.color(Colors.orange),
//     );
//
//     final sphere = ARKitSphere(
//       radius: 0.003,
//       materials: [material]
//     );
//
//     final node = ARKitNode(
//       geometry: sphere,
//       position: position
//     );
//
//     arKitController?.add(node);
//
//     if(lastPosition != null){
//       final line = ARKitLine(
//           fromVector: lastPosition!,
//           toVector: position
//       );
//
//       final lineNode = ARKitNode(
//         geometry: line
//       );
//
//       arKitController?.add(lineNode);
//
//       final distance = calculateDistanceBtPnts(position, lastPosition!);
//       final point = getMiddleVector(position, lastPosition!);
//       drawText(distance, point);
//     }
//   }
//
//   String calculateDistanceBtPnts(vector.Vector3 A, vector.Vector3 B){
//     final length = A.distanceTo(B);
//     return '${(length * 100).toStringAsFixed(2)} cm';
//   }
//
//   vector.Vector3 getMiddleVector(vector.Vector3 A, vector.Vector3 B){
//     return vector.Vector3(
//         (A.x + B.x) / 2,
//         (A.y + B.y) / 2,
//         (A.z + B.z) / 2,
//     );
//   }
//
//   void drawText(String textDistance,vector.Vector3 point){
//     final textGeometry = ARKitText(text: textDistance, extrusionDepth: 1,materials: [ARKitMaterial(
//       diffuse: ARKitMaterialProperty.color(Colors.red)
//     )]);
//
//     const scale = 0.001;
//     final vectorScale = vector.Vector3(scale, scale, scale);
//
//     final node = ARKitNode(
//       geometry: textGeometry,
//       position: point,
//       scale: vectorScale
//     );
//
//     arKitController?.getNodeBoundingBox(node).then((List<vector.Vector3> result){
//       final minVector = result[0];
//       final maxVector = result[1];
//
//       final dx = (maxVector.x - minVector.x) / 2 * scale;
//       final dy = (maxVector.y - minVector.y) / 2 * scale;
//
//       final position = vector.Vector3(node.position.x = dx, node.position.y -dy, node.position.x);
//       node.position = position;
//     });
//   }
//
//   onArKitCreated(ARKitController arKitController){
//     this.arKitController = arKitController;
//     this.arKitController?.onAddNodeForAnchor = addAnchor;
//     this.arKitController?.onUpdateNodeForAnchor = updateAnchor;
//     this.arKitController?.onARTap = (List<ARKitTestResult> ar){
//       final planeTap = ar.firstWhere((tap) => tap.type == ARKitHitTestResultType.existingPlaneUsingExtent);
//       if(planeTap != null){
//         onTapHandler(planeTap.worldTransform);
//       }
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Measurement'),
//       ),
//       body: ARKitSceneView(
//         showFeaturePoints: true,
//         planeDetection: ARPlaneDetection.horizontal,
//         onARKitViewCreated: onArKitCreated,
//         enableTapRecognizer: true,
//       ),
//     );
//   }
// }
//

// class mynfc extends StatefulWidget {
//   const mynfc({super.key});
//
//   @override
//   State<mynfc> createState() => _mynfcState();
// }
//
// class _mynfcState extends State<mynfc> {
//
//   void _startNFC() async {
//     // Check availability
//     bool isAvailable = await NfcManager.instance.isAvailable();
//
// // Start Session
//     NfcManager.instance.startSession(
//       onDiscovered: (NfcTag tag) async {
//         // Do something with an NfcTag instance.
//       },
//     );
//
// // Stop Session
//     NfcManager.instance.stopSession();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  Container();
//   }
// }


