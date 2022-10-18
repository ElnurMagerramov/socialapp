import 'package:app/pages/flow.dart';
import 'package:app/pages/announce.dart';
import 'package:app/pages/profile.dart';
import 'package:app/pages/search.dart';
import 'package:app/pages/uplaod.dart';
import 'package:app/services/adminService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activePageNo=0;
  late PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController=PageController();
  }
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final activeUserID = Provider.of<AdminService>(context, listen: false).activeUserID;
    return Scaffold(
      body:  PageView(
        // physics: NeverScrollableScrollPhysics(),
        onPageChanged: (displayPageNo) {
          setState(() {
            activePageNo = displayPageNo;
          });
        },
        controller: pageController,
        children: [
          FlowPage(),
          SearchPage(),
          UplaodPage(),
          PostPage(),
          ProfilePage(ptofileOwnerID: activeUserID)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
        onTap: (selectedPageNo) {
          setState(() {
            print(selectedPageNo);
            activePageNo=selectedPageNo;
            pageController.jumpToPage(selectedPageNo);
          });
        },
        currentIndex: activePageNo,
      ),
    );
  }
}
