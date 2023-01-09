import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vertical_flutter/screens/feed_screen.dart';
import 'package:vertical_flutter/screens/search_screen.dart';
import 'package:vertical_flutter/screens/user_profile_screen.dart';

import '../screens/post_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Text('Notif'),
  UserProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
