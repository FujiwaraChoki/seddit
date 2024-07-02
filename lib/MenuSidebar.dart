import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  Sidebar({Key? key}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            title: const Text(""),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(
              "Recently visited",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text("r/popular"),
            onTap: () {
              // Update the state of the app
              // Send notification
              print("pressed.");
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}