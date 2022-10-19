import 'dart:io';
import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:app/services/storageService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class UplaodPage extends StatefulWidget {
  const UplaodPage({super.key});

  @override
  State<UplaodPage> createState() => _UplaodPageState();
}

class _UplaodPageState extends State<UplaodPage> {
  late VideoPlayerController _videoPlayerController;
  String? fileType;
  File? file;
  bool loading = false;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return file == null ? uploadButton() : postForm();
  }

  Widget uploadButton() {
    return IconButton(
        onPressed: () {
          choosePicture();
        },
        icon: Icon(
          Icons.file_upload,
          size: 50.0,
        ));
  }

  Widget postForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text(
          "Create post",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: (() {
            setState(() {
              file = null;
            });
          }),
        ),
        actions: [
          IconButton(
              onPressed: _createPost,
              icon: Icon(
                Icons.send,
                color: Colors.black,
              ))
        ],
      ),
      body: ListView(children: [
        loading
            ? LinearProgressIndicator()
            : SizedBox(
                height: 0.0,
              ),
        fileType == "image"
            ? AspectRatio(
                aspectRatio: 16.0 / 9.0,
                child: Image.file(
                  File("${file?.path}"),
                  fit: BoxFit.cover,
                ))
            : Center(
                child: VideoPlayerController.file(File("${file?.path}"))
                        .value
                        .isInitialized
                    ? Column(
                        children: [
                          AspectRatio(
                              aspectRatio: VideoPlayerController.file(
                                      File("${file?.path}"))
                                  .value
                                  .aspectRatio,
                              child: VideoPlayer(VideoPlayerController.file(
                                  File("${file?.path}")))),
                          TextButton(
                            onPressed: () {
                              VideoPlayerController.file(File("${file?.path}"))
                                  .value
                                  .isPlaying;
                            },
                            child: Icon(Icons.pause
                            ),
                          ),
                        ],
                      )
                    : CircularProgressIndicator(),
              ),
        SizedBox(
          height: 20.0,
        ),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
              hintText: "Enter description",
              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0)),
        ),
        TextFormField(
          controller: locationController,
          decoration: InputDecoration(
              hintText: "Location",
              contentPadding: EdgeInsets.only(left: 15.0, right: 15.0)),
        )
      ]),
    );
  }

  void _createPost() async {
    if (!loading) {
      setState(() {
        loading = true;
      });
      String? photoURL = await StorageService().postPhotoUpload(file!);
      // print("${photoURL}");
      String? activeUserID =
          Provider.of<AdminService>(context, listen: false).activeUserID;
      await FireStoreService().createPost(
        postPhotoURL: photoURL,
        description: descriptionController.text,
        userID: activeUserID,
        location: locationController.text,
      );
      setState(() {
        loading = false;
        descriptionController.clear();
        locationController.clear();
        file = null;
      });
    }
  }

  choosePicture() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create post"),
            children: [
              SimpleDialogOption(
                child: Text("Take a photo"),
                onPressed: () {
                  takePhoto();
                },
              ),
              SimpleDialogOption(
                child: Text("Upload photo from Galery"),
                onPressed: () {
                  uploadFromGalery();
                },
              ),
              SimpleDialogOption(
                child: Text("Take a video"),
                onPressed: () {
                  takeVideo();
                },
              ),
              SimpleDialogOption(
                child: Text("Upload video from Galery"),
                onPressed: () {
                  uploadVideoGallery();
                },
              ),
              SimpleDialogOption(
                child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(color: Colors.red[700]),
                    child: Center(
                        child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Colors.red[700]),
                    ))),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  takePhoto() async {
    setState(() {
      fileType = "image";
    });
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800.0,
        maxHeight: 600.0,
        imageQuality: 80);
    setState(() {
      file = File("${image?.path}");
    });
  }

  uploadFromGalery() async {
    setState(() {
      fileType = "image";
    });
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800.0,
        maxHeight: 600.0,
        imageQuality: 80);
    setState(() {
      file = File("${image?.path}");
    });
  }

  takeVideo() async {
    setState(() {
      fileType = "video";
    });
    Navigator.pop(context);
    var video = await ImagePicker().pickVideo(
        source: ImageSource.camera, maxDuration: Duration(seconds: 30));
        setState(() {
      file = File("${video?.path}");
    });
    _videoPlayerController = VideoPlayerController.file(file!)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play();
      });
    setState(() {
      file = File("${video?.path}");
    });
  }

  uploadVideoGallery() async {
    setState(() {
      fileType = "video";
    });
    Navigator.pop(context);
    var image = await ImagePicker().pickVideo(
        source: ImageSource.gallery, maxDuration: Duration(seconds: 30));
    setState(() {
      file = File("${image?.path}");
    });
  }
}
