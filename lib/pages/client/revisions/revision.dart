import 'dart:io';
import 'package:fluent_beat/classes/revision.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CurrentRevision extends StatefulWidget {
  final Revision revision;
  const CurrentRevision({Key? key, required this.revision}) : super(key: key);

  @override
  State<CurrentRevision> createState() => _CurrentRevisionState();
}

class _CurrentRevisionState extends State<CurrentRevision> {
  ImageProvider? imageProvider;
  static PatientStateController get patientState => Get.find();

  @override
  void initState() {
    super.initState();

    downloadImage();
  }

  Future downloadImage() async {
    File imageFile = (await StorageRepository.getImage(
        widget.revision.getId() + "_h", "png"))!;

    setState(() {
      imageProvider = FileImage(imageFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientStateController>(
        builder: (_) => Column(
              children: [
                Container(
                  height: 80.0,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                  color: Colors.transparent,
                  child: Expanded(
                      child: Card(
                          child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.access_time,
                                color: Color(0xFFff6b6b)),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Revision",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black)),
                                  Text(widget.revision.getShortId(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                      )),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(widget.revision.getDaysAgo())
                          ],
                        )
                      ],
                    ),
                  ))),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Text("ECG Report",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                      // button to view ECG in viewer
                      const Spacer(),
                      if (imageProvider != null)
                        ElevatedButton(
                          onPressed: () async {
                            final documentsDir =
                                await getApplicationDocumentsDirectory();
                            final filepath =
                                '${documentsDir.path}/${widget.revision.getId()}.png';
                            final file = File(filepath);

                            // open file with default app
                            if (await file.exists()) {
                              await OpenFile.open(filepath);
                            }
                          },
                          child: const Text("Open in gallery"),
                        ),
                    ],
                  ),
                ),
                // show scrollable image
                if (imageProvider != null)
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          height: 136,
                          child: Image(
                            image: imageProvider!,
                            fit: BoxFit.cover,
                          ))),
                // comments box ( input )
                Container(
                  color: Color(0x3386AEAD),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: [
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Comments",
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    color: const Color(0xFFff6b6b),
                                    icon: const Icon(Icons.send))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height *
                                          0.315),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: widget.revision.comments.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var comment =
                                        widget.revision.comments[index];

                                    return ListTile(
                                      leading: patientState.patient!.image,
                                      title: Text(comment.body),
                                      subtitle: Text(comment.getDaysAgo()),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ));
  }
}
