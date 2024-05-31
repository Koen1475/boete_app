import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Importeer de geolocator package

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
  double snelheid = 0.0; // Variabele om de snelheid op te slaan
  String status = 'Snelheid niet beschikbaar'; // Statusbericht voor snelheid
  bool showFloatingButton =
      true; // Variabele om de zichtbaarheid van de zwevende actieknop te bepalen

  @override
  void initState() {
    super.initState();
    _getCurrentSpeed(); // Haal de huidige snelheid op wanneer de app wordt gestart
  }

  Future<void> _getCurrentSpeed() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Controleer of locatie services aan staan
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        status = 'Locatieservices staan uit';
      });
      return;
    }

    // Controleer permissies
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          status = 'Locatie permissies geweigerd';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        status = 'Locatie permissies permanent geweigerd';
      });
      return;
    }

    // Start het ophalen van de snelheid
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, // Hoogste nauwkeurigheid vereist
        distanceFilter:
            10, // Update alleen wanneer de afstand van de vorige locatie groter is dan 10 meter
      ),
    ).listen((Position position) {
      setState(() {
        snelheid =
            position.speed * 3.6; // Converteer snelheid van m/s naar km/h
        status =
            'Snelheid: ${snelheid.toStringAsFixed(2)} km/h'; // Toon de huidige snelheid
        showFloatingButton = snelheid <=
            10; // Controleer of de knop moet worden weergegeven op basis van de snelheid
      });
    });
  }

  void _openSettings() {
    // Toon het instellingenscherm als de gebruiker op de zwevende actieknop klikt
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Sluit het instellingenscherm
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
        child: snelheid >
                30 // Als de snelheid hoger is dan 30 km/h, toon dan de boete cirkel, anders toon de status van de snelheid
            ? FineCircle(fineAmount: _calculateFine())
            : Text(
                status,
                style: const TextStyle(fontSize: 24),
              ),
      ),
      floatingActionButton: showFloatingButton
          ? FloatingActionButton(
              onPressed:
                  _openSettings, // Open het instellingenscherm wanneer de gebruiker op de knop klikt
              backgroundColor: Colors.blue, // Maak de FAB blauw
              child: const Icon(Icons.settings),
            )
          : null, // Verberg de knop als de snelheid hoger is dan 10 km/h
    );
  }

  double _calculateFine() {
    if (snelheid <= 30) {
      return 0.0; // Geen boete als de snelheid 30 km/h of minder is
    }

    if (binnenBebouwdeKom) {
      // Bereken de overtreding (snelheid boven de limiet van 30 km/h)
      double overtreding = snelheid - 30;
      if (overtreding <= 5) {
        return 43.0;
      } else if (overtreding <= 10) {
        return 90.0;
      } else if (overtreding <= 15) {
        return 169.0;
      } else if (overtreding <= 20) {
        return 240.0;
      } else if (overtreding <= 25) {
        return 325;
      } else if (overtreding <= 30) {
        return 421.0;
      } else {
        return double.infinity; // Meer dan 30 km/h: strafbeschikking
      }
    } else if (buitenBebouwdeKom) {
      // Bereken de overtreding (snelheid boven de limiet van 50 km/h)
      double overtreding = snelheid - 50;
      if (overtreding <= 5) {
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
      if (overtreding <= 5) {
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
    return 0.0; // Als geen van de bovenstaande voorwaarden waar is, retourneer 0.0
  }
}

class FineCircle extends StatelessWidget {
  final double fineAmount;

  FineCircle({required this.fineAmount});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    // Bepaal de achtergrondkleur op basis van de hoogte van de boete
    if (fineAmount < 75) {
      backgroundColor = Colors.yellow;
    } else if (fineAmount >= 75 && fineAmount <= 150) {
      backgroundColor = Colors.orange;
    } else {
      backgroundColor = Colors.red;
    }

    // Bepaal de tekstkleur op basis van de achtergrondkleur
    textColor =
        backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      width: 300, // Diameter van de cirkel
      height: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          fineAmount == double.infinity
              ? 'Strafbeschikking'
              : '€${fineAmount.toStringAsFixed(2)}',
          style: TextStyle(
            color: textColor,
            fontSize: 54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
