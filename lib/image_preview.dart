import 'dart:io';

import 'package:camera/camera.dart';
import 'package:eyedentifytrial/main.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ImagePreview extends StatefulWidget {
  final XFile file;
  const ImagePreview(
    this.file, {
    super.key,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final double _initFabHeight = 300;
  static const double fabHeightClosed = 100.0;
  double _fabHeight = fabHeightClosed;

  final panelController = PanelController();

  CameraController? controller;
  @override
  Widget build(BuildContext context) {
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.5;
    final panelHeightOpen = MediaQuery.of(context).size.height;
    File picture = File(widget.file.path);
    return Scaffold(
      body: SlidingUpPanel(
        controller: panelController,
        defaultPanelState: PanelState.CLOSED,
        maxHeight: panelHeightOpen - 100,
        minHeight: panelHeightClosed,
        parallaxEnabled: true,
        parallaxOffset: .1,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
        onPanelSlide: (double pos) => setState(() {
          final panelMaxScrollExtend = panelHeightOpen - panelHeightClosed;

          // _fabHeight = pos * 300;
          _fabHeight = pos * panelMaxScrollExtend;
        }),
        panelBuilder: (controller) => Panelwidget(
          controller: controller,
        ),
        body: Stack(children: [
          Image.file(picture),
          Positioned(
            left: 30,
            bottom: _initFabHeight + 100,
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
            bottom: _initFabHeight + 90,
            left: 100,
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.white,
                            )),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Tap here to reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
