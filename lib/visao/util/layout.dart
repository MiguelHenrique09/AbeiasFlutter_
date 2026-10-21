import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trailer_dm/visao/telas/principal.dart';
import 'package:trailer_dm/visao/telas/carrinho.dart';
import 'package:trailer_dm/visao/telas/pedidos.dart';
import 'package:trailer_dm/visao/telas/perfil.dart';

class Layout extends StatelessWidget {
  final Widget body;
  final int currentIndex;

  const Layout({super.key, required this.body, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: body,
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Abeias Burguer",
        style: TextStyle(
          color: Color.fromARGB(255, 230, 154, 14),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 4, 0, 36),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Sair"),
                  content: const Text("Deseja realmente sair do aplicativo?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        exit(0);
                      },
                      child: const Text("Confirmar"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  BottomNavigationBar _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0E1240),
      selectedItemColor: const Color(0xFFFEA116),
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _navegarPara(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Menu"),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "Carrinho",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Pedidos"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
      ],
    );
  }

  void _navegarPara(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destino;
    switch (index) {
      case 0:
        destino = const Principal();
        break;
      case 1:
        destino = const Carrinho();
        break;
      case 2:
        destino = const Pedidos();
        break;
      case 3:
        destino = const Perfil();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }
}
