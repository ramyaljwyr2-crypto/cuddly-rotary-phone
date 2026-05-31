import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const double birdSize = 50;
  static const double gravity = 0.5;
  static const double jumpForce = -10;
  static const double pipeWidth = 60;
  static const double pipeGap = 150;
  static const double pipeSpeed = 3;

  double birdY = 0;
  double birdVelocity = 0;
  List<Pipe> pipes = [];
  int score = 0;
  bool gameStarted = false;
  bool gameOver = false;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    setState(() {
      birdY = 0;
      birdVelocity = 0;
      pipes = [];
      score = 0;
      gameStarted = false;
      gameOver = false;
    });
    gameTimer?.cancel();
  }

  void startGame() {
    gameStarted = true;
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    setState(() {
      birdVelocity += gravity;
      birdY += birdVelocity;

      if (birdY > MediaQuery.of(context).size.height - birdSize - 100 || birdY < -birdSize) {
        gameOver = true;
        gameTimer?.cancel();
      }

      for (var pipe in pipes) {
        pipe.x -= pipeSpeed;

        if (pipe.x < -pipeWidth) {
          pipe.x = MediaQuery.of(context).size.width;
          pipe.topHeight = Random().nextDouble() * (MediaQuery.of(context).size.height - pipeGap - 200) + 100;
          score++;
        }

        if (checkCollision(pipe)) {
          gameOver = true;
          gameTimer?.cancel();
        }
      }

      if (pipes.isEmpty || pipes.last.x < MediaQuery.of(context).size.width - 200) {
        addPipe();
      }
    });
  }

  void addPipe() {
    double topHeight = Random().nextDouble() * (MediaQuery.of(context).size.height - pipeGap - 200) + 100;
    pipes.add(Pipe(x: MediaQuery.of(context).size.width, topHeight: topHeight));
  }

  bool checkCollision(Pipe pipe) {
    double birdLeft = MediaQuery.of(context).size.width / 2 - birdSize / 2;
    double birdRight = birdLeft + birdSize;
    double birdTop = MediaQuery.of(context).size.height / 2 + birdY;
    double birdBottom = birdTop + birdSize;

    if (birdRight > pipe.x && birdLeft < pipe.x + pipeWidth) {
      if (birdTop < pipe.topHeight || birdBottom > pipe.topHeight + pipeGap) {
        return true;
      }
    }
    return false;
  }

  void jump() {
    if (!gameStarted && !gameOver) {
      startGame();
    }
    if (!gameOver) {
      setState(() {
        birdVelocity = jumpForce;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameOver) {
          resetGame();
        } else {
          jump();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            ...pipes.map((pipe) => buildPipe(pipe)).toList(),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - birdSize / 2,
              top: MediaQuery.of(context).size.height / 2 + birdY,
              child: Container(
                width: birdSize,
                height: birdSize,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.orange, width: 3),
                ),
                child: const Center(
                  child: Text('🐤', style: TextStyle(fontSize: 30)),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
            if (!gameStarted && !gameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'اضغط للبدء\nTap to Start',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (gameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over!',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'اضغط للاعادة\nTap to Restart',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildPipe(Pipe pipe) {
    return Stack(
      children: [
        Positioned(
          left: pipe.x,
          top: 0,
          child: Container(
            width: pipeWidth,
            height: pipe.topHeight,
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(color: Colors.green.shade900, width: 3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
        ),
        Positioned(
          left: pipe.x,
          top: pipe.topHeight + pipeGap,
          child: Container(k
            width: pipeWidth,
            height: MediaQuery.of(context).size.height - pipe.topHeight - pipeGap - 100,
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(color: Colors.green.shade900, width: 3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}

class Pipe {
  double x;
  double topHeight;

  Pipe({required this.x, required this.topHeight});
}lib/main.dart
