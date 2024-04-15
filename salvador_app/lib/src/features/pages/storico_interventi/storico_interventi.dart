import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/interventi_aperti.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/intervento_aperto_state.dart';
import 'package:salvador_task_management/src/features/pages/storico_interventi/storico_interventi_datasource_columns.dart';
import 'package:salvador_task_management/src/repository/storico_interventi_api_repository.dart';

// ignore: must_be_immutable
class StoricoInterventiPage extends ConsumerWidget {
  StoricoInterventiPage({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String lastFromDate = '';
  String lastToDate = '';
  String lastNdoc = '';
  String lastCliente = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervento = ref.watch(interventoApertoStateProvider);
    final columns = storicoInterventiDataSourceColumns();
    final disponibilitaRepository =
        ref.read(storicoInterventiApiRepositoryProvider);

    if (intervento.rifMatricolaCliente == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Targa non presente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.grey),
                  ),
                ),
                child: const Text(
                  'Esci',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'STORICO INTERVENTI - MATRICOLA: ${intervento.rifMatricolaCliente}'),
        backgroundColor: const Color.fromARGB(255, 236, 201, 148),
      ),
      body: Column(
        children: [
          //const SizedBox(height: 10,),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start, // Posiziona il pulsante a sinistra
          //   children: [
          //     const SizedBox(width: 15,),
          //     ElevatedButton.icon(
          //       onPressed: () {
          //         //_showFilterMenu(context, ref);
          //       },
          //       style: buttonStyleFilter,
          //       icon: const Icon(Icons.filter_alt),
          //       label: const Text('Filtra'),
          //     ),
          //   ],
          // ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                future: disponibilitaRepository.getStoricoInterventoTarga(
                    intervento.rifMatricolaCliente ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: RotatingHourglass());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    var qtaResiduaResponse = snapshot.data;

                    var filteredData = qtaResiduaResponse.where((intervento) {
                      return true;
                    }).toList();

                    filteredData.sort((a, b) {
                      var dateA = DateTime.parse(a['dataDoc']);
                      var dateB = DateTime.parse(b['dataDoc']);
                      return dateB.compareTo(dateA);
                    });

                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: GestureDetector(
                            onTap: () {
                              // showDialog(
                              //   context: context,
                              //   builder: (index) => const AlertDialog(
                              //     content: Text('Tipo Intervento:'),
                              //   ),
                              // );
                            },
                            child: DataTable(
                              border: TableBorder.all(width: 0.2),
                              columns: columns,
                              dataRowMinHeight: 100,
                              dataRowMaxHeight: 100,
                              headingRowColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                      (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .background;
                                }
                                return const Color.fromARGB(255, 236, 201, 148);
                              }),
                              rows: [
                                for (var intervento in filteredData)
                                  ...List<DataRow>.generate(
                                    intervento['righe'].length,
                                    (index) {
                                      final riga = intervento['righe'][index];
                                      final dataDoc =
                                          intervento['dataDoc'] != null
                                              ? DateFormat('dd/MM/yyyy').format(
                                                  DateTime.parse(
                                                      intervento['dataDoc']))
                                              : '';
                                      final cliente =
                                          intervento['cliente'] != null
                                              ? intervento['cliente']
                                                      ['descrizione'] ??
                                                  ''
                                              : '';
                                      final descrizioneIntervento =
                                          riga['descrizione'] ?? '';
                                      final descrizioniArticoli =
                                          riga['articolo'] != null
                                              ? riga['articolo']
                                                      ['descrizione'] ??
                                                  ''
                                              : '';
                                      final operatoriRighe =
                                          riga['operatore'] ?? '';

                                      return DataRow(
                                        cells: [
                                          DataCell(Text(dataDoc)),
                                          DataCell(Text(cliente)),
                                          DataCell(Text(descrizioneIntervento)),
                                          DataCell(Text(descrizioniArticoli)),
                                          DataCell(Text(operatoriRighe))
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );

//   final buttonStyleFilter = ElevatedButton.styleFrom(
//   foregroundColor: const Color.fromARGB(255, 0, 0, 0),
//   textStyle: const TextStyle(
//     fontSize: 18.0,
//     fontWeight: FontWeight.bold,
//   ),
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(8.0),
//   ),
//   side: const BorderSide(
//     color: Color.fromARGB(255, 39, 39, 39),
//     width: 1.5,
//   ),
// );
  }
}
