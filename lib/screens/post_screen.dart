import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vertical_flutter/models/user.dart';
import 'package:vertical_flutter/providers/user_provider.dart';
import 'package:vertical_flutter/resources/firestore_methods.dart';
import 'package:vertical_flutter/utils/colors.dart';
import 'package:vertical_flutter/utils/utils.dart';

import '../widgets/Date_Picker_Item.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  DateTime date = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  int _gradeController = 0;
  double _starsController = 0;
  String climbName = "Climb Name";
  String areaName = "Area Name";

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system
              // navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
        _gradeController,
        _starsController.round(),
        date,
        climbName,
        areaName,
      );
      if (res == "success") {
        showSnackBar("Posted!", context);
        setState(() {
          _isLoading = false;
        });
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  _selectImage() async {
    Uint8List file = await pickImage(
      ImageSource.gallery,
    );
    setState(() {
      _file = file;
    });
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  void add() {
    if (_gradeController < 17) {
      setState(() {
        _gradeController++;
      });
    }
  }

  void subtract() {
    if (_gradeController > 0) {
      setState(() {
        _gradeController--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text("Post to"),
        actions: [
          TextButton(
            onPressed: () => postImage(
              userProvider.getUser.uid,
              userProvider.getUser.username,
              userProvider.getUser.photoUrl,
            ),
            child: const Text(
              "Post",
              style: TextStyle(
                color: purpleColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _isLoading
              ? const LinearProgressIndicator()
              : Padding(
                  padding: EdgeInsets.only(top: 0),
                ),
          const Divider(),
          (_file == null
              ? InkWell(
                  onTap: _selectImage,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Icon(
                        Icons.upload,
                        size: 50,
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(_file!),
                          fit: BoxFit.fill,
                          alignment: FractionalOffset.topCenter,
                        ),
                      ),
                    ),
                  ),
                )),
          const Divider(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 100,
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: mobileSearchColor,
                hintText: "Write a caption...",
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
              ),
              maxLines: 8,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: add,
                    child: Icon(
                      Icons.arrow_upward_sharp,
                      color: purpleColor,
                      size: 30,
                    ),
                    backgroundColor: Colors.black,
                  ),
                  Text('V$_gradeController', style: TextStyle(fontSize: 20)),
                  FloatingActionButton.small(
                    onPressed: subtract,
                    child: Icon(
                      Icons.arrow_downward_sharp,
                      color: purpleColor,
                      size: 30,
                    ),
                    backgroundColor: Colors.black,
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  RatingBar.builder(
                    itemSize: 25,
                    itemBuilder: ((context, index) => Icon(
                          Icons.star,
                          color: purpleColor,
                        )),
                    minRating: 0,
                    onRatingUpdate: (stars) => setState(() {
                      _starsController = stars;
                    }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DatePickerItem(
                    children: [
                      CupertinoButton(
                        // Display a CupertinoDatePicker in date picker mode.
                        onPressed: () => _showDialog(
                          CupertinoDatePicker(
                            initialDateTime: date,
                            mode: CupertinoDatePickerMode.date,
                            use24hFormat: true,
                            // This is called when the user changes the date.
                            onDateTimeChanged: (DateTime newDate) {
                              setState(() => date = newDate);
                            },
                          ),
                        ),
                        padding: EdgeInsets.all(0),
                        child: Text(
                          '${date.month}-${date.day}-${date.year}',
                          style: const TextStyle(
                            fontSize: 22.0,
                            color: purpleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}


// DateFormat.yMMMd().format(
//                       snap['date'].toDate(),
//                     ),