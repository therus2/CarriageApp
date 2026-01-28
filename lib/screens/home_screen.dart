import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dispatcher_screen.dart';
import 'composer_screen.dart';
import 'wagon_list_screen.dart';
import 'rail_yard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role ?? 'GUEST';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Панель управления"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => auth.logout(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(auth.username, role),
            const SizedBox(height: 30),
            const Text("Доступные модули",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Адаптивная верстка: 3 колонки на широком экране, 2 на узком
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                if (role == 'ADMIN' || role == 'DISPATCHER')
                  _menuButton(context, "Регистрация", Icons.add_circle_outline, Colors.orange, const DispatcherScreen()),

                if (role == 'ADMIN' || role == 'COMPOSER')
                  _menuButton(context, "Составитель", Icons.alt_route_rounded, Colors.blue, const ComposerScreen()),

                // Исправлено: grid_view_rounded вместо GridView_rounded
                _menuButton(context, "Карта путей", Icons.grid_view_rounded, Colors.indigo, const RailYardScreen()),

                _menuButton(context, "Все вагоны", Icons.list_alt_rounded, Colors.teal, const WagonListScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(String? name, String role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 35, color: Colors.white)
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Здравствуйте, ${name ?? 'Пользователь'}",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Ваша роль: $role",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, String label, IconData icon, Color color, Widget target) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 45),
            const SizedBox(height: 10),
            Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }
}