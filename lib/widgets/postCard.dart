import 'package:app/models/posts.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/comments.dart';
import 'package:app/pages/profile.dart';
import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Users user;
  const PostCard({super.key, required this.post, required this.user});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int _likeNumber = 0;
  bool _liked = false;
  String? _activeUserID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activeUserID=Provider.of<AdminService>(context,listen: false).activeUserID;
    _likeNumber = widget.post.likeNumber;
    _islike();

  }
  _islike() async{
   bool islike= await FireStoreService().isLike(widget.post, _activeUserID!);
   if(islike){
    if (mounted) {
  setState(() {
    _liked=true;
  });
}
   }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _postTitle(),
        _postPhoto(),
        _postFooter(),
      ],
    );
    // return Padding(
    //   padding: const EdgeInsets.only(bottom:8.0),
    //   child: Container(
    //     height: 300.0,
    //     color: Colors.blue,
    //     child: Text('data'),
    //   ),
    // );
  }
  postSelection(){
    showDialog(
      context: context, 
      builder: (context) {
        return SimpleDialog(
          title: Text("Your choice"),
          children: [
            SimpleDialogOption(
              child: Text("Remove post"),
              onPressed: (){ 
                FireStoreService().removePost(_activeUserID!, widget.post);
                Navigator.pop(context);
                },
            ),
            SimpleDialogOption(
              child: Text("Cancel",style: TextStyle(color: Colors.red),),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
      );
  }
  Widget _postTitle() {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(ptofileOwnerID: widget.post.userID))),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: NetworkImage("${widget.user.photoURL}"),
          ),
        ),
      ),
      title: GestureDetector(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(ptofileOwnerID: widget.post.userID))),child: Text("${widget.user.name}")),
      subtitle:
          widget.post.location == "" ? null : Text("${widget.post.location}"),
      trailing: _activeUserID==widget.post.userID? IconButton(onPressed: ()=>postSelection(), icon: Icon(Icons.more_vert)): IconButton(onPressed: () {}, icon: Icon(Icons.download)),
      contentPadding: EdgeInsets.all(0),
    );
  }

  Widget _postPhoto() {
    return GestureDetector(
      onDoubleTap: _changeLike,
      child:widget.post.postPhotoURL!=null?  Image.network(
        '${widget.post.postPhotoURL}',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ):
      null
      ,
    );
  }

  Widget _postFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: _changeLike,
                icon: _liked == false
                    ? Icon(
                        Icons.favorite_border,
                        size: 35.0,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 35.0,
                        color: Colors.red,
                      )),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: ((context) => Comments(post: widget.post,))));
                },
                icon: Icon(
                  Icons.comment,
                  size: 35.0,
                )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '${_likeNumber} likes',
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 2.0,
        ),
        widget.post.description == ""
            ? SizedBox(
                height: 0.0,
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RichText(
                    text: TextSpan(
                        text: "${widget.user.name} ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                            color: Colors.black),
                        children: [
                      TextSpan(
                          text: "${widget.post.description}",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: Colors.black))
                    ])),
              )
      ],
    );
  }

  void _changeLike() {
    if (_liked == true) {
      setState(() {
        _liked = false;
        _likeNumber > 0
            ? _likeNumber = _likeNumber - 1
            : _likeNumber = _likeNumber;
      });
      FireStoreService().dislikePost(widget.post, _activeUserID!);
    } else {
      setState(() {
        _liked = true;
        _likeNumber = _likeNumber + 1;
      });
      FireStoreService().likePost(widget.post,_activeUserID!);
    }
  }
  
}
