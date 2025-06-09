// import 'package:flutter/material.dart';
// import 'chat_screen.dart';
// import 'history_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   // Pages excluding the top bar content
//   final List<Widget> _pages = [
//     Center(child: Text('Welcome to ChatSmart!', style: TextStyle(fontSize: 24))),
//     ChatScreen(),
//     const HistoryScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom Top Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // App Name
//                   Text(
//                     "ChatSmart",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple,
//                     ),
//                   ),
//                   // Settings Icon
//                   IconButton(
//                     icon: Icon(Icons.settings, color: const Color.fromARGB(221, 248, 248, 248)),
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/settings');
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Main Content
//             Expanded(
//               child: _pages[_currentIndex],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.deepPurple,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) => setState(() => _currentIndex = index),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble),
//             label: 'Chatbot',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'History',
//           ),
//         ],
//       ),
//     );
//   }
// }
