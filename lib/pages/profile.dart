import 'package:app/models/user.dart';
import 'package:app/pages/editProfile.dart';
import 'package:app/services/adminService.dart';
import 'package:app/services/firestoreService.dart';
import 'package:app/widgets/postCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/posts.dart';

class ProfilePage extends StatefulWidget {
  final String? ptofileOwnerID;
  const ProfilePage({super.key, required this.ptofileOwnerID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _posts = 0;
  int _followers = 0;
  int _followings = 0;
  List<Post> _postsDetails = [];
  String postStyle = "list";
  String? _activeUserID;
  Users? _profileOwner;
  bool _isFollow = false;
  _getFollowerNumber() async {
    int followerNumber =
        await FireStoreService().followerNumber(widget.ptofileOwnerID);
    if (mounted) {
      setState(() {
        _followers = followerNumber;
      });
    }
  }

  _getFollowingNumber() async {
    int followingNumber =
        await FireStoreService().followingNumber(widget.ptofileOwnerID);
    if (mounted) {
      setState(() {
        _followings = followingNumber;
      });
    }
  }

  _getPosts() async {
    List<Post> posts = await FireStoreService().getPosts(widget.ptofileOwnerID);
    if (mounted) {
      setState(() {
        _postsDetails = posts;
        _posts = _postsDetails.length;
      });
    }
  }

  _followControl() async {
    bool isFollow = await FireStoreService()
        .followControl(_activeUserID, widget.ptofileOwnerID);
    setState(() {
      _isFollow = isFollow;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getFollowerNumber();
    _getFollowingNumber();
    _getPosts();
    _activeUserID =
        Provider.of<AdminService>(context, listen: false).activeUserID;
    _followControl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Profile Page',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[100],
        actions: [
          widget.ptofileOwnerID == _activeUserID
              ? IconButton(
                  onPressed: _logout,
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ),
                )
              : IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert)) //burda bir funksiya ola biler
        ],
      ),
      body: FutureBuilder(
          future: FireStoreService().getUser(widget.ptofileOwnerID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            _profileOwner = snapshot.data;
            return ListView(
              children: [
                _profileDetails(snapshot.data),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                postStyle = "grid";
                              });
                            },
                            child: Icon(
                              Icons.grid_view,
                              color: postStyle == "grid"
                                  ? Colors.blue
                                  : Colors.grey,
                            )),
                        Container(
                          height: 3,
                          width: 200,
                          color:
                              postStyle == "grid" ? Colors.blue : Colors.grey,
                        )
                      ],
                    ),
                    Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                postStyle = "list";
                              });
                            },
                            child: Icon(
                              Icons.view_agenda,
                              color: postStyle == "list"
                                  ? Colors.blue
                                  : Colors.grey,
                            )),
                        Container(
                          height: 3,
                          width: 200,
                          color:
                              postStyle == "list" ? Colors.blue : Colors.grey,
                        )
                      ],
                    ),
                  ],
                ),
                _showPosts(snapshot.data)
              ],
            );
          }),
    );
  }

  Widget _showPosts(user) {
    if (postStyle == "list") {
      return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: _postsDetails.length,
        itemBuilder: (context, index) {
          return PostCard(post: _postsDetails[index], user: user);
        },
      );
    } else {
      List<GridTile> grids = [];
      _postsDetails.forEach(((post) {
        grids.add(_createGrid(post));
      }));
      return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
          physics: NeverScrollableScrollPhysics(),
          children: grids
          // [
          // GridTile(child: Container(
          //   color: Colors.blue,
          // ),
          // header: Text('Ust'),
          // footer: Text('Ust'),
          // ),
          // GridTile(child: Container(
          //   color: Colors.blue,
          // ),
          // )
          // ],
          );
    }
  }

  GridTile _createGrid(Post post) {
    return GridTile(
        child: GridTile(
            child: Image.network(
      '${post.postPhotoURL}',
      fit: BoxFit.cover,
    )));
  }

  Widget _profileDetails(Users? profileData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              (profileData!.photoURL.isEmpty
                  ? CircleAvatar(
                      backgroundColor: Colors.blue[200],
                      radius: 50.0,
                      backgroundImage: NetworkImage(
                          'https://cdn.pixabay.com/photo/2017/08/07/13/14/black-and-white-2603731__340.jpg'),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.blue[200],
                      radius: 50.0,
                      backgroundImage: NetworkImage('${profileData.photoURL}'),
                    )),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sosialCounter(_posts, "Posts"),
                    _sosialCounter(_followers, "Followers"),
                    _sosialCounter(_followings, "Following"),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "${profileData.name}",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text("${profileData.about}"),
          SizedBox(
            height: 25.0,
          ),
          widget.ptofileOwnerID == _activeUserID
              ? _editProfile()
              : _followBUtton()
        ],
      ),
    );
  }

  Widget _followBUtton() {
    return _isFollow ? _dontFollow() : _follow();
  }

  Widget _follow() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Theme.of(context).primaryColor),
              foregroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white)),
          onPressed: () {
            FireStoreService().follow(_activeUserID, widget.ptofileOwnerID);
            setState(() {
              _isFollow = true;
              _followers = _followers + 1;
            });
          },
          child: Text(
            "Follow",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _dontFollow() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: () {
            FireStoreService().followOut(_activeUserID, widget.ptofileOwnerID);
            setState(() {
              _isFollow = false;
              _followers = _followers - 1;
            });
          },
          child: Text(
            "Follow out",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _editProfile() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => EditProfile(
                    profile: _profileOwner,
                  ),
                ));
          },
          child: Text("Edit Profile")),
    );
  }

  Widget _sosialCounter(int number, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 2.0,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 15.0),
        )
      ],
    );
  }

  void _logout() {
    try {
      Provider.of<AdminService>(context, listen: false).logout();
    } catch (error) {
      print(error);
    }
  }
}
