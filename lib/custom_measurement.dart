import 'dart:developer';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math' as math;



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
  vector.Vector3? firstPosition;
  bool isCreated = false;
  List<ARKitNode> addedNodes = [];
  double totalDistance = 0;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // appBar: AppBar(title: const Text('Distance Tracking Sample')),
    body: Container(
      child: Stack(
        children: [

          ARKitSceneView(
            showFeaturePoints: true,
            planeDetection: ARPlaneDetection.horizontalAndVertical,
            onARKitViewCreated: onARKitViewCreated,
            enableTapRecognizer: true,
            forceUserTapOnCenter: true,
            enableRotationRecognizer: true,
            environmentTexturing: ARWorldTrackingConfigurationEnvironmentTexturing.automatic,
            // showWorldOrigin: true,
            // worldAlignment: ARWorldAlignment.camera,
            // forceUserTapOnCenter: true,
          ),
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height* 0.1,
            alignment: Alignment.bottomCenter,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(totalDistance.toStringAsFixed(2) + ' cm'),),
          ),
          isCreated ? Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle
              ),
            ),
          ):Container(),
          GestureDetector(
            onTap: (){
              // arkitController.node
              for (var node in addedNodes) {
                arkitController.remove(node.name);
              }
              lastPosition = null;
              totalDistance = 0;
              addedNodes.clear();
              firstPosition = null;
              setState(() {

              });
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 50),
                width: 150,
                height: 70,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Center(
                  child: Text('Clear',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
    this.arkitController.addCoachingOverlay(CoachingOverlayGoal.anyPlane);
    this.arkitController.onCameraDidChangeTrackingState = (arTrackingState, arTrackingStateReason)async{
      if(arTrackingState == ARTrackingState.normal){
        // var testResult = await this.arkitController.performHitTest(x: 1, y: 1);
        // _onPlaneTapHandler(testResult.first.worldTransform);
      }
      print(arTrackingState.name);
      print(arTrackingStateReason?.index ?? 'asd');
    };
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      final planeTap = ar.firstWhere(
            (tap) => tap.type == ARKitHitTestResultType.featurePoint,
      );
      if (planeTap != null) {
        // _onButtonTap();
        // log(planeTap.worldTransform.toString());

        log(planeTap.worldTransform.toString());
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
    setState(() {
      isCreated = true;
    });
    anchorId = anchor.identifier;
    plane = ARKitPlane(
      width: anchor.extent.x,
      height: anchor.extent.z,
      materials: [
        ARKitMaterial(
          transparency: 0.0,
          diffuse: ARKitMaterialProperty.color(Colors.white),
        )
      ],
    );

    // arkitController.onNodePan = (List<ARKitNodePanResult> nodePans){
    //   print('asdnjasbds');
    // };

    node = ARKitNode(
      geometry: plane,
      position: vector.Vector3(anchor.center.x, 0, anchor.center.z),
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
    );
    controller.add(node!, parentNodeName: anchor.nodeName);
  }

  void _onButtonTap() async {
    // Calculate the center of the screen
    var cameraPosition = await arkitController.cameraPosition();
    // final screenSize = MediaQuery.of(context).size;
    // final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // Convert the screen center to a Matrix4
    final screenCenterVector = await arkitController.projectPoint(vector.Vector3(
      0,
      0,
      0, // Depth can be adjusted as per requirement
    ));

    Matrix4 matrix4 = Matrix4.identity(); // Identity matrix

// Convert Vector3 to Matrix4
    matrix4.setTranslation(vector.Vector3(
      cameraPosition!.x,//screenCenterVector!.x,
      cameraPosition.y,//screenCenterVector.y,
      cameraPosition.z,//screenCenterVector.z,
    ));
    // cameraPosition.bbbg
    // final centerMatrix = Matrix4.identity()
    //   ..setEntry(0, 3, screenCenterVector!.x)
    //   ..setEntry(1, 3, screenCenterVector.y)
    //   ..setEntry(2, 3, screenCenterVector.z);
    //
    // // Call _onPlaneTapHandler with the center Matrix4
    //
    // final screenSize = MediaQuery.of(context).size;
    //
    // // Create a point in 3D space corresponding to the screen center
    // final screenCenterPoint = await arkitController.projectPoint(
    //   vector.Vector3(
    //     screenSize.width / 2,
    //     screenSize.height / 2,
    //     0.0, // Depth can be adjusted as per requirement
    //   ),
    // );
    //
    // // Create a matrix representing the transformation
    // final centerMatrix = Matrix4.compose(
    //   vector.Vector3.zero(), // Translation
    //   vector.Quaternion.identity(), // Rotation
    //   vector.Vector3.all(0.5), // Scale
    // )..setTranslation(vector.Vector3(
    //   screenCenterPoint!.x,
    //   screenCenterPoint.y,
    //   screenCenterPoint.z,
    // ));

    // Call _onPlaneTapHandler with the center Matrix4
    // log(centerMatrix.toString());
    _onPlaneTapHandler(matrix4);
  }

  void _onPlaneTapHandler(Matrix4 transform) async {
    // this.arkitController.performHitTest(x: MediaQuery.of(context).size.width /2, y: MediaQuery.of(context).size.height /2).then((value) {
    //   print('hittsssss');
    //   print(value.firstOrNull);
    //   final planeTap = value.firstWhere(
    //         (tap) => tap.type == ARKitHitTestResultType.existingPlane,
    //   );
    //   if (planeTap != null) {
    //     // _onButtonTap();
    //     // log(planeTap.worldTransform.toString());
    //
    //     log(planeTap.worldTransform.toString());
    //     // _onPlaneTapHandler(planeTap.worldTransform);
    //   }
    // });
    // var cameraPosition = await arkitController.cameraPosition();
    var position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );
    String? firstPositionDistance;
    if(firstPosition != null) {
      firstPositionDistance = _calculateDistanceBetweenPoints(
          position, firstPosition!);
      if(double.parse(firstPositionDistance) <= 1){
        position = firstPosition!;
      }
    }
    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.constant,
      diffuse: ARKitMaterialProperty.color(Colors.white),
    );
    final sphere = ARKitSphere(
      radius: 0.004,
      materials: [material],
    );
    final node = ARKitNode(
      geometry: sphere,
      position: position,
    );
    // arkitController.ce
    arkitController.add(node);
    addedNodes.add(node);
    if (lastPosition != null) {
      final line = ARKitLine(
        fromVector: lastPosition!,
        toVector: position,
      );
      final lineNode = ARKitNode(geometry: line,name: 'lineN');
      arkitController.add(lineNode);
      addedNodes.add(lineNode);

      final distance = _calculateDistanceBetweenPoints(position, lastPosition!);
      // final point = _getMiddleVector(position, lastPosition!);
      setState(() {
        totalDistance += double.parse(distance);
      });
      // if(double.parse(distance) <= 0.100){
      //   lastPosition = firstPosition;
      // }
      // else{
        lastPosition = position;
      // }
      // if(firstPosition == null){
      //   firstPosition = position;
      // }
      // _drawText(distance, point);
    }else{
      lastPosition = position;
      if(firstPosition == null){
        firstPosition = position;
      }
    }


  }

  // void _handleButtonTap() async {
  //   print('object');
  //   final screenSize = MediaQuery.of(context).size;
  //   final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
  //   final projectionMatrix = await arkitController.cameraProjectionMatrix();
  //   final viewMatrix = await arkitController.pointOfViewTransform();
  //   arkitController.projectPoint(point)
  //   // final viewMatrix = arkitController.cameraViewMatrix;
  //
  //   if (projectionMatrix != null && viewMatrix != null) {
  //     vector.Matrix4 invertedProjectionMatrix = projectionMatrix;
  //     invertedProjectionMatrix.invert();
  //     // final invertedProjectionMatrix = projectionMatrix.asStream();
  //     // invertedProjectionMatrix.invert();
  //     vector.Matrix4 invertedViewMatrix = viewMatrix;
  //     invertedViewMatrix.invert();
  //
  //     final screenToWorld = invertedProjectionMatrix * invertedViewMatrix;
  //
  //     // Convert screen center to world coordinates
  //     final screenCenterVector = vector.Vector4(
  //       screenCenter.dx,
  //       screenCenter.dy,
  //       0.0,
  //       1.0,
  //     );
  //
  //     final worldPosition = screenToWorld.transform(screenCenterVector);
  //
  //     final transform = Matrix4.compose(
  //       vector.Vector3(worldPosition.x, worldPosition.y, worldPosition.z),
  //       vector.Quaternion(0.0, 0.0, 0.0, 1.0),
  //       vector.Vector3(1.0, 1.0, 1.0),
  //     );
  //
  //     _onPlaneTapHandler(transform);
  //   }
  // }



  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)}';
  }

  vector.Vector3 _getMiddleVector(vector.Vector3 A, vector.Vector3 B) {
    return vector.Vector3((A.x + B.x) / 2, (A.y + B.y) / 2, (A.z + B.z) / 2);
  }

  void _drawText(String text, vector.Vector3 point) {
    final textGeometry = ARKitText(
      text: text,
      extrusionDepth: 0.8,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.black),
        )
      ],
    );
    const scale = 0.0005;
    final vectorScale = vector.Vector3(scale, scale, scale);
    final node = ARKitNode(
      geometry: textGeometry,
      position: point+vector.Vector3(0,0.004,0),
      scale: vectorScale,
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
      // rotation: vector.Vector4(0,1 * (180 / 3.142),0 * (180 / 3.142), 45 * (180 / 3.142)),
      // rotation: vector.Vector4(0, 40 * (180 / 3.142), 0 * (180 / 3.142), 0 * (180 / 3.142))
      // rotation: vector.Vector4(0.001, 0.001, 0.001,0.001)
      // eulerAngles: vector.Vector3(0.2, 0.2, 0.2)
    );
    final textBoundingBox = ARKitBox(
      width: 0.03,
      height: 0.015,
      length: 0.0004,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(Colors.white.withOpacity(0.3)),
        )
      ],
    );
    final backgroundNode = ARKitNode(
      geometry: textBoundingBox,
      rotation: vector.Vector4(1, 0, 0, -math.pi / 2),
      position: node.position + vector.Vector3(0, -0.003, 0), // Slightly behind the text
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
    arkitController.add(backgroundNode);
    addedNodes.add(backgroundNode);
    arkitController.add(node);
    addedNodes.add(node);

  }
}
