import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart';


class LivreursPage extends StatefulWidget {
  @override
  _LivreursPageState createState() => _LivreursPageState();
}

class _LivreursPageState extends State<LivreursPage> {
  String? arrivalTime;
  bool isLoading = true;
  final TextEditingController phoneController = TextEditingController();

  String? infoMessage;
  Color? infoMessageColor;
  List<dynamic> requestsList = [];
  String? phoneError;

  @override
  void initState() {
    super.initState();
    fetchEstimatedArrivalTime();
    fetchRequestsList();
  }

  bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(06|07)[0-9]{8}$');
    return regex.hasMatch(phone);
  }

  Future<void> fetchEstimatedArrivalTime() async {
    final result = await ApiService.getEstimatedArrivalTime();

    setState(() {
      arrivalTime = result.message;
      isLoading = false;
    });
  }

  Future<void> fetchRequestsList() async {
    final result = await ApiService.fetchRequests();
    if (result.success) {
      setState(() {
        requestsList = result.message as List<dynamic>;
      });
    } else {
      setState(() {
        requestsList = [];
      });
    }
  }

  void showTemporaryMessage(String message, Color color) {
    setState(() {
      infoMessage = message;
      infoMessageColor = color;
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          infoMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Restaurant O'Mexico"),
        ),
        backgroundColor: const Color.fromARGB(255, 248, 245, 243),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (infoMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: infoMessageColor?.withOpacity(0.2) ?? Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    infoMessage!,
                    style: TextStyle(
                      color: infoMessageColor ?? Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Prochain livreur peut arriver dans :',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Text(
                        arrivalTime ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return AlertDialog(
                              title: const Text("Numéro du client"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: "Entrez le numéro de téléphone",
                                      errorText: phoneError,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    phoneController.clear();
                                    phoneError = null;
                                  },
                                  child: const Text("Annuler"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final phone = phoneController.text.trim();
                                    final isValid = isValidPhoneNumber(phone);

                                    if (!isValid) {
                                      setModalState(() {
                                        phoneError = "Veuillez entrer un numéro valide (06 ou 07 + 8 chiffres)";
                                      });
                                      return;
                                    }

                                    final result = await ApiService.requestLivreur(phone);

                                    Navigator.of(context).pop(); // Fermer la popup

                                    if (mounted) {
                                      phoneController.clear();
                                      phoneError = null;

                                      fetchRequestsList(); // Refresh
                                      showTemporaryMessage(
                                        result.message,
                                        result.success ? Colors.green : Colors.red,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text("Demander"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Demander un Livreur',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Liste des demandes :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...requestsList.map((request) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Commande #${request['id'] ?? 'Inconnu'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${request['total'] ?? ''} Dhs",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(request['status'] ?? '--'),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
