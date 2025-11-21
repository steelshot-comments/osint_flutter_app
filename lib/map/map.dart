import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/services.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMap mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  bool isAddingMarker = false;
  double zoomLvl = 2;

  final bounds = CoordinateBounds(
      southwest:
          Point(coordinates: Position(388.42376845031635, 853.1385104577851)),
      northeast:
          Point(coordinates: Position(25.294140623294645, 66.08828125146374)),
      infiniteBounds: true);

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();

    // mapboxMap.setBounds(
    //     CameraBoundsOptions(bounds: bounds, maxZoom: 10, minZoom: 4));
  }

  Future<void> _addMarker(Point point) async {
    final ByteData bytes = await rootBundle.load('assets/images/marker.webp');
    final Uint8List imageData = bytes.buffer.asUint8List();

    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
      geometry: point,
      image: imageData,
      iconSize: 0.3,
    );

    pointAnnotationManager?.create(pointAnnotationOptions);
  }

  void _toggleMarkerAddingMode() {
    setState(() {
      isAddingMarker = !isAddingMarker;
    });
  }

  _onTap(MapContentGestureContext context) {
    debugPrint("OnTap coordinate: {${context.point.coordinates.lng}, ${context.point.coordinates.lat}}" +
        " point: {x: ${context.touchPosition.x}, y: ${context.touchPosition.y}}");
    if (isAddingMarker) {
      _addMarker(context.point);
    }
    // showModalBottomSheet(context: context, builder: (BuildContext context){

    // })
  }

  _onCameraChangeListener(CameraChangedEventData data) {
    // print("CameraChangedEventData: timestamp: ${data.cameraState.zoom}");
    if (data.cameraState.zoom != zoomLvl) {
      setState(() {
        zoomLvl = data.cameraState.zoom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: MapWidget(
          key: ValueKey("mapWidget"),
          cameraOptions: CameraOptions(
            center: Point(coordinates: Position(-98.0, 39.5)),
            zoom: 2,
            bearing: 0,
            pitch: 0,
          ),
          onMapCreated: _onMapCreated,
          onTapListener: _onTap,
          onCameraChangeListener: _onCameraChangeListener,
        ),
        floatingActionButton: SpeedDial(
          animationAngle: 180,
          tooltip: "Open actions",
          icon: Icons.add,
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext contxt) {
                      return SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Modal BottomSheet'),
                                ElevatedButton(
                                  child: const Text('Close BottomSheet'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
              child: Icon(isAddingMarker ? Icons.add_location : Icons.add),
            ),
            SpeedDialChild(
              onTap: _toggleMarkerAddingMode,
              child: Icon(isAddingMarker ? Icons.add_location : Icons.add),
            ),
            SpeedDialChild(
              label: isAddingMarker ? "Remove marker" : "Add marker",
              onTap: _toggleMarkerAddingMode,
              child: Icon(isAddingMarker ? Icons.add_location : Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
