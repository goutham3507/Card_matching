import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(),
    );
  }
}

class CardModel {
  String asset;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.asset, this.isFaceUp = false, this.isMatched = false});
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardModel> cards;
  CardModel? firstSelectedCard;
  CardModel? secondSelectedCard;
  int score = 0;
  bool isChecking = false;
  int timeElapsed = 0;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _startTimer();
  }

  void _initializeCards() {
    List<String> assets = [
      'assets/card1.png',
      'assets/card2.png',
      'assets/card3.png',
      'assets/card4.png',
      'assets/card5.png',
      'assets/card6.png',
      'assets/card7.png',
      'assets/card8.png',
    ];
    cards = [...assets, ...assets]
        .map((asset) => CardModel(asset: asset))
        .toList()
      ..shuffle();
  }

  void _startTimer() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeElapsed++;
      });
    });
  }

  void _stopTimer() {
    gameTimer?.cancel();
  }

  void _checkMatch() {
    setState(() {
      if (firstSelectedCard!.asset == secondSelectedCard!.asset) {
        firstSelectedCard!.isMatched = true;
        secondSelectedCard!.isMatched = true;
        score += 10; // Points for correct match
      } else {
        // Delay before flipping back the cards if they don't match
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            firstSelectedCard!.isFaceUp = false;
            secondSelectedCard!.isFaceUp = false;
          });
        });
      }
      // Reset the selection after the match check
      firstSelectedCard = null;
      secondSelectedCard = null;
      isChecking = false;
    });
  }

  void _onCardTapped(CardModel card) {
    if (isChecking || card.isFaceUp || card.isMatched) return;

    setState(() {
      card.isFaceUp = true;

      if (firstSelectedCard == null) {
        firstSelectedCard = card;
      } else if (secondSelectedCard == null) {
        secondSelectedCard = card;
        isChecking = true;
        _checkMatch();  // Check if the two selected cards match
      }
    });
  }

  void _restartGame() {
    setState(() {
      _initializeCards();
      score = 0;
      timeElapsed = 0;
      firstSelectedCard = null;
      secondSelectedCard = null;
      _startTimer();
    });
  }

  bool _checkWinCondition() {
    return cards.every((card) => card.isMatched);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkWinCondition()) {
      _stopTimer();
      Future.delayed(Duration(seconds: 1), () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Victory!'),
              content: Text('You matched all cards in $timeElapsed seconds with a score of $score.'),
              actions: [
                TextButton(
                  child: Text('Restart'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                ),
              ],
            );
          },
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: _restartGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $timeElapsed sec', style: TextStyle(fontSize: 18)),
                Text('Score: $score', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Adjust the number of cards per row
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1, // Ensure cards are square
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return AspectRatio(
                  aspectRatio: 1, // Ensures each card is square
                  child: GestureDetector(
                    onTap: () => _onCardTapped(card),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(10),
                        image: card.isFaceUp
                            ? DecorationImage(
                                image: AssetImage(card.asset),
                                fit: BoxFit.contain, // Ensures image fits within the card
                              )
                            : null,
                      ),
                      child: card.isFaceUp
                          ? null
                          : Center(
                              child: Text(
                                '?',
                                style: TextStyle(fontSize: 32, color: Colors.white),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
