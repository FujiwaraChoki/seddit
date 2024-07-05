import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final storage = FlutterSecureStorage();
  bool exitOnShake = false;

  @override
  void initState() {
    super.initState();
    _loadExitOnShake();
  }

  Future<void> _loadExitOnShake() async {
    String? value = await storage.read(key: "exitOnShake");
    setState(() {
      exitOnShake = value == "true";
    });
  }

  Future<void> _writeExitOnShake(bool value) async {
    await storage.write(key: "exitOnShake", value: value.toString());
  }

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
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Exit on Shake"),
            trailing: Switch(
              value: exitOnShake,
              onChanged: (value) {
                setState(() {
                  exitOnShake = value;
                });
                _writeExitOnShake(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
