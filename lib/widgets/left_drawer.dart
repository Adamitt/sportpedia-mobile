import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/screens/menu.dart';
import 'package:sportpedia_mobile/screens/gearguide_page.dart';
import 'package:sportpedia_mobile/screens/gear_form_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
                Text(
                  'SportPedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(10)),
                Text(
                  "Sport library & gear recommendation dalam satu aplikasi.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // ====== Home ======
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              );
            },
          ),

          // ====== Gear Guide ======
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Gear'),
            onTap: () async {
                Navigator.pop(context); // close drawer first
                // push form and wait for result; if true -> refresh list (handled in gear list page)
                final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GearFormPage()),
                );
                // optional: you can use a callback / state management to refresh GearListPage
            },
            ),
        ],
      ),
    );
  }
}
