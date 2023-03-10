import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vertical_flutter/resources/auth_methods.dart';
import 'package:vertical_flutter/resources/firestore_methods.dart';
import 'package:vertical_flutter/screens/login_screen.dart';
import 'package:vertical_flutter/utils/utils.dart';
import 'package:vertical_flutter/widgets/follow_button.dart';

import '../utils/colors.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;
  const UserProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var userData = {};
  int postLen = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  void logout() async {
    await AuthMethods().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () async {
                    await AuthMethods().signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign Out",
                    style: TextStyle(
                      color: purpleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStateColumn(postLen, 'posts'),
                                    buildStateColumn(150, 'followers'),
                                    buildStateColumn(150, 'followers'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: "Edit Profile",
                                            textColor: primaryColor,
                                            function: () {},
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                backgroundColor:
                                                    mobileBackgroundColor,
                                                borderColor: purpleColor,
                                                text: "Unfollow",
                                                textColor: purpleColor,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['uid'],
                                                  );
                                                  setState(() {
                                                    isFollowing = false;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                backgroundColor: purpleColor,
                                                borderColor: purpleColor,
                                                text: "Follow",
                                                textColor: Colors.black,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['uid'],
                                                  );
                                                  setState(() {
                                                    isFollowing = true;
                                                  });
                                                },
                                              )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                DefaultTabController(
                  length: 3,
                  child: Expanded(
                    child: Column(
                      children: <Widget>[
                        TabBar(
                          padding: EdgeInsets.only(bottom: 10),
                          indicator: ShapeDecoration(
                            shape: Border(
                              bottom: BorderSide(
                                width: 3.0,
                                color: purpleColor,
                                style: BorderStyle.solid,
                              ), //BorderSide
                            ),
                          ),
                          tabs: <Widget>[
                            Tab(
                              child: Text('Videos'),
                            ),
                            Tab(
                              child: Text('Ascents'),
                            ),
                            Tab(
                              child: Text('About'),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: TabBarView(
                            children: <Widget>[
                              Center(
                                child: FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('posts')
                                      .where('uid', isEqualTo: widget.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return GridView.builder(
                                      shrinkWrap: false,
                                      primary: false,
                                      itemCount: (snapshot.data! as dynamic)
                                          .docs
                                          .length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 1.5,
                                        mainAxisSpacing: 1.5,
                                        childAspectRatio: 1,
                                      ),
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot snap =
                                            (snapshot.data! as dynamic)
                                                .docs[index];

                                        return Container(
                                          child: Image(
                                            image: NetworkImage(
                                              snap['postUrl'],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('posts')
                                      .where('uid', isEqualTo: widget.uid)
                                      .orderBy('grade', descending: true)
                                      .orderBy('date', descending: true)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                        height: 10,
                                      ),
                                      itemCount: (snapshot.data! as dynamic)
                                          .docs
                                          .length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot snap =
                                            (snapshot.data! as dynamic)
                                                .docs[index];
                                        num previousGrade = 0;
                                        if (previousGrade != snap['grade']) {
                                          previousGrade = snap['grade'];
                                          return Column(
                                            children: [
                                              ListTile(
                                                dense: true,
                                                visualDensity:
                                                    VisualDensity(vertical: -2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                title: Text(
                                                  'V' +
                                                      snap['grade'].toString(),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: purpleColor),
                                                ),
                                                tileColor: Colors.black,
                                              ),
                                              InkWell(
                                                child: ListTile(
                                                  onTap: () => {},
                                                  // Navigator.of(context)
                                                  //     .push(MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             UserProfileScreen(
                                                  //                 uid: (snapshot.data!
                                                  //                             as dynamic)
                                                  //                         .docs[index]
                                                  //                     ['uid']))),
                                                  dense: true,
                                                  visualDensity: VisualDensity(
                                                      vertical: -2),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  title: Text(
                                                    snap['username'] +
                                                        " V" +
                                                        snap['grade']
                                                            .toString(),
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  subtitle: Text(
                                                    snap['username'],
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  tileColor: purpleColor
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return InkWell(
                                            child: ListTile(
                                              onTap: () => {},
                                              // Navigator.of(context)
                                              //     .push(MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             UserProfileScreen(
                                              //                 uid: (snapshot.data!
                                              //                             as dynamic)
                                              //                         .docs[index]
                                              //                     ['uid']))),
                                              dense: true,
                                              visualDensity:
                                                  VisualDensity(vertical: -2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              title: Text(
                                                snap['climbName'],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              subtitle: Text(
                                                snap['areaName'],
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              tileColor:
                                                  purpleColor.withOpacity(0.6),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              Center(child: Text('About')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStateColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
