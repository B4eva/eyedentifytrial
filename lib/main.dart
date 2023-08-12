import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'image_preview.dart';

List<CameraDescription> cameras = [];
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double _initFabHeight = 40;
  static const double fabHeightClosed = 100.0;
  final double _fabHeight = fabHeightClosed;

  final panelController = PanelController();

  CameraController? controller;

  bool _isCameraInitialized = false;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    // Hide the status bar
    // SystemChrome.setEnabledSystemUIMode([]);
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isCameraInitialized
            ? Stack(
                alignment: FractionalOffset.center,
                children: <Widget>[
                  SizedBox(
                      height: double.infinity,
                      child: CameraPreview(controller!)),
                  Positioned(
                    left: 30,
                    bottom: _initFabHeight,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.image,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: _initFabHeight,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      if (!controller!.value.isInitialized) {
                                        return;
                                      }
                                      if (controller!.value.isTakingPicture) {
                                        return;
                                      }

                                      try {
                                        await controller!
                                            .setFlashMode(FlashMode.auto);
                                        XFile file =
                                            await controller!.takePicture();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImagePreview(file)));
                                      } on CameraException catch (e) {
                                        debugPrint(
                                            'Error occured taking picture: $e');
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                    )),
                                const Text(
                                  'Tap here to reset',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )

                  // DraggableScrollableSheet(
                  //   initialChildSize: 0.4,
                  //   minChildSize: 0.2,
                  //   maxChildSize: 1.0,
                  //   builder: (context, scrollController) {
                  //     return Container(
                  //       decoration: const BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.only(
                  //               topLeft: Radius.circular(15),
                  //               topRight: Radius.circular(15))),
                  //       child: ListView(
                  //         controller: scrollController,
                  //         children: const [
                  //           Center(
                  //               child: Padding(
                  //             padding: EdgeInsets.all(8.0),
                  //             child: Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Text(
                  //                   'Bottle Of Milk.',
                  //                   style: TextStyle(fontSize: 20),
                  //                 ),
                  //                 Icon(Icons.flutter_dash)
                  //               ],
                  //             ),
                  //           )),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              )
            : Container());
  }
}

class Panelwidget extends StatelessWidget {
  final ScrollController controller;
  const Panelwidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
        controller: controller,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        children: [
          buildDragHandle(),
          const SizedBox(
            height: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bottle of Milk ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                height: 36,
                width: 95,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFFF3F3F3)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flutter_dash),
                    SizedBox(
                      width: 10,
                    ),
                    Text('search'),
                  ],
                ),
              )
            ],
          )
        ]);
  }

  Widget buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
