import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const StarPathApp());
}

class StarPathApp extends StatelessWidget {
  const StarPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class FriendPlanet {
  final String name;
  final Color color;
  final double radius;
  final double offset;

  FriendPlanet(this.name, this.color, this.radius, this.offset);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int tab = 0;

  late AnimationController controller;

  final friends = [
    FriendPlanet("Unknown EX-001", Colors.purple, 90, 0),

    FriendPlanet("EX-002", Colors.cyanAccent, 140, 2),

    FriendPlanet("Cpt. Alex", Colors.greenAccent, 190, 4),
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: [
        orbitPage(),

        const Center(child: Text("基地艙", style: TextStyle(fontSize: 30))),

        const Center(child: Text("膠囊艙", style: TextStyle(fontSize: 30))),
      ][tab],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,

        selectedItemColor: Colors.cyanAccent,

        currentIndex: tab,

        onTap: (v) {
          setState(() {
            tab = v;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: "Orbit"),

          BottomNavigationBarItem(icon: Icon(Icons.hub), label: "Base"),

          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Capsule"),
        ],
      ),
    );
  }

  Widget orbitPage() {
    return AnimatedBuilder(
      animation: controller,

      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,

          children: [
            CustomPaint(size: Size.infinite, painter: RingPainter()),

            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🐶", style: TextStyle(fontSize: 90)),

                SizedBox(height: 20),

                Text(
                  "Hubble",
                  style: TextStyle(fontSize: 28, color: Colors.cyanAccent),
                ),
              ],
            ),

            for (int i = 0; i < friends.length; i++) planet(friends[i]),
          ],
        );
      },
    );
  }

  Widget planet(FriendPlanet p) {
    double angle = (controller.value * 2 * pi) + p.offset;

    return Transform.translate(
      offset: Offset(cos(angle) * p.radius, sin(angle) * (p.radius * .45)),

      child: Container(
        width: 50,
        height: 50,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: p.color,

          boxShadow: [BoxShadow(color: p.color, blurRadius: 20)],
        ),

        child: Center(
          child: Text(
            p.name.substring(0, 2),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white24;

    final center = Offset(size.width / 2, size.height / 2);

    for (double r in [90, 140, 190]) {
      canvas.save();

      canvas.translate(center.dx, center.dy);

      canvas.rotate(-0.4);

      canvas.scale(1, 0.45);

      canvas.drawCircle(Offset.zero, r, p);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
