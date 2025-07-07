// lib/core/main_navigator.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/features/appointments/appointments_screen.dart';
import 'package:pc_studio_app/features/artists/artists_screen.dart';
import 'package:pc_studio_app/features/home/home_screen.dart';
import 'package:pc_studio_app/features/profile/profile_screen.dart';

/// O widget de navegação principal da aplicação.
/// AGORA ACEITA UM PARÂMETRO PARA DEFINIR O ÍNDICE INICIAL.
class MainNavigator extends StatefulWidget {
  // 1. NOVO PARÂMETRO: Opcional, para definir qual aba deve ser aberta inicialmente.
  final int initialIndex;

  // O valor padrão é 0 (a aba 'Início').
  const MainNavigator({super.key, this.initialIndex = 0});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  // O índice da aba selecionada.
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // 2. O índice selecionado agora começa com o valor que foi passado para o widget.
    _selectedIndex = widget.initialIndex;
  }

  // A lista de ecrãs que correspondem a cada aba da navegação.
  static final List<Widget> _widgetOptions = <Widget>[
    // Passamos uma função para a HomeScreen que permite que ela mude a aba.
    HomeScreen(
        onNavigateToPage: (index) {}), // Será atualizado no próximo passo
    const ArtistsScreen(),
    const AppointmentsScreen(),
    const ProfileScreen(),
  ];

  // Função chamada quando um item da barra de navegação é tocado.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para que a HomeScreen possa chamar a função _onItemTapped,
    // precisamos de reconstruir a lista de widgets aqui.
    final List<Widget> currentWidgetOptions = <Widget>[
      HomeScreen(onNavigateToPage: _onItemTapped),
      const ArtistsScreen(),
      const AppointmentsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Center(
        child: currentWidgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.brush), label: 'Artistas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
