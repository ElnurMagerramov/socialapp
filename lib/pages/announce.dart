import 'package:app/models/user.dart';
import 'package:app/pages/onePost.dart';
import 'package:app/pages/profile.dart';
import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import '../models/announce.dart';
import 'package:timeago/timeago.dart' as timeago;
class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Announce>? _announces;
  String? _activeUserID;
  bool _loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activeUserID =
        Provider.of<AdminService>(context, listen: false).activeUserID;
    getAnnounces();
    timeago.setLocaleMessages('az', timeago.AzMessages());
  }

  Future<void> getAnnounces() async {
    List<Announce> announces =
        await FireStoreService().getAnnounces(_activeUserID);
    if (mounted) {
      setState(() {
        _announces = announces;
        _loading = false;
      });
    }
  }

  showAnnounces() {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    } else if (_announces!.isEmpty) {
      return Center(child: Text("You don't have any announces..."));
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: RefreshIndicator(
          onRefresh: getAnnounces,
          child: ListView.builder(
              itemCount: _announces!.length,
              itemBuilder: (context, index) {
                Announce announce = _announces![index];
                return announceLine(announce);
              }),
        ),
      );
    }
  }

  announceLine(Announce announce) {
    String message = createMessage(announce.activityType, announce.comment);
    return FutureBuilder(
      future: FireStoreService().getUser(announce.activityUserID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 0.0,
          );
        } else {
          Users activityUser = snapshot.data!;
          return ListTile(
            leading: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: ((context) => ProfilePage(ptofileOwnerID: announce.activityUserID)))),
              child: CircleAvatar(
                  backgroundImage: NetworkImage(activityUser.photoURL)),
            ),
            title: RichText(
              text: TextSpan(
                recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: ((context) => ProfilePage(ptofileOwnerID: announce.activityUserID)))),
                  text: "${activityUser.name} ",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: announce.comment==" "?"${message}":"${message}: ${announce.comment}", style: TextStyle(fontWeight: FontWeight.normal))
                      ]
                      ),
            ),
            subtitle: Text(timeago.format(announce.createdTime.toDate(),locale: "az")),
            trailing: postImage(announce.activityType, announce.postPhoto, announce.postID),
          );
        }
      },
    );
  }

  postImage(String activity, String photo,String postID) {
    if (activity == "follow") {
      return null;
    } else if (activity == "like" || activity == "comment") {
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: ((context) => OnePost(postID: postID,postUserID: _activeUserID!,)))),
        child: Image.network(
          photo,
          width: 50.0,
          height: 50.0,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  createMessage(String activity, String comment) {
    if (activity == "like") {
      return "liked your post";
    } else if (activity == "follow") {
      return "followed you";
    } else if (activity == "comment") {
      return "commented your post";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Announces",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: showAnnounces(),
    );
  }
}
