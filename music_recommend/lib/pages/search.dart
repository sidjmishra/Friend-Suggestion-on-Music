// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_recommend/models/user.dart';
import 'package:music_recommend/pages/timeline.dart';
import 'package:music_recommend/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where('displayName', isGreaterThanOrEqualTo: query).get();

    setState(() {
      searchResultsFuture = users;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        decoration: InputDecoration(
          hintText: "Search for a user",
          filled: true,
          prefixIcon: const Icon(
            Icons.account_box,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => print("Cleared"),
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  SizedBox buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return SizedBox(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300 : 200,
            ),
            const Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Text> searchResults = [];
        snapshot.data!.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          searchResults.add(
            Text(user.username),
          );
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  const UserResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text("User Result");
  }
}
