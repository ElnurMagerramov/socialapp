import 'package:app/models/user.dart';
import 'package:app/pages/profile.dart';
import 'package:app/services/firestoreService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  Future<List<Users>>? _searchResult;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _searchResult != null ? getResults() : hasNotSearch(),
    );
  }

  AppBar _createAppBar() {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.blue[400],
      title: TextFormField(
        onFieldSubmitted: (value) {
          setState(() {
            _searchResult = FireStoreService().searchUser(value);
          });
        },
        controller: _searchController,
        style: TextStyle(
          fontSize: 20.0,
        ),
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              size: 30.0,
            ),
            suffix: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.black,
                size: 30.0,
              ),
              color: Colors.black,
              onPressed: ()
              { 
                _searchController.clear();
                setState(() {
                  _searchResult=null;
                });
                },
            ),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            hintText: 'Search...',
            contentPadding: EdgeInsets.only(bottom: 13)),
      ),
    );
  }

  Widget hasNotSearch() {
    return Center(child: Text("Search user"));
  }

  Widget getResults() {
    return FutureBuilder<List<Users>>(
      future: _searchResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data?.length == 0) {
          print(_searchController.text);

          return Center(
            child: Text("There is not result..."),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Users user = snapshot.data![index];
              // if (user.name == _searchController.text) {
                return userLine(user);
              // }
              // return Text('data');
            },
          );
        }
      },
    );
  }
  userLine(Users user){
    return Padding(
      padding: const EdgeInsets.only(top:4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(ptofileOwnerID: user.id),));
        },
        child: ListTile(
          leading:
           user.photoURL.isEmpty? CircleAvatar(
                    backgroundColor: Colors.blue[200],
                    backgroundImage: NetworkImage('https://cdn.pixabay.com/photo/2017/08/07/13/14/black-and-white-2603731__340.jpg'),
                  ):
                   CircleAvatar(backgroundColor: Colors.blue[400],backgroundImage: NetworkImage(user.photoURL),),
          title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}
