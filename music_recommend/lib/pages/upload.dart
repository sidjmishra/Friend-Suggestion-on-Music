// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:music_recommend/models/user.dart';
import 'package:music_recommend/pages/home.dart';
import 'package:music_recommend/pages/profile.dart';
import 'package:music_recommend/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;

class Upload extends StatefulWidget {
  final User currentUser;

  const Upload({Key? key, required this.currentUser}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

//AutomaticKeepAliveClientMixin Requirement #1 of 3
class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  //Once This File Is Not Null And Is In State
  // We Need To Change View
  //Has to be stored in state
  File? file;
  bool isUpLoading = false;
  var _imageFile;
  String postId = const Uuid().v4();

  handleTakePhoto(context) async {
    Navigator.pop(context);
    // XFile? xfile = await ImagePicker.pickImage(
    //   source: ImageSource.camera,

    // );
    // setState(() {
    //   file = xfile as File;
    // });
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

  handleChooseFromGallery(context) async {
    Navigator.pop(context);
    // XFile? xfile = await ImagePicker.pickImage(
    //   source: ImageSource.gallery,
    // );
    // setState(() {
    //   file = xfile as File;
    // });
    final picker = ImagePicker();
    // var _imageFile;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
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
              // onPressed: () {},
              onPressed: () => handleTakePhoto(context),
            ),
            SimpleDialogOption(
              child: const Text('Image From Gallery'),
              // onPressed: () {},
              onPressed: () => handleChooseFromGallery(context),
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

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
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
                  fontSize: 22.00,
                ),
              ),
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    //Read Image File We Have In State Putting It In imageFile
    // Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
    Im.Image? imageFile = Im.decodeImage(_imageFile!.readAsBytesSync());
    final compressesImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 50));
    setState(() {
      _imageFile = compressesImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap =
        await uploadTask.whenComplete(() => print("Completed"));
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {required String mediaUrl,
      required String location,
      required String description}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerid': widget.currentUser.id,
      'username': widget.currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUpLoading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(_imageFile);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUpLoading = false;
      postId = const Uuid().v4();
    });
  }

  //After Modal Popup and Image is selected
  buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          //onPressed: clearImage,
          onPressed: () {
            locationController.clear();
            captionController.clear();
            clearImage();
          },
        ),
        title: const Text(
          'Caption Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          TextButton(
            //Null disables Button while loading
            //()=> handleSubmit is fat arrowed, if not it will
            // be called as soon as the button isn't null/enabled vs
            // being called only when pressed. It waits to be
            // pressed instead of being activated immediately
            onPressed: isUpLoading ? null : () => handleSubmit(),
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUpLoading ? linearProgress() : const Text(''),
          SizedBox(
            height: 220.0,
            //Take up 80 percent of screen
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
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
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
          Container(
            width: 200.0,
            height: 100.00,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              label: const Text(
                'USE CURRENT LOCATION',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Profile(profileId: currentUser!.id)));
              },
              // onPressed: getUserLocation,
              icon: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  // getUserLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );
  //   Placemark placeMark = placeMarks[0];
  //   String completeAddress =
  //       '${placeMark.subThoroughfare} ${placeMark.thoroughfare} ${placeMark.subLocality} ${placeMark.locality} ${placeMark.subAdministrativeArea} ${placeMark.administrativeArea} ${placeMark.postalCode} ${placeMark.country}';
  //   print(completeAddress);
  //   String formattedAddress =
  //       '${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.country}';
  //   locationController.text = formattedAddress;
  // }

  //AutomaticKeepAliveClientMixin Requirement #2 of 3
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    //AutomaticKeepAliveClientMixin Requirement #3 of 3
    super.build(context);
    return _imageFile == null ? buildSplashScreen() : buildUploadForm();
  }
}
