// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vertical_flutter/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      // ignore: sort_child_properties_last
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            cursorColor: purpleColor,
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search for a user',
            ),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
            },
          ),
          bottom: TabBar(
            padding: const EdgeInsets.only(bottom: 10),
            indicator: ShapeDecoration(
              shape: Border(
                bottom: BorderSide(
                    width: 3.0,
                    color: purpleColor,
                    style: BorderStyle.solid), //BorderSide
              ),
            ),
            tabs: const <Widget>[
              Tab(
                child: Text('users'),
              ),
              Tab(
                child: Text('climbs'),
              ),
              Tab(
                child: Text('areas'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'username',
                      isGreaterThanOrEqualTo: searchController.text,
                    )
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                      height: 10,
                    ),
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity(vertical: -2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['username'],
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          "Area",
                          style: TextStyle(fontSize: 12),
                        ),
                        tileColor: purpleColor.withOpacity(0.6),
                      );
                    },
                  );
                },
              ),
            ),
            Center(child: Text('climbs')),
            Center(child: Text('areas')),
          ],
        ),
      ),
    );
  }
}
