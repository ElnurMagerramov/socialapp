import 'package:app/models/posts.dart';
import 'package:app/models/user.dart';
import 'package:app/widgets/postCard.dart';
import 'package:app/widgets/undeletedWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../services/adminService.dart';
import '../services/firestoreService.dart';

class FlowPage extends StatefulWidget {
  const FlowPage({super.key});

  @override
  State<FlowPage> createState() => _FlowPageState();
}

class _FlowPageState extends State<FlowPage> {
  List<Post> _posts = [];
  _getFlows() async {
    String? activeUserID = Provider.of<AdminService>(context, listen: false).activeUserID;
    List<Post> posts = await FireStoreService().getFlows(activeUserID);
    if (mounted) {
      setState(() {
        _posts = posts;
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getFlows();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Social app")),
      ),
      body: ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          Post post = _posts[index];
          return UnDeletetedWidget( //sehifeni surusdurende silinmeyen futurebuilder duzeldir bu
            future: FireStoreService().getUser(post.userID),
            builder: (context, snapshot) {
              if(!snapshot.hasData){
                return SizedBox();
              }else{
                Users user = snapshot.data!;
                return PostCard(post: post,user: user);
              }
            },
            );
        },
        ),
    );
  }
}
