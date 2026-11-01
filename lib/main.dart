import 'package:flutter/material.dart';

void main() => runApp(const CampusCupApp());

class Drink {
  final String name;
  final int price;

  const Drink(this.name, this.price);
}

const menu = [
  Drink('Latte', 425),
  Drink('Cappuccino', 400),
  Drink('Cold Brew', 375),
  Drink('Mocha', 475),
];

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

class CampusCupApp extends StatelessWidget {
  const CampusCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        scaffoldBackgroundColor: const Color(0xFFF7F3EE),
      ),
      home: const OrderPage(),
    );
  }
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final selected = List<bool>.filled(menu.length, false);

  int get total {
    var amount = 0;
    for (var i = 0; i < menu.length; i++) {
      if (selected[i]) amount += menu[i].price;
    }
    return amount;
  }

  void confirmOrder() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Order confirmed'),
        content: Text('Your total is ${money(total)}. Thank you!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Cup'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 480,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(Icons.local_cafe,
                    size: 48, color: Colors.brown, semanticLabel: 'Coffee cup'),
                const SizedBox(height: 12),
                const Text('Choose your drinks',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                for (var i = 0; i < menu.length; i++)
                  DrinkOption(
                    drink: menu[i],
                    selected: selected[i],
                    onChanged: (value) => setState(() => selected[i] = value),
                  ),
                if (selected.contains(true))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Your drinks are selected. Ready to order?',
                        textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 16),
                Text('Total: ${money(total)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: selected.contains(true) ? confirmOrder : null,
                  child: const Text('Confirm order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrinkOption extends StatelessWidget {
  final Drink drink;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const DrinkOption(
      {super.key,
      required this.drink,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // New widget: Card groups each drink and its checkbox.
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: CheckboxListTile(
        title: Text(drink.name),
        subtitle: Text(money(drink.price)),
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
      ),
    );
  }
}
