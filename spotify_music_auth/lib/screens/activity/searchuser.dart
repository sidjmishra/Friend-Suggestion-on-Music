// ignore_for_file: avoid_print, unnecessary_string_escapes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/database.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({Key? key}) : super(key: key);

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController searchEditingController = TextEditingController();
  late QuerySnapshot searchResultSnapshot;
  late QuerySnapshot searchSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;
  bool users = false;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await Database()
          .getUserByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          users = false;
          haveUserSearched = true;
        });
      });
    }
  }

  getUserList() async {
    await FirebaseFirestore.instance.collection('Users').get().then((value) {
      setState(() {
        searchSnapshot = value;
        users = true;
      });
    });
  }

  Widget userList() {
    getUserList();
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.docs[index]["username"],
                searchResultSnapshot.docs[index]["displayName"],
                searchResultSnapshot.docs[index]["photoUrl"],
                searchResultSnapshot.docs[index]["uid"],
              );
            })
        : users
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: searchSnapshot.docs.length,
                itemBuilder: (context, index) {
                  return userTile(
                    searchSnapshot.docs[index]["username"],
                    searchSnapshot.docs[index]["displayName"],
                    searchSnapshot.docs[index]["photoUrl"],
                    searchSnapshot.docs[index]["uid"],
                  );
                })
            : Container();
  }

  Widget userTile(
      String username, String displayName, String imgUrl, String userUid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imgUrl),
            radius: 20.0,
          ),
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: GoogleFonts.openSans(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Text(
                displayName,
                style: GoogleFonts.openSans(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              showProfile(context, profileId: userUid);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(24)),
              child: Text(
                "View Profile",
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const SizedBox(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SizedBox(
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                color: Colors.white,
                              ),
                              child: TextField(
                                onSubmitted: (value) {
                                  initiateSearch();
                                },
                                controller: searchEditingController,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: "Search username",
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: const Icon(Icons.search),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50.0))),
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    userList(),
                  ],
                ),
              ),
      ),
    );
  }
}
