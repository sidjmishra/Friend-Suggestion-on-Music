// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/screens/screens.dart';
import 'package:spotify_music_auth/services/database.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as im;

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();

  File? file;

  bool isUpLoading = false;
  var _imageFile;
  String postId = const Uuid().v4();

  takePhoto(context) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  chooseFromGallery(context) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create Post'),
          children: [
            SimpleDialogOption(
              child: const Text('Photo with Camera'),
              onPressed: () => takePhoto(context),
            ),
            SimpleDialogOption(
              child: const Text('Image From Gallery'),
              onPressed: () => chooseFromGallery(context),
            ),
            SimpleDialogOption(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    im.Image? imageFile = im.decodeImage(_imageFile!.readAsBytesSync());
    final compressesImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(im.encodeJpg(imageFile!, quality: 50));
    setState(() {
      _imageFile = compressesImageFile;
    });
  }

  handleSubmit() async {
    setState(() {
      isUpLoading = true;
    });
    await compressImage();
    Database().addPostToDatabase(postId, Constants.uid, locationController.text,
        _imageFile, Constants.userName, captionController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUpLoading = false;
      postId = const Uuid().v4();
    });
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Home()));
  }

  Widget splashScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Post"),
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/upload.svg', height: 260.0),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(kPrimaryColor),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Upload Image',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => selectImage(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  uploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            locationController.clear();
            captionController.clear();
            clearImage();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Home()));
          },
        ),
        title: const Text(
          'Upload Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: isUpLoading ? null : () => handleSubmit(),
            child: const Text(
              'Post',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          isUpLoading
              ? Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: const LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.purple),
                  ),
                )
              : const Text(''),
          SizedBox(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_imageFile),
                  )),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(Constants.photoUrl),
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: 'Write A Caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Where Was The Photo Taken',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _imageFile == null ? splashScreen() : uploadForm();
  }

  @override
  bool get wantKeepAlive => true;
}
