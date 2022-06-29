import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:fluent_beat/classes/comment.dart';
import 'package:fluent_beat/classes/revision.dart';
import 'package:fluent_beat/classes/storage_repository.dart';
import 'package:fluent_beat/pages/client/state/patient.dart';
import 'package:fluent_beat/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class CurrentRevision extends StatefulWidget {
  final Revision revision;
  const CurrentRevision({Key? key, required this.revision}) : super(key: key);

  @override
  State<CurrentRevision> createState() => _CurrentRevisionState();
}

class _CurrentRevisionState extends State<CurrentRevision> {
  ImageProvider? imageProvider;
  static PatientStateController get patientState => Get.find();
  var commentField = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    downloadImage();
  }

  Future downloadImage() async {
    // download vertical image
    await StorageRepository.getImage(widget.revision.getId(), "png");

    // download horizontal image
    File? imageFile = (await StorageRepository.getImage(
        widget.revision.getId() + "_h", "png"));

    // widget should be mounted, check if so to prevent errors
    if (mounted && imageFile != null) {
      setState(() {
        imageProvider = FileImage(imageFile);

        // Wait until the ECG image become attached to scrollView
        Future.delayed(const Duration(milliseconds: 50), () {
          // scroll a bit to make the ECG image look better from the start
          _scrollController.jumpTo(32);
        });
      });
    }
  }

  void sendComment() async {
    String commentBody = commentField.text;

    // clear comment text field and add comment before everything ( makes user feel it is fast )

    Comment comment = Comment(
      revision_id: widget.revision.getId(),
      body: commentBody,
      by: "USER",
      date: DateTime.now().toString(),
    );

    setState(() {
      commentField.text = "";
      widget.revision.comments.add(comment);
    });

    String revisionId = widget.revision.getId();

    var client = http.Client();
    var response = await client.post(
        Uri.parse("${dotenv.env["API_URL"]}/revisions/comment"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "by": "USER",
          "revision_id": revisionId,
          "comment_body": commentBody
        }));

    if (response.statusCode == 200) {
      var resJson = Map<String, dynamic>.from(json.decode(response.body));
      var jsonBody = Map<String, dynamic>.from(resJson['body']);

      setState(() {
        comment.date = jsonBody['date'];

        widget.revision.comments[widget.revision.comments.length - 1] = comment;
      });
    } else {
      showErrorDialog("Unable to comment on revision.", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientStateController>(
        builder: (_) => Expanded(
              child: Column(
                children: [
                  Container(
                    height: 68.0,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  ),
                  // show scrollable image
                  if (imageProvider != null)
                    SingleChildScrollView(
                        controller:
                            _scrollController, // Where I pin the ScrollController
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                            height: 120,
                            child: Image(
                              image: imageProvider!,
                              fit: BoxFit.cover,
                            ))),
                  // comments box ( input )
                  Expanded(
                    child: Container(
                      color: Color(0x3386AEAD),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 18, left: 8, right: 8, bottom: 8),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: TextField(
                                        controller: commentField,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Comments",
                                        ),
                                        onSubmitted: null,
                                        textInputAction:
                                            TextInputAction.newline,
                                        maxLines: null,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: sendComment,
                                        color: const Color(0xFFff6b6b),
                                        icon: const Icon(Icons.send))
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount:
                                              widget.revision.comments.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var comment =
                                                widget.revision.comments[index];

                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: patientState
                                                          .patient!.image),
                                                  title: Text(comment.body),
                                                  subtitle: Text(
                                                      comment.getDaysAgo()),
                                                ),
                                                Divider(
                                                  height: 3,
                                                  thickness: 2,
                                                  color: Colors.grey
                                                      .withOpacity(0.22),
                                                ),
                                              ],
                                            );
                                          }),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ));
  }
}
