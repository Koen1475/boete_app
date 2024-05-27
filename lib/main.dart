import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speeding Fine Calculator',
      theme: ThemeData.light(), // Licht thema
      darkTheme: ThemeData.dark(), // Donker thema
      themeMode: ThemeMode.dark, // Standaard naar donker thema
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool binnenBebouwdeKom = false;
  bool buitenBebouwdeKom = false;
  bool snelweg = false;
  double snelheid = 0.0;

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text("Binnen bebouwde kom"),
                value: binnenBebouwdeKom,
                onChanged: (bool? value) {
                  setState(() {
                    binnenBebouwdeKom = value ?? false;
                    if (binnenBebouwdeKom) {
                      buitenBebouwdeKom = false;
                      snelweg = false;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Buiten bebouwde kom"),
                value: buitenBebouwdeKom,
                onChanged: (bool? value) {
                  setState(() {
                    buitenBebouwdeKom = value ?? false;
                    if (buitenBebouwdeKom) {
                      binnenBebouwdeKom = false;
                      snelweg = false;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Snelweg"),
                value: snelweg,
                onChanged: (bool? value) {
                  setState(() {
                    snelweg = value ?? false;
                    if (snelweg) {
                      binnenBebouwdeKom = false;
                      buitenBebouwdeKom = false;
                    }
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Snelheid in km/u",
                ),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  setState(() {
                    snelheid = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Instellingen opslaan"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speeding Fine Calculator'),
      ),
      body: Center(
        child: FineCircle(fineAmount: _calculateFine()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSettings,
        backgroundColor: Colors.blue, // Maak de FAB blauw
        child: const Icon(Icons.settings),
      ),
    );
  }

  double _calculateFine() {
    // Controleer of de gebruiker binnen bebouwde kom rijdt
    if (binnenBebouwdeKom) {
      // Bereken de overtreding (snelheid boven de limiet van 30 km/h)
      double overtreding = snelheid - 30;
      if (overtreding <= 0) {
        return 0.0; // Geen overtreding
      } else if (overtreding <= 5) {
        return 43.0;
      } else if (overtreding <= 10) {
        return 90.0;
      } else if (overtreding <= 15) {
        return 169.0;
      } else if (overtreding <= 20) {
        return 240.0;
      } else if (overtreding <= 25) {
        return 325.0;
      } else if (overtreding <= 30) {
        return 421.0;
      } else {
        return double.infinity; // Meer dan 30 km/h: strafbeschikking
      }
    } else if (buitenBebouwdeKom) {
      // Bereken de overtreding (snelheid boven de limiet van 50 km/h)
      double overtreding = snelheid - 50;
      if (overtreding <= 0) {
        return 0.0; // Geen overtreding
      } else if (overtreding <= 5) {
        return 39.0;
      } else if (overtreding <= 10) {
        return 84.0;
      } else if (overtreding <= 15) {
        return 162.0;
      } else if (overtreding <= 20) {
        return 230.0;
      } else if (overtreding <= 25) {
        return 308.0;
      } else if (overtreding <= 30) {
        return 401.0;
      } else {
        return double.infinity; // Meer dan 30 km/h: strafbeschikking
      }
    } else if (snelweg) {
      // Bereken de overtreding (snelheid boven de limiet van 100 km/h)
      double overtreding = snelheid - 100;
      if (overtreding <= 0) {
        return 0.0; // Geen overtreding
      } else if (overtreding <= 5) {
        return 32.0;
      } else if (overtreding <= 10) {
        return 79.0;
      } else if (overtreding <= 15) {
        return 150.0;
      } else if (overtreding <= 20) {
        return 216.0;
      } else if (overtreding <= 25) {
        return 287.0;
      } else if (overtreding <= 30) {
        return 368.0;
      } else if (overtreding <= 35) {
        return 495.0;
      } else {
        return double.infinity; // Meer dan 40 km/h: strafbeschikking
      }
    }
    return 0.0;
  }
}

class FineCircle extends StatelessWidget {
  final double fineAmount;

  FineCircle({required this.fineAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Diameter van de cirkel
      height: 300,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          fineAmount == double.infinity
              ? 'Strafbeschikking'
              : '€${fineAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
