import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;


class ARKitLinePage extends StatefulWidget {
  @override
  _ARKitLinePageState createState() => _ARKitLinePageState();
}

class _ARKitLinePageState extends State<ARKitLinePage> {
  late ARKitController arkitController;
  ARKitNode? startNode;
  ARKitNode? lineNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ARKit Line Example')),
      body: ARKitSceneView(
        onARKitViewCreated: onARKitViewCreated,
        planeDetection: ARPlaneDetection.horizontal,
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    this.arkitController = controller;
    this.arkitController.addCoachingOverlay(CoachingOverlayGoal.horizontalPlane);
    this.arkitController.onARTap = (List<ARKitTestResult> ar) {
      if (ar.isEmpty) {
        print('empty');
        return;
      }
      final point = ar.firstWhere(
              (element) => element.type == ARKitHitTestResultType.featurePoint);
      final position = point.worldTransform.getColumn(3);
      handleTap(vector.Vector3(position.x, position.y, position.z));
    };
  }

  void handleTap(vector.Vector3 position) {
    if (startNode == null) {
      // Place start node
      startNode = ARKitNode(
        geometry: ARKitSphere(radius: 0.01, materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.red))]),
        position: position,
      );
      arkitController.add(startNode!);
    } else if (lineNode == null) {
      // Place end node and create line
      final endNode = ARKitNode(
        geometry: ARKitSphere(radius: 0.01, materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue))]),
        position: position,
      );
      arkitController.add(endNode);

      final lineGeometry = ARKitLine(fromVector: startNode!.position, toVector: endNode.position);
      lineNode = ARKitNode(geometry: lineGeometry);
      arkitController.add(lineNode!);
    } else {
      // Reset
      arkitController.remove(startNode!.name);
      arkitController.remove(lineNode!.name);
      startNode = null;
      lineNode = null;
      handleTap(position);
    }
  }
}