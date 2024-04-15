// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salvador_task_management/src/config/rowsperpage.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/interventi_aperti_controller.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/interventi_datasource.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/list_interventi_aperti_datasource_columns.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/interventi_api_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InterventiApertiPage extends ConsumerWidget {
  InterventiApertiPage({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String lastFromDate = '';
  String lastToDate = '';
  String lastNdoc = '';
  String lastCliente = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var interventi = ref.watch(interventiApertiControllerProvider);
    final columns = interventiApertiDataSourceColumns();
    final rowsPerPage = ref.watch(rowsPerPageProvider);
    var nuovoInterventoAsyncValue = ref.watch(interventiDbRepositoryProvider);
    List<Intervento>? nuovoInterventoList;

    nuovoInterventoAsyncValue.when(
      data: (data) {
        nuovoInterventoList = data;
      },
      loading: () {
        // Gestisci il caso in cui i dati siano ancora in caricamento
      },
      error: (error, stackTrace) {
        // Gestisci il caso in cui si sia verificato un errore durante il recupero dei dati
      },
    );

    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      textStyle: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      side: const BorderSide(
        color: Colors.black,
        width: 1,
      ),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                                    var interventi =
                      await ref.read(interventiApiProvider.call().future);
                  var interventiDbNotifier =
                      ref.read(interventiDbRepositoryProvider.notifier);
                  interventiDbNotifier.updateInterventi(interventi);
                },
                style: buttonStyle,
                icon: const Icon(Icons.refresh),
                label: const Text('Aggiorna'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _showFilterMenu(context, ref);
                },
                style: buttonStyle,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Filtra'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: interventi.when(
              data: (data) {
                data.sort((a, b) => (b.dataDoc).compareTo(a.dataDoc));
                nuovoInterventoList
                    ?.sort((a, b) => (b.dataDoc).compareTo(a.dataDoc));

                return SfDataGrid(
                  source: InterventiApertiDataSource(
                      data, nuovoInterventoList ?? [], ref, context),
                  columns: columns,
                  headerGridLinesVisibility: GridLinesVisibility.horizontal,
                  gridLinesVisibility: GridLinesVisibility.both,
                  showCheckboxColumn: false,
                  columnWidthMode: ColumnWidthMode.fill,
                  checkboxShape: const CircleBorder(),
                  checkboxColumnSettings: const DataGridCheckboxColumnSettings(
                    showCheckboxOnHeader: false,
                  ),
                  selectionMode: SelectionMode.multiple,
                  allowFiltering: false,
                  allowEditing: true,
                  rowsPerPage: rowsPerPage,
                  shrinkWrapRows: true,
                );
              },
              error: (err, stack) => Center(child: Text('Error: $err')),
              loading: () => const Center(
                child: RotatingHourglass(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterMenu(BuildContext context, WidgetRef ref) async {
    String lastRifMatricolaCliente = '';
    String lastTelaio = '';

    TextEditingController fromDateController =
        TextEditingController(text: lastFromDate);
    TextEditingController toDateController =
        TextEditingController(text: lastToDate);

    void setCurrentDate(String field) {
      DateTime currentDate = DateTime.now();
      String formattedDate = currentDate.toLocal().toString().split(' ')[0];

      if (field == 'fromDate') {
        fromDateController.text = formattedDate;
        lastFromDate = formattedDate;
        if (toDateController.text.isEmpty) {
          lastToDate = formattedDate;
        }
      } else if (field == 'toDate') {
        toDateController.text = formattedDate;
        lastToDate = formattedDate;
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_alt),
              SizedBox(width: 2),
              Text('Filtra'),
            ],
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (String value) {
                      lastNdoc = value;
                    },
                    controller: TextEditingController(text: lastNdoc),
                    style: const TextStyle(fontSize: 16.0),
                    decoration: InputDecoration(
                      labelText: 'N° Doc',
                      labelStyle: const TextStyle(fontSize: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 243, 159, 33),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (String value) {
                      lastCliente = value;
                    },
                    controller: TextEditingController(text: lastCliente),
                    decoration: InputDecoration(
                      labelText: 'Cliente',
                      labelStyle: const TextStyle(fontSize: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 243, 159, 33),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (String value) {
                      lastRifMatricolaCliente = value;
                    },
                    controller:
                        TextEditingController(text: lastRifMatricolaCliente),
                    decoration: InputDecoration(
                      labelText: 'Targa/N°',
                      labelStyle: const TextStyle(fontSize: 16.0),
                      border: OutlineInputBorder(
                        // Bordo esterno
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 243, 159, 33),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (String value) {
                      lastTelaio = value;
                    },
                    controller: TextEditingController(text: lastTelaio),
                    decoration: InputDecoration(
                      labelText: 'Telaio',
                      labelStyle: const TextStyle(fontSize: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(255, 243, 159, 33),
                            width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              cancelText: 'Annulla',
                            );

                            if (selectedDate != null) {
                              fromDateController.text = selectedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0];
                              lastFromDate = selectedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0];
                            } else {
                              fromDateController.clear();
                            }
                          },
                          readOnly: true,
                          controller: fromDateController,
                          decoration: InputDecoration(
                            labelText: 'Data Inizio',
                            labelStyle: const TextStyle(fontSize: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 243, 159, 33),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.schedule),
                              onPressed: () => setCurrentDate('fromDate'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              cancelText: 'Annulla',
                            );

                            if (selectedDate != null) {
                              toDateController.text = selectedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0];
                              lastToDate = selectedDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0];
                            } else {
                              toDateController.clear();
                            }
                          },
                          readOnly: true,
                          controller: toDateController,
                          decoration: InputDecoration(
                            labelText: 'Data Fine',
                            labelStyle: const TextStyle(fontSize: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 243, 159, 33),
                                  width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            suffixIcon: IconButton(
                              // Icona a destra
                              icon: const Icon(Icons.schedule),
                              onPressed: () => setCurrentDate('toDate'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        lastFromDate = '';
                        lastToDate = '';
                        lastNdoc = '';
                        lastCliente = '';

                        fromDateController.text = '';
                        toDateController.text = '';

                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Colors.grey),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(double.infinity, 40)),
                      ),
                      child: const Text(
                        'Annulla',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (lastFromDate.isNotEmpty && lastToDate.isEmpty) {
                          DateTime currentDate = DateTime.now();
                          String formattedDate =
                              currentDate.toLocal().toString().split(' ')[0];
                          toDateController.text = formattedDate;
                          lastToDate = formattedDate;
                        }
                        Navigator.of(context).pop();
                        ref.read(interventiApertiControllerProvider.notifier);
                        // .applyFilter(
                        //   fromDate: lastFromDate,
                        //   toDate: lastToDate,
                        //   nDoc: lastNdoc,
                        //   cliente: lastCliente,
                        //   rifMatricolaCliente: lastRifMatricolaCliente,
                        //   telaio: lastTelaio,
                        // );
                        applyFilter(
                            fromDate: lastFromDate,
                            toDate: lastToDate,
                            nDoc: lastNdoc,
                            cliente: lastCliente,
                            rifMatricolaCliente: lastRifMatricolaCliente,
                            telaio: lastTelaio,
                            ref: ref);
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          const BorderSide(color: Colors.grey),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size(double.infinity, 40)),
                      ),
                      child: const Text(
                        'Applica',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

void applyFilter({
  required String fromDate,
  required String toDate,
  required String nDoc,
  required String cliente,
  required String rifMatricolaCliente,
  required String telaio,
  required WidgetRef ref,
}) {
  final interventi = ref.read(interventiDbRepositoryProvider);

  interventi.when(
    data: (data) {
      List<Intervento> nuovoInterventoList = List.from(data);

      if (fromDate.isNotEmpty && toDate.isNotEmpty) {
        DateTime from = DateTime.parse(fromDate);
        DateTime to = DateTime.parse(toDate);

        nuovoInterventoList = nuovoInterventoList.where((intervento) {
          var dataDoc = DateTime.parse(intervento.dataDoc as String);

          return dataDoc.isAfter(from.subtract(const Duration(days: 1))) &&
              dataDoc.isBefore(to.add(const Duration(days: 1)));
        }).toList();
      }

      if (nDoc.isNotEmpty) {
        nuovoInterventoList = nuovoInterventoList
            .where((intervento) => intervento.numDoc?.contains(nDoc) ?? false)
            .toList();
      }
      if (cliente.isNotEmpty) {
        nuovoInterventoList = nuovoInterventoList
            .where((intervento) =>
                intervento.cliente?.descrizione?.contains(cliente) ?? false)
            .toList();
      }
      if (rifMatricolaCliente.isNotEmpty) {
        nuovoInterventoList = nuovoInterventoList
            .where((intervento) =>
                intervento.rifMatricolaCliente?.contains(rifMatricolaCliente) ??
                false)
            .toList();
      }
      if (telaio.isNotEmpty) {
        nuovoInterventoList = nuovoInterventoList
            .where((intervento) => intervento.telaio?.contains(telaio) ?? false)
            .toList();
      }

      // Aggiorna lo stato con i dati filtrati
      ref.read(interventiDbRepositoryProvider.notifier);
    },
    error: (error, stackTrace) {
      // Gestisci il caso in cui si sia verificato un errore durante il recupero dei dati
    },
    loading: () {
      // Gestisci il caso in cui i dati siano ancora in caricamento
    },
  );
}

class RotatingHourglass extends StatefulWidget {
  const RotatingHourglass({super.key});

  @override
  RotatingHourglassState createState() => RotatingHourglassState();
}

class RotatingHourglassState extends State<RotatingHourglass>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: const Icon(
        Icons.hourglass_bottom,
        size: 40,
      ),
    );
  }
}
