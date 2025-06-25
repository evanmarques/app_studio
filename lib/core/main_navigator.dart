import 'package:flutter/material.dart';
// --- CAMINHOS DE IMPORT CORRIGIDOS ---
import 'package:pc_studio_app/features/appointments/appointments_screen.dart';
import 'package:pc_studio_app/features/artists/artists_screen.dart';
import 'package:pc_studio_app/features/home/home_screen.dart';
import 'package:pc_studio_app/features/profile/profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // A lista de widgets que correspondem a cada aba da navegação.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ArtistsScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  // Função chamada quando um item da barra de navegação é tocado.
  void _onItemTapped(int index) {
    // setState notifica o Flutter que o estado mudou, e a UI precisa ser redesenhada.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Exibe o widget selecionado da lista _widgetOptions.
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // A barra de navegação inferior.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brush),
            label: 'Artistas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Estilização para o tema escuro.
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType
            .fixed, // Garante que todos os labels apareçam.
      ),
    );
  }
}
