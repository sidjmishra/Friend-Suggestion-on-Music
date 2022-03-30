import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_music_auth/constants/constants.dart';
import 'package:spotify_music_auth/services/database.dart';

class SearchChat extends StatefulWidget {
  const SearchChat({Key? key}) : super(key: key);

  @override
  State<SearchChat> createState() => _SearchChatState();
}

class _SearchChatState extends State<SearchChat> {
  TextEditingController searchEditingController = TextEditingController();
  late QuerySnapshot searchResultSnapshot;

  bool isLoading = false;
  bool haveUserSearched = false;

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
          haveUserSearched = true;
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.docs[index]["username"],
                searchResultSnapshot.docs[index]["displayName"],
              );
            })
        : Container();
  }

  sendMessage(String userName) {
    // List<String> users = [Constants.myName, userName];

    // String chatRoomId = getChatRoomId(Constants.myName, userName);

    // Map<String, dynamic> chatRoom = {
    //   "users": users,
    //   "chatRoomId": chatRoomId,
    // };

    // databaseMethods.addChatRoom(chatRoom, chatRoomId);

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Chat(
    //               chatRoomId: chatRoomId,
    //             )));
  }

  Widget userTile(String username, String displayName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                displayName,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              sendMessage(username);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(24)),
              child: const Text(
                "Message",
                style: TextStyle(color: Colors.white, fontSize: 16),
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
                                  // Database().getUserByName(value).then((val) {
                                  //   print(val.toString());
                                  // });
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
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50.0))),
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () {
                                  initiateSearch();
                                  // Database().getUserByName(
                                  //     searchEditingController.text);
                                },
                                icon: const Icon(
                                  Icons.search,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    userList(),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 24, vertical: 16),
                    //   color: const Color(0x54FFFFFF),
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: TextField(
                    //           controller: searchEditingController,
                    //           style: const TextStyle(
                    //               color: Colors.black, fontSize: 16),
                    //           decoration: const InputDecoration(
                    //               hintText: "search username ...",
                    //               hintStyle: TextStyle(
                    //                 color: Colors.grey,
                    //                 fontSize: 16,
                    //               ),
                    //               border: InputBorder.none),
                    //         ),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           initiateSearch();
                    //         },
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //               gradient: const LinearGradient(
                    //                   colors: [
                    //                     Color(0x36FFFFFF),
                    //                     Color(0x0FFFFFFF)
                    //                   ],
                    //                   begin: FractionalOffset.topLeft,
                    //                   end: FractionalOffset.bottomRight),
                    //               borderRadius: BorderRadius.circular(40)),
                    //           padding: const EdgeInsets.all(12),
                    //           child: const Icon(Icons.search),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // userList()
                  ],
                ),
              ),
      ),
    );
  }
}
