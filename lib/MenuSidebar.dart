import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    final storage = new FlutterSecureStorage();

    Future<String?> readValue(String key) async {
      return await storage.read(key: key);
    }

    void writeValue(String key, String value) async {
      await storage.write(key: key, value: value);
    }

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
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            onTap: () {},
          ),
          // Exit post on shake
          ListTile(
            title: const Text("Exit on Shake"),
            trailing: Switch(
              value: readValue("exitOnShake") == "true",
              onChanged: (value) {
                writeValue("exitOnShake", value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }
}