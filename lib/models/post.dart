import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final String username;
  final date;
  final String postUrl;
  final String profImage;
  final int grade;
  final int stars;
  final String climbName;
  final String areaName;

  const Post({
    required this.description,
    required this.uid,
    required this.postId,
    required this.username,
    required this.date,
    required this.postUrl,
    required this.profImage,
    required this.grade,
    required this.stars,
    required this.climbName,
    required this.areaName,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'description': description,
        'postId': postId,
        'date': date,
        'postUrl': postUrl,
        'profImage': profImage,
        'grade': grade,
        'stars': stars,
        'climbName': climbName,
        'areaName': areaName,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      date: snapshot['date'],
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      grade: snapshot['grade'],
      stars: snapshot['stars'],
      climbName: snapshot['climbName'],
      areaName: snapshot['areaName'],
    );
  }
}
