import 'package:flutter/material.dart';

const coffee = Color(0xFF51382F);
const cream = Color(0xFFFAF6EF);
const olive = Color(0xFF626A49);

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

class Drink {
  final String name;
  final String description;
  final int price;
  final IconData icon;

  const Drink(this.name, this.description, this.price, this.icon);
}

const menu = [
  Drink('Latte', 'Espresso, steamed milk, a little foam', 425,
      Icons.local_cafe_outlined),
  Drink('Cappuccino', 'Equal parts espresso, milk, and foam', 400,
      Icons.coffee_outlined),
  Drink('Cold Brew', 'Slow steeped and served over ice', 375,
      Icons.local_drink_outlined),
  Drink('Mocha', 'Espresso with chocolate and milk', 475,
      Icons.emoji_food_beverage_outlined),
];

void main() => runApp(const CampusCupApp());

class CampusCupApp extends StatelessWidget {
  const CampusCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cup',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coffee,
          primary: coffee,
          secondary: olive,
          surface: cream,
        ),
        scaffoldBackgroundColor: cream,
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
  final quantities = List<int>.filled(menu.length, 0);
  int tipPercent = 0;

  int get itemCount => quantities.fold(0, (sum, quantity) => sum + quantity);

  int get subtotal {
    var amount = 0;
    for (var i = 0; i < menu.length; i++) {
      amount += menu[i].price * quantities[i];
    }
    return amount;
  }

  int get tip => (subtotal * tipPercent / 100).round();
  int get total => subtotal + tip;

  void changeQuantity(int index, int change) {
    final next = quantities[index] + change;
    if (next < 0 || next > 9) return;
    setState(() => quantities[index] = next);
  }

  void confirmOrder() {
    if (itemCount == 0) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        icon: const Icon(Icons.check_circle_outline, color: olive, size: 42),
        title: const Text('Order confirmed!'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thanks for stopping by Campus Cup.'),
            const SizedBox(height: 16),
            for (var i = 0; i < menu.length; i++)
              if (quantities[i] > 0)
                PriceLine(
                  label: '${quantities[i]} × ${menu[i].name}',
                  amount: menu[i].price * quantities[i],
                ),
            const Divider(),
            PriceLine(label: 'Tip ($tipPercent%)', amount: tip),
            PriceLine(label: 'Total', amount: total, bold: true),
            const SizedBox(height: 16),
            const Text('Pick up at the counter in about 10 minutes.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                quantities.fillRange(0, quantities.length, 0);
                tipPercent = 0;
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CafeHeader(),
                  const SizedBox(height: 28),
                  const Text('Find your usual.',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: coffee)),
                  const SizedBox(height: 4),
                  const Text('Made fresh. Ready for your next class.',
                      style: TextStyle(color: Color(0xFF746960))),
                  const SizedBox(height: 18),
                  for (var i = 0; i < menu.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DrinkCard(
                        drink: menu[i],
                        quantity: quantities[i],
                        onAdd: () => changeQuantity(i, 1),
                        onRemove: () => changeQuantity(i, -1),
                      ),
                    ),
                  if (itemCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEEDD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('A little thanks',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Text('$tipPercent% · ${money(tip)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text('Optional tip for the crew'),
                          // New widget: Slider lets you choose a tip from 0–20%.
                          Slider(
                            key: const Key('tip-slider'),
                            value: tipPercent.toDouble(),
                            min: 0,
                            max: 20,
                            divisions: 4,
                            label: '$tipPercent%',
                            semanticFormatterCallback: (value) =>
                                '${value.round()} percent tip',
                            activeColor: olive,
                            onChanged: (value) =>
                                setState(() => tipPercent = value.round()),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Tap + to start your order.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF746960))),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5DDD3))),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (itemCount > 0) ...[
                      PriceLine(label: 'Drinks ($itemCount)', amount: subtotal),
                      PriceLine(label: 'Tip ($tipPercent%)', amount: tip),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        Text(money(total),
                            key: const Key('order-total'),
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: coffee)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('place-order'),
                      onPressed: itemCount == 0 ? null : confirmOrder,
                      icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                      label: const Text('Place pickup order'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CafeHeader extends StatelessWidget {
  const CafeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: coffee,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CAMPUS CUP',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
                SizedBox(height: 10),
                Text('Good coffee.\nBetter study breaks.',
                    style: TextStyle(
                        color: Color(0xFFF0DCC6), fontSize: 15, height: 1.5)),
                SizedBox(height: 16),
                Text('PICKUP AT THE COUNTER',
                    style: TextStyle(
                        color: Color(0xFFF0DCC6),
                        fontSize: 10,
                        letterSpacing: 1.1)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
                color: Color(0xFF715348), shape: BoxShape.circle),
            child: const Icon(Icons.local_cafe,
                size: 44,
                color: Color(0xFFF0DCC6),
                semanticLabel: 'Coffee cup logo'),
          ),
        ],
      ),
    );
  }
}

class DrinkCard extends StatelessWidget {
  final Drink drink;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const DrinkCard(
      {super.key,
      required this.drink,
      required this.quantity,
      required this.onAdd,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: quantity > 0 ? olive : const Color(0xFFE5DDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: const Color(0xFFF3EBDF),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(drink.icon, color: coffee),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(drink.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18))),
              Text(money(drink.price),
                  style: const TextStyle(
                      color: coffee,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(drink.description,
              style: const TextStyle(color: Color(0xFF746960), fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                key: Key('remove-${drink.name}'),
                tooltip: 'Remove one ${drink.name}',
                onPressed: quantity == 0 ? null : onRemove,
                icon: const Icon(Icons.remove_circle_outline),
                color: olive,
              ),
              SizedBox(
                  width: 24,
                  child: Text('$quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600))),
              IconButton(
                key: Key('add-${drink.name}'),
                tooltip: 'Add one ${drink.name}',
                onPressed: quantity == 9 ? null : onAdd,
                icon: const Icon(Icons.add_circle),
                color: olive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PriceLine extends StatelessWidget {
  final String label;
  final int amount;
  final bool bold;

  const PriceLine(
      {super.key,
      required this.label,
      required this.amount,
      this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style =
        TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 16),
          Text(money(amount), style: style),
        ],
      ),
    );
  }
}
