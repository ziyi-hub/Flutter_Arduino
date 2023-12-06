import 'package:flutter/material.dart';
import 'SelectorDispositivePage.dart';
import 'layout_bluetooth/ControlePrincipalPage.dart';
import 'package:provider/provider.dart';
import 'layout_bluetooth/CustomAppBar.dart';
import 'layout_bluetooth/StatusConnexionProvider.dart';

class Accueil extends StatelessWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onPressBluetooth() {
      return (() async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings: const RouteSettings(name: 'selectDevice'),
            builder: (context) => const SelecionarDispositivoPage()));
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        Title: 'Remote Arduino',
        isBluetooth: true,
        isDiscovering: false,
        onPress: onPressBluetooth,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Consumer<StatusConexaoProvider>(
            builder: (context, StatusConnectionProvider, widget) {
              return (StatusConnectionProvider.device == null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.bluetooth_disabled_sharp, size: 50),
                        Text(
                          "Bluetooth Disconnected",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        )
                      ],
                    )
                  : ControlePrincipalPage(
                      server: StatusConnectionProvider.device));
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey,
        // this creates a notch in the center of the bottom bar
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.people,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            const SizedBox(
              width: 20,
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                {
                  Navigator.pushNamed(context, '/arduino');
                }
              },
            ),
          ],
        ),
      ),
// implement the floating button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/map');
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
