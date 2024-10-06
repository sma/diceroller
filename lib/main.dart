import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

/// Represents a die with a given number of sides and color.
class Die {
  const Die(this.sides, this.color);

  final int sides;
  final Color color;

  DieResult roll() => DieResult(this, random.nextInt(sides) + 1);

  static final random = Random();

  static final dice = [
    Die(2, Colors.red),
    Die(3, Colors.orange),
    Die(4, Colors.blue),
    Die(5, Colors.green),
    Die(6, Colors.deepOrange),
    Die(7, Colors.teal),
    Die(8, Colors.purple),
    Die(10, Colors.lightBlue),
    Die(12, Colors.brown),
    Die(14, Colors.pink),
    Die(16, Colors.indigo.shade700),
    Die(20, Colors.cyan),
    Die(24, Colors.lime.shade700),
    Die(30, Colors.grey),
    Die(50, Colors.blueGrey),
    Die(100, Colors.deepPurple),
  ];
}

/// Represents the result of rolling a die.
class DieResult {
  const DieResult(this.die, this.result);

  final Die die;
  final int result;

  bool get isMin => result == 1;
  bool get isMax => result == die.sides;
}

/// The model for the dice roller.
final model = ValueNotifier<List<DieResult>>([]);

/// The "business logic" for the model.
extension on ValueNotifier<List<DieResult>> {
  void add(Die die) => value = [...value, die.roll()];

  void remove(DieResult result) => value = value.toList()..remove(result);

  void clear() => value = [];

  void sort() => value = [...value]..sort((a, b) => a.result.compareTo(b.result));

  void reroll() => value = [...value.map((r) => r.die.roll())];

  int get sum => value.fold(0, (previousValue, element) => previousValue + element.result);
  int get minimum => value.fold(1 << 31, (previousValue, element) => min(previousValue, element.result));
  int get maximum => value.fold(0, (previousValue, element) => max(previousValue, element.result));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: DiceRoller(),
    );
  }
}

class DiceRoller extends StatelessWidget {
  const DiceRoller({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey.shade800,
        title: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            if (model.value.length < 2) return Text('Dice Roller');
            return Text('∑${model.sum} ↓${model.minimum} ↑${model.maximum}');
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ResultsBox(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Commands(),
          ),
          Expanded(
            child: DieButtonGrid(),
          ),
        ],
      ),
    );
  }
}

class Commands extends StatelessWidget {
  const Commands({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: CommandButton(
            onPressed: model.clear,
            label: Text('Clear'),
          ),
        ),
        Expanded(
          child: CommandButton(
            onPressed: model.reroll,
            label: Text('Reroll'),
          ),
        ),
        Expanded(
          child: CommandButton(
            onPressed: model.sort,
            label: Text('Sort'),
          ),
        ),
      ],
    );
  }
}

class CommandButton extends StatelessWidget {
  const CommandButton({super.key, required this.onPressed, required this.label});

  final VoidCallback? onPressed;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        padding: EdgeInsets.all(8),
      ),
      onPressed: onPressed,
      child: label,
    );
  }
}

class ResultsBox extends StatelessWidget {
  const ResultsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        constraints: BoxConstraints(minHeight: 56 * 2 + 8 + 16),
        padding: EdgeInsets.all(8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final result in model.value) Result(result),
          ],
        ),
      ),
    );
  }
}

class Result extends StatelessWidget {
  const Result(this.result, {super.key});

  final DieResult result;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: result.isMax ? BadgePainter() : null,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: result.die.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          padding: EdgeInsets.all(4),
          fixedSize: Size(56, 56),
        ),
        onPressed: () {
          model.remove(result);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(
                '${result.result}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1),
              ),
            ),
            Text(
              'd${result.die.sides}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class DieButtonGrid extends StatelessWidget {
  const DieButtonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        ...Die.dice.map(
          (die) => DieButton(die: die),
        ),
      ],
    );
  }
}

class DieButton extends StatelessWidget {
  const DieButton({super.key, required this.die});

  final Die die;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: die.color,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 18),
      ),
      onPressed: () => model.add(die),
      onLongPress: () => showDialog<void>(context: context, builder: (_) => DieDialog(die)),
      child: Text('d${die.sides}'),
    );
  }
}

class BadgePainter extends CustomPainter {
  final _paint = Paint()..color = Colors.white60;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..translate(size.width, 0)
      ..drawPath(
          Path()
            ..moveTo(-24, 0)
            ..lineTo(0, 24)
            ..lineTo(0, 12)
            ..lineTo(-12, 0)
            ..close(),
          _paint);
  }

  @override
  bool shouldRepaint(BadgePainter oldDelegate) => false;
}

class DieDialog extends StatelessWidget {
  const DieDialog(this.die, {super.key});

  final Die die;

  static final exploding = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: die.color,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
              listenable: exploding,
              builder: (context, _) {
                return TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    iconColor: Colors.white,
                    fixedSize: Size.fromHeight(40),
                  ),
                  onPressed: () {
                    exploding.value = !exploding.value;
                  },
                  icon: exploding.value //
                      ? Icon(Icons.check_box)
                      : Icon(Icons.check_box_outline_blank),
                  label: Text('Exploding dice'),
                );
              }),
          for (var i = 1; i <= 12; i += 3)
            Row(
              children: [
                for (var j = 0; j < 3; j++)
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        fixedSize: Size.fromHeight(40),
                      ),
                      onPressed: () {
                        _roll(i + j);
                        Navigator.of(context).pop();
                      },
                      child: Text('${i + j}d${die.sides}'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _roll(int n) {
    for (var i = 0; i < n; i++) {
      model.add(die);
      if (exploding.value && model.value.last.isMax) {
        _roll(1);
      }
    }
  }
}
