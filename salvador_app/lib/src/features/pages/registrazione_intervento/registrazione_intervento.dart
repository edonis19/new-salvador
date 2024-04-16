// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, unnecessary_string_interpolations

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/pages/articoli/articoli_controller.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/intervento_aperto_state.dart';
import 'package:salvador_task_management/src/features/pages/registrazione_intervento/articoli_datasource.dart';
import 'package:salvador_task_management/src/features/pages/registrazione_intervento/articoli_datasource_columns.dart';
import 'package:salvador_task_management/src/models/articolo_model.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/add_righe_repository.dart';
import 'package:salvador_task_management/src/repository/disponibilita_articoli_api_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';
import 'package:salvador_task_management/src/repository/movimento_magazzino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:roundcheckbox/roundcheckbox.dart';


// ignore: must_be_immutable
class RegistrazioneInterventoPage extends ConsumerWidget {
  //int index = 0;

  TimeOfDay? initialStartTime;
  TimeOfDay? initialEndTime;

  RegistrazioneInterventoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervento = ref.watch(interventoApertoStateProvider);

    double screenWidth = MediaQuery.of(context).size.width;

    final columns = articoliInterventiDataSourceColumns();

    return LayoutBuilder(
      builder: (context, constraints) {
        String? dataDocFormatted;
        if (intervento != null) {
          dataDocFormatted =
              DateFormat('dd/MM/yyyy').format(intervento.dataDoc);
        } else {}

        return Scaffold(
          appBar: AppBar(
            title: Text(
                '${intervento.numDoc} - $dataDocFormatted - ${intervento.cliente?.descrizione}'),
            backgroundColor: const Color.fromARGB(255, 236, 201, 148),
          ),
          body: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (screenWidth < 600) ...[
                  _buildButton(
                    onPressed: () {
                      _showAggiungiArticoloDialog(context, ref, intervento);
                    },
                    icon: Icons.construction,
                    label: 'Aggiungi Articolo',
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: () {
                      _showAggiungiNotaDialog(context, ref);
                    },
                    icon: Icons.note_add,
                    label: 'Aggiungi Nota',
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    onPressed: () {
                      List<PlatformFile> files =
                          [];
                      _showAllegatiDialog(
                          context, files, intervento.rifMatricolaCliente ?? '');
                    },
                    icon: Icons.attach_file,
                    label: 'Aggiungi Allegati',
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(height: 20),
                  Consumer(builder: ((context, ref, child) {
                    final intervento = ref.watch(interventoApertoStateProvider);

                    final prefs =
                        ref.read(sharedPreferencesProvider).asData!.value;

                    return Expanded(
                      child: SfDataGrid(
                        source: ArticoliInterventoDataSource(
                            intervento, prefs, ref),
                        columns: columns,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerGridLinesVisibility:
                            GridLinesVisibility.horizontal,
                        gridLinesVisibility: GridLinesVisibility.both,
                        allowEditing: true,
                        onCellTap: (details) {
                          final int idRiga = int.parse(
                              details.rowColumnIndex.rowIndex.toString());
                          final articolo = intervento.righe
                              .where((element) => element.idRiga == idRiga)
                              .firstOrNull;

                          if (articolo != null) {
                            final String columnName = details.column.columnName;

                            final isNoteNullOrEmpty =
                                articolo.note == null || articolo.note!.isEmpty;

                            if (columnName == 'quantita' ||
                                (columnName == 'note' && isNoteNullOrEmpty)) {
                              modifyDurataDialog(context, articolo, ref);
                            } else if (columnName == 'durata' ||
                                (columnName == 'note' && !isNoteNullOrEmpty)) {
                              modifyDurataDialog(context, articolo, ref);
                            }
                          }
                        },
                      ),
                    );
                  }))
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          onPressed: () {
                            _showAggiungiArticoloDialog(
                                context, ref, intervento);
                          },
                          icon: Icons.construction,
                          label: 'Aggiungi Articolo',
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildButton(
                          onPressed: () {
                            _showAggiungiNotaDialog(context, ref);
                          },
                          icon: Icons.note_add,
                          label: 'Aggiungi Nota',
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildButton(
                          onPressed: () {
                            List<PlatformFile> files =
                                [];
                            _showAllegatiDialog(context, files,
                                intervento.rifMatricolaCliente ?? '');
                          },
                          icon: Icons.attach_file,
                          label: 'Aggiungi Allegati',
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Consumer(builder: ((context, ref, child) {
                    final intervento = ref.watch(interventoApertoStateProvider);

                    final prefs =
                        ref.read(sharedPreferencesProvider).asData!.value;

                    return Expanded(
                      child: SfDataGrid(
                        source: ArticoliInterventoDataSource(
                            intervento, prefs, ref),
                        columns: columns,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerGridLinesVisibility:
                            GridLinesVisibility.horizontal,
                        gridLinesVisibility: GridLinesVisibility.both,
                        allowEditing: true,
                        onCellTap: (details) {
                          final int idRiga = int.parse(
                              details.rowColumnIndex.rowIndex.toString());
                          final riga = intervento.righe
                              .where((element) => element.idRiga == idRiga)
                              .firstOrNull;

                          if (riga != null) {
                            final String columnName = details.column.columnName;

                            final isNoteNullOrEmpty =
                                riga.note == null || riga.note!.isEmpty;

                            if ([
                              'SMANCAR',
                              'SMANCLI',
                              'SMANEST',
                              'SMANEST+40%',
                              'SMANESTFES',
                              'SMANFES',
                              'SMANINT',
                              'SMANSTD'
                            ].contains(riga.articolo?.codice)) {
                              modifyDurataDialog(context, riga,
                                  ref);
                            } else {
                              if (columnName == 'quantita' ||
                                  (columnName == 'note' && isNoteNullOrEmpty)) {
                                modifyDurataDialog(context, riga, ref);
                              } else if (columnName == 'durata' ||
                                  (columnName == 'note' &&
                                      !isNoteNullOrEmpty)) {
                                modifyDurataDialog(context, riga, ref);
                              }
                            }
                          }
                        },
                      ),
                    );
                  }))
                ],
                SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: ()async {
  try {
String formattedDate = DateFormat('yyyy-MM-dd').format(intervento.dataDoc);

List<RigaInvio> righe = [];

for (var riga in intervento.righe) {
  RigaInvio nuovaRiga = RigaInvio(
                            id: null,
                            idRiga: riga.idRiga,
                            riga: riga.riga,
                            descrizione: riga.descrizione,
                            articolo: InterventoArticoloInvio(
                              id: riga.articolo?.id,
                              codice: riga.articolo?.codice,
                              descrizione: riga.articolo?.descrizione,
                            ),
                            tipoRiga: null,
                            qta: riga.qta,
                            dtOraIni: riga.dtOraIni.toString(),
                            dtOraFin: riga.dtOraFin.toString(),
                            operatore: riga.operatore,
                            note: null,
                            noteDaStampare: null,
                            matricola: riga.matricola,
                            info: null,
                            warning: null,
                            error: null, 
  );

  righe.add(nuovaRiga);
}

final result = await ref.read(addRigheApiRepositoryProvider).updateRighe(
  idTestata: intervento.idTestata,
  numDoc: intervento.numDoc,
  dataDoc: formattedDate,
  note: intervento.note,
  matricola: intervento.matricola,
  telaio: intervento.telaio,
  rifMatricolaCliente: intervento.rifMatricolaCliente,
  contMatricola: intervento.contMatricola,
  righe: righe,
  status: 'SOS',
  idCliente: intervento.cliente?.id,
  codiceCliente: intervento.cliente?.codice,
  descrizioneCliente: intervento.cliente?.descrizione,
  idTipoDoc: intervento.tipoDoc?.id,
  codiceTipoDoc: intervento.tipoDoc?.codice,
  descrizioneTipoDoc: intervento.tipoDoc?.descrizione,
);


    final resultMap = result as Map<String, dynamic>;
    final resultValue = resultMap['result'] as String;
    final errorList = resultMap['errorList'] as List<dynamic>;


    if (resultValue == 'OK') {
      var interventiDbProvider =
                        ref.read(interventiDbRepositoryProvider.notifier);
      await interventiDbProvider.deleteInterventoById(intervento.idTestata);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento registrato con successo.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      final errorMessage = errorList.isNotEmpty ? errorList.first.toString() : 'Errore sconosciuto';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Si è verificato un errore: $e'),
      backgroundColor: Colors.red,
    ),
  );
  }
},
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('Chiudi giornata'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            textStyle: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 60),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Completa Intervento'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    double height = 50.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: buttonStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(color),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final buttonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black,
    textStyle: const TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: const BorderSide(
        color: Colors.black,
        width: 1,
      ),
    ),
  );

  Future<void> _showAllegatiDialog(BuildContext context,
      List<PlatformFile> files, String rifMatricolaCliente) async {
    List<PlatformFile> allegati = List.from(files);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.attach_file),
              const SizedBox(width: 2),
              Text('ALLEGATI: $rifMatricolaCliente'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...allegati.map((file) {
                return InkWell(
                  onTap: () {
                    _openFile(file.path!);
                  },
                  child: Row(
                    children: [
                      Expanded(child: Text(file.name)),
                      IconButton(
                        onPressed: () {
                          allegati.remove(file);
                          Navigator.of(context).pop();
                          _showAllegatiDialog(
                              context, allegati, rifMatricolaCliente);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () async {
                    String? choice = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          children: [
                            SimpleDialogOption(
                              onPressed: () async {
                                final imagePicker = ImagePicker();
                                final XFile? pickedImage =
                                    await imagePicker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (pickedImage != null) {
                                  File newFile = File(pickedImage.path);
                                  PlatformFile platformFile = PlatformFile(
                                    name: pickedImage.path.split('/').last,
                                    path: pickedImage.path,
                                    size: await newFile.length(),
                                  );
                                  allegati.add(platformFile);
                                  Navigator.pop(context);
                                  _showAllegatiDialog(
                                      context, allegati, rifMatricolaCliente);
                                }
                              },
                              child: const Text('Scatta Foto'),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 'scegli');
                              },
                              child: const Text('Scegli File'),
                            ),
                          ],
                        );
                      },
                    );

                    if (choice == 'scegli') {
                      // Aggiungi qui la logica per scegliere un file
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.any,
                        allowedExtensions: ['jpg', 'pdf', 'doc', 'docx'],
                      );

                      if (result != null) {
                        // Aggiungi i nuovi file alla lista degli allegati
                        allegati.addAll(result.files);
                        Navigator.of(context).pop();
                        _showAllegatiDialog(
                            context, allegati, rifMatricolaCliente);
                      }
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Annulla',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Invia',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFile(String path) async {
    final result = await OpenFile.open(path);
    if (result.type != ResultType.done) {
      // Gestire il fallimento dell'apertura del file
    }
  }

  void _showAggiungiArticoloDialog(
      BuildContext context, WidgetRef ref, Intervento intervento) {
    String searchQuery = '';
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction),
                  SizedBox(width: 2),
                  Text('Articoli'),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              ref
                                  .read(articoliControllerProvider.notifier)
                                  .applyFilterArticoli(filterText: value);
                            },
                            onSubmitted: (_) {
                              _aggiungiArticoloIfSingle(
                                  context, ref, intervento);
                            },
                            decoration: InputDecoration(
                              labelText: 'Cerca per codice o descrizione',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide:
                                    const BorderSide(color: Colors.orange),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ref.watch(articoliControllerProvider).when(
                          data: (data) {
                            if (searchQuery.isEmpty) {
                              return const SizedBox();
                            } else {
                              final filteredData = data.where((articolo) {
                                final codice =
                                    articolo.codice.toString().toLowerCase();
                                final descrizione = articolo.descrizione
                                    .toString()
                                    .toLowerCase();
                                final searchWords =
                                    searchQuery.toLowerCase().split(' ');
                                return searchWords.every((word) =>
                                    codice.contains(word) ||
                                    descrizione.contains(word));
                              }).toList();

                              return Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredData.length,
                                  itemBuilder: (context, index) {
                                    var articolo = filteredData[index];
                                    //final articoloJson = articoloObj.toJson();
                                    //final articolo =
                                    //    InterventoArticoloState.fromJson(
                                    //        articoloJson);
                                    return ListTile(
                                      title: Text(articolo.descrizione),
                                      subtitle: Text(articolo.codice),
                                      onTap: () {
                                        final intervento = ref.read(
                                            interventoApertoStateProvider);
                                        _showAggiungiDettagliDialog(
                                            context, articolo, intervento, ref);
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) {
                            return Text('Error: $error');
                          },
                        ),
                  ],
                ),
              ),
              actions: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 60)),
                    ),
                    child: const Text(
                      'Chiudi',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(FocusNode());
      searchController.clear();
    });
  }

  void _aggiungiArticoloIfSingle(
      BuildContext context, WidgetRef ref, Intervento intervento) async {
    // final filteredData = ref.watch(articoliControllerProvider);
    // if (filteredData is AsyncData<List<Map<String, dynamic>>>) {
    //   if (filteredData.value.length == 1) {
    //     _showAggiungiDettagliDialog(context, filteredData.value.first, ref);
    //   }
    // }

    final filteredData = await ref.watch(articoliControllerProvider.future);
    final articolo = filteredData.first;
    _showAggiungiDettagliDialog(context, articolo, intervento, ref);
  }

  void addRiga(Articolo articolo, WidgetRef ref, Map<String, dynamic> params) {
    ref.read(interventoApertoStateProvider.notifier).addRiga(articolo, params);
  }

  void updateRiga(Riga riga, WidgetRef ref) {
    ref.read(interventoApertoStateProvider.notifier).updateRiga(riga);
  }

  void addNote(String note, WidgetRef ref) {
    ref.read(interventoApertoStateProvider.notifier).addNote(note);
  }

  void _showAggiungiDettagliDialog(BuildContext context, Articolo articolo,
      Intervento intervento, WidgetRef ref) async {
    if ([
      'SMANCAR',
      'SMANCLI',
      'SMANEST',
      'SMANEST+40%',
      'SMANESTFES',
      'SMANFES',
      'SMANINT',
      'SMANSTD'
    ].contains(articolo.codice)) {
      _showDurataDialog(context, articolo, intervento, ref);
    } else {
      _showQuantitaDialog(context, articolo, intervento, ref);
    }
  }

  String calculateDuration(TimeOfDay start, TimeOfDay end) {
    DateTime startDate = DateTime(2022, 1, 1, start.hour, start.minute);
    DateTime endDate = DateTime(2022, 1, 1, end.hour, end.minute);

    Duration difference = endDate.difference(startDate);
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    if (minutes <= 14) {
      minutes = 0;
    } else if (minutes <= 44) {
      minutes = 30;
    } else {
      minutes = 0;
      hours++;
    }

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _showDurataDialog(BuildContext context, Articolo articolo,
      Intervento intervento, WidgetRef ref) async {
    TimeOfDay? startTime = initialStartTime;
    TimeOfDay? endTime = initialEndTime;
    int quantity = 1;
    String notes = '';
    TextEditingController notesController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();
    TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.post_add),
              SizedBox(width: 2),
              Text('Dettagli'),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: startTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      startTime = picked;
                      startTimeController.text = _formatTimeOfDay(startTime!);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Inizio',
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: startTimeController,
                            enabled: false,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              startTime = picked;
                              startTimeController.text =
                                  _formatTimeOfDay(startTime!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: startTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      endTime = picked;
                      endTimeController.text = _formatTimeOfDay(endTime!);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fine',
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            enabled: false,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: endTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              endTime = picked;
                              endTimeController.text =
                                  _formatTimeOfDay(endTime!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (startTime != null && endTime != null) {
                        String duration =
                            calculateDuration(startTime!, endTime!);
                        double parseDuration(String durationString) {
                          if (durationString.contains(':')) {
                            final parts = durationString.split(':');
                            final hours = double.parse(parts[0]);
                            final minutes = double.parse(parts[1]);
                            return hours + (minutes / 60);
                          } else {
                            return double.parse(durationString);
                          }
                        }

                        String formattedStartTime = '${startTime!.hour}:${startTime!.minute}';
DateTime dtOraIni = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ' + formattedStartTime);
String formattedFinTime = '${endTime!.hour}:${endTime!.minute}';
DateTime dtOraFin = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()) + ' ' + formattedFinTime);






                        // double quantityDouble =
                        //     double.parse(quantity.toString());
                        double durationDouble = parseDuration(duration);
                        var prefs =
                            await ref.read(sharedPreferencesProvider.future);
                        final operatore = prefs.getString('user')?.toUpperCase();

                        Map<String, dynamic> params = {
                          'dataInserimento':
                              DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          'quantita': durationDouble,
                          'durataIni': dtOraIni,
                          'durataFin' : dtOraFin,
                          'note': notes,
                          'operatore': operatore,
                        };
                        // var interventoArticolo =
                        //     InterventoArticoloState.fromJson(articoloJson);
                        addRiga(articolo, ref, params);

                        initialStartTime = startTime;
                        initialEndTime = endTime;
                      }

                      final result = ref
                          .read(movimentoMagazzinoApiRepositoryProvider)
                          .updateQuantity(
                            codArt: articolo.codice,
                            desMov: articolo.descrizione,
                            note: notes,
                            tipoMov: 40,
                            mag: articolo.magazzino?.codice ?? '',
                            umMov: articolo.unimis?.codice ?? '',
                            qtaMov: quantity.toDouble(),
                          );

                      if (result != null) {
                        Navigator.pop(context);

                        return;
                      } else {}

                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey), // Bordo grigio
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(
                          double.infinity,
                          40)), // Larghezza espansa e altezza 50
                    ),
                    child: const Text(
                      'Conferma',
                      style: TextStyle(
                          color: Colors.black), // Colore del testo nero
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dateTime);
  }

  final sendEmailProvider = StateProvider<bool>((ref) => false);

  void _showQuantitaDialog(
    BuildContext context,
    Articolo articolo,
    Intervento intervento,
    WidgetRef ref,
  ) async {
    int quantity = 1;
    String notes = '';
    TextEditingController quantityController =
        TextEditingController(text: quantity.toString());
    TextEditingController notesController = TextEditingController();

    final disponibilitaRepository =
        ref.read(disponibilitaArticoliApiRepositoryProvider);
    final dataLim = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String codArt = articolo.codice;

    var sendEmailState = ref.watch(sendEmailProvider);

    double disp = 0;
    double giac = 0;
    double scorta = articolo.mtsScSic ?? 0.0;

    final qtaResiduaResponse =
        await disponibilitaRepository.getDisponibilitaArticoli(dataLim, codArt);

    if (qtaResiduaResponse != null) {
      final magazzinoSede = qtaResiduaResponse.firstWhere(
        (element) => element['magazzino'] == 'SEDE',
        orElse: () => null,
      );
      if (magazzinoSede != null) {
        disp = magazzinoSede['disp'];
        giac = magazzinoSede['giac'];
        //scorta = magazzinoSede['scoSic'];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 2),
                  Text('${articolo.codice} (${articolo.unimis?.codice})'),
                ],
              ),
              const Divider(),
              Text(
                articolo.descrizione,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: 20,
                      onPressed: () {
                        if (quantity > 1) {
                          quantity--;
                          quantityController.text = quantity.toString();
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          quantity = int.tryParse(value) ?? 1;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Quantità',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                      onPressed: () {
                        quantity++;
                        quantityController.text = quantity.toString();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    DataTable(
      columns: const [
        DataColumn(label: Text('Disp.')),
        DataColumn(label: Text('Scorta')),
        DataColumn(label: Text('Giac.')),
      ],
      rows: [
        DataRow(cells: [
          DataCell(Text(disp.toInt().toString())),
          DataCell(Text(scorta.toInt().toString())),
          DataCell(Text(giac.toInt().toString())),
        ]),
      ],
    ),
    Row(
      children: [
        const SizedBox(height: 20),
RoundCheckBox(  
                  onTap: (selected) {
                      // Inverti lo stato della checkbox
                      sendEmailState = !sendEmailState;
                  },
                  size: 25,
                  isChecked: sendEmailState, // Passa lo stato attuale alla checkbox
                ),
        const SizedBox(width: 10,),
        const Text('Invia segnalazione'),
      ],
    ),
  ],
),
                const SizedBox(height: 20),
                TextField(
                  controller: notesController,
                  onChanged: (value) {
                    notes = value;
                  },
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                  ),
                  maxLength: 500,
                  buildCounter: (BuildContext context,
                      {required int currentLength,
                      required bool isFocused,
                      required int? maxLength}) {
                    return Text('$currentLength/$maxLength');
                  },
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      var prefs =
                          await ref.read(sharedPreferencesProvider.future);
                      var operatore = prefs.getString('user')?.toUpperCase();

                      double quantityDouble = double.parse(quantity.toString());
                      Map<String, dynamic> params = {
                        'operatore': operatore,
                        'dataInserimento':
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        'quantita': quantityDouble,
                        'note': notes,
                      };

                      addRiga(articolo, ref, params);


if (sendEmailState) {
                  await _sendEmail(context, ref, articolo);
                }

                      final result = ref
                          .read(movimentoMagazzinoApiRepositoryProvider)
                          .updateQuantity(
                            codArt: articolo.codice,
                            desMov: articolo.descrizione,
                            note: notes,
                            tipoMov: 40,
                            mag: articolo.magazzino?.codice ?? '',
                            umMov: articolo.unimis?.codice ?? '',
                            qtaMov: quantity.toDouble(),
                          );

                      if (result != null) {
                        Navigator.pop(context);

                        return;
                        
                      } else {}
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey),
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 40)),
                    ),
                    child: const Text(
                      'Conferma',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

Future<void> _sendEmail(BuildContext context, WidgetRef ref, Articolo articolo) async {
  final smtpServer = SmtpServer(
    'mail.smtp2go.com',
    username: 'edonis,morina@icoldo.it',
    password: 'Edonis.19',
    port: 2525,
    ssl: false,
    allowInsecure: false,
  );

  final message = Message()
    ..from = Address('assistenza@icoldo.it', 'Assistenza')
    ..recipients.add('assistenza@icoldo.it')
    ..subject = 'Segnalazione Articolo ${articolo.codice} - ${articolo.descrizione}'
    ..text = 'Questà è una mail inviata dal sistema per una segnalazione all\'articolo: ${articolo.codice} - ${articolo.descrizione} ';

  try {
    final sendReport = await send(message, smtpServer);

    print('Message sent: ${sendReport.messageSendingEnd}');
    print('Preview URL: ${sendReport.mail}'); // Email inviata correttamente
  } catch (e) {
    print('Error occurred: $e');
  }
}




  // void modifyDettagliDialog(
  //     BuildContext context,
  //     Articolo articolo,
  //     WidgetRef ref,
  //     double quantity,
  //     String notes) async {
  //   TextEditingController quantityController =
  //       TextEditingController(text: quantity.toString());
  //   TextEditingController notesController = TextEditingController(text: notes);

  //   final double initialQuantity = quantity;

  //   TextEditingController quantityControllerNew =
  //       TextEditingController(text: initialQuantity.toString());

  //   final disponibilitaRepository =
  //       ref.read(disponibilitaArticoliApiRepositoryProvider);
  //   final dataLim = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   String? codArt = articolo.codice;
  //   if (codArt == null) {
  //     return;
  //   }

  //   double disp = 0;
  //   double giac = 0;
  //   double scorta = 0;
  //   String? unimis;

  //   final qtaResiduaResponse =
  //       await disponibilitaRepository.getDisponibilitaArticoli(dataLim, codArt);

  //   if (qtaResiduaResponse != null) {
  //     final magazzinoSede = qtaResiduaResponse.firstWhere(
  //         (element) => element['magazzino'] == 'SEDE',
  //         orElse: () => null);
  //     if (magazzinoSede != null) {
  //       disp = magazzinoSede['disp'];
  //       giac = magazzinoSede['giac'];
  //       scorta = magazzinoSede['scoSic'];
  //       unimis = magazzinoSede['unimis'];
  //     }
  //   }

  //   double difference = disp - quantity;
  //   TextEditingController differenceController =
  //       TextEditingController(text: difference.toString());

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Column(
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 const SizedBox(width: 2),
  //                 Text('$codArt ${unimis != null ? '($unimis)' : ''}'),
  //               ],
  //             ),
  //             const Divider(),
  //             Text(
  //               articolo.descrizione,
  //               textAlign: TextAlign.center,
  //               style:
  //                   const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
  //             ),
  //           ],
  //         ),
  //         content: SizedBox(
  //           width: 300,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.remove),
  //                     iconSize: 20,
  //                     onPressed: () {
  //                       if (quantity > 1) {
  //                         quantity--;
  //                         quantityController.text = quantity.toString();
  //                       }
  //                     },
  //                   ),
  //                   const SizedBox(width: 10),
  //                   Expanded(
  //                     child: TextField(
  //                       controller: quantityController,
  //                       keyboardType: TextInputType.number,
  //                       textAlign: TextAlign.center,
  //                       onChanged: (value) {
  //                         quantity = double.tryParse(value) ?? 1;
  //                         difference = disp - quantity;
  //                         differenceController.text = difference.toString();
  //                       },
  //                       decoration: const InputDecoration(
  //                         labelText: 'Quantità',
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 10),
  //                   IconButton(
  //                     icon: const Icon(Icons.add),
  //                     iconSize: 20,
  //                     onPressed: () {
  //                       quantity++;
  //                       quantityController.text = quantity.toString();
  //                       difference = disp - quantity;
  //                       differenceController.text =
  //                           difference.toInt().toString();
  //                     },
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 20),
  //               DataTable(
  //                 columns: const [
  //                   DataColumn(label: Text('Disp.')),
  //                   DataColumn(label: Text('Scorta')),
  //                   DataColumn(label: Text('Giac.')),
  //                 ],
  //                 rows: [
  //                   DataRow(cells: [
  //                     DataCell(Text(disp.toInt().toString())),
  //                     DataCell(Text(scorta.toInt().toString())),
  //                     DataCell(Text(giac.toInt().toString())),
  //                   ]),
  //                 ],
  //               ),
  //               const SizedBox(height: 20),
  //               TextField(
  //                   controller: notesController,
  //                   onChanged: (value) {
  //                     notes = value;
  //                   },
  //                   maxLines: 3,
  //                   decoration: const InputDecoration(
  //                     labelText: 'Note',
  //                   ),
  //                   maxLength: 500,
  //                   buildCounter: (BuildContext context,
  //                       {required int currentLength,
  //                       required bool isFocused,
  //                       required int? maxLength}) {
  //                     return Text('$currentLength/$maxLength');
  //                   }),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               double parseDuration(String durationString) {
  //                 if (durationString.contains(':')) {
  //                   final parts = durationString.split(':');
  //                   final hours = double.parse(parts[0]);
  //                   final minutes = double.parse(parts[1]);
  //                   return hours + (minutes / 60);
  //                 } else {
  //                   return double.parse(durationString);
  //                 }
  //               }

  //               //double quantityDouble = double.parse(quantity.toString());
  //               articolo.quantita = quantity;
  //               articolo.note = notes;
  //               ref
  //                   .read(interventoStateControllerProvider.notifier)
  //                   .addOrUpdate(articolo);

  //               final int quantityValue =
  //                   int.tryParse(quantityControllerNew.text) ?? 0;
  //               final int tipoMov =
  //                   articolo.quantita! > quantityValue ? 40 : 41;

  //               int quantityDifferenceReso = 0;
  //               if (tipoMov == 41) {
  //                 quantityDifferenceReso = quantityValue - quantity.toInt();
  //               }

  //               int quantityDifferencePrelievo = 0;
  //               if (tipoMov == 40) {
  //                 quantityDifferencePrelievo = quantity.toInt() - quantityValue;
  //               }

  //               final double qtaMov = tipoMov == 40
  //                   ? quantityDifferencePrelievo.toDouble()
  //                   : quantityDifferenceReso.toDouble();

  //               final result = ref
  //                   .read(movimentoMagazzinoApiRepositoryProvider)
  //                   .updateQuantity(
  //                       codArt: articolo.codice,
  //                       desMov: articolo.descrizione,
  //                       note: notes,
  //                       tipoMov: tipoMov,
  //                       mag: articolo.magazzino?.descrizione ?? '',
  //                       umMov: articolo.unimis?.codice ?? '',
  //                       qtaMov: qtaMov);

  //               if (result != null) {
  //                 Navigator.pop(context);

  //                 return;
  //               } else {}

  //               Navigator.pop(context);
  //             },
  //             child: const Text('Conferma'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  TimeOfDay? lastStartTime;
  TimeOfDay? lastEndTime;

  void modifyDurataDialog(
      BuildContext context, Riga riga, WidgetRef ref) async {
    double quantity = riga.qta ?? 1;
    String notes = riga.note ?? '';

    TimeOfDay? savedStartTime = lastStartTime;
    TimeOfDay? savedEndTime = lastEndTime;

    TextEditingController notesController = TextEditingController(text: notes);
    TextEditingController startTimeController = TextEditingController(
        text: savedStartTime != null
            ? DateFormat.Hm().format(DateTime(
                2022, 1, 1, savedStartTime.hour, savedStartTime.minute))
            : '');
    TextEditingController endTimeController = TextEditingController(
        text: savedEndTime != null
            ? DateFormat.Hm().format(
                DateTime(2022, 1, 1, savedEndTime.hour, savedEndTime.minute))
            : '');
    TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 2),
                  Text('Modifica Durata'),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: savedStartTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          lastStartTime = picked;
                          setState(() {
                            savedStartTime = picked;
                            startTimeController.text = DateFormat.Hm().format(
                                DateTime(
                                    2022, 1, 1, picked.hour, picked.minute));
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Orario di Inizio',
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: startTimeController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  hintText: 'Seleziona orario',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                TimeOfDay now = TimeOfDay.now();
                                lastStartTime = now;
                                setState(() {
                                  savedStartTime = now;
                                  startTimeController.text = DateFormat.Hm()
                                      .format(DateTime(
                                          2022, 1, 1, now.hour, now.minute));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: savedEndTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          lastEndTime =
                              picked; // Memorizza l'ultimo valore inserito
                          setState(() {
                            savedEndTime = picked;
                            endTimeController.text = DateFormat.Hm().format(
                                DateTime(
                                    2022, 1, 1, picked.hour, picked.minute));
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Orario di Fine',
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: endTimeController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  hintText: 'Seleziona orario',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                TimeOfDay now = TimeOfDay.now();
                                lastEndTime =
                                    now; // Memorizza l'ultimo valore inserito
                                setState(() {
                                  savedEndTime = now;
                                  endTimeController.text = DateFormat.Hm()
                                      .format(DateTime(
                                          2022, 1, 1, now.hour, now.minute));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (lastStartTime != null && lastEndTime != null) {
                      String duration =
                          calculateDuration(lastStartTime!, lastEndTime!);
                      double parseDuration(String durationString) {
                        if (durationString.contains(':')) {
                          final parts = durationString.split(':');
                          final hours = double.parse(parts[0]);
                          final minutes = double.parse(parts[1]);
                          return hours + (minutes / 60);
                        } else {
                          return double.parse(durationString);
                        }
                      }

                      // double quantityDouble = double.parse(quantity.toString());
                      double durationDouble = parseDuration(duration);
                      //articolo.durata = duration;
                      riga.qta = durationDouble;
                      riga.note = notes;

                      updateRiga(riga, ref);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Conferma'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAggiungiNotaDialog(BuildContext context, WidgetRef ref) async {
    String notaText = '';
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_add),
              SizedBox(width: 2),
              Text('Nota'),
            ],
          ),
          content: Container(
            width: 300,
            child: TextField(
              controller: controller,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Inserisci una nota',
                contentPadding: EdgeInsets.all(16.0),
              ),
              buildCounter: (BuildContext context,
                  {required int currentLength,
                  required bool isFocused,
                  required int? maxLength}) {
                return Text('$currentLength/$maxLength');
              },
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey), // Bordo grigio
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(
                          double.infinity,
                          40)), // Larghezza espansa e altezza 50
                    ),
                    child: const Text('Annulla',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 8), // Spazio tra i pulsanti
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // if (controller.text.isNotEmpty) {
                      //   notaText = controller.text;
                      //   _stampaNellaPage('$notaText', ref);
                      //   Navigator.pop(context);
                      // }

                      notaText = controller.text;

                      // this doesn't seem to be the place to do this
                      // var prefs =
                      //     await ref.read(sharedPreferencesProvider.future);
                      // var operatore = prefs.getString('user');

                      // Map<String, dynamic> params = {
                      //   'operatore': operatore,
                      //   'dataInserimento':
                      //       DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      //   'quantita': 0,
                      //   //     //'durata': duration,
                      //   'note': notaText,
                      // };

                      addNote(notaText, ref);
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(color: Colors.grey), // Bordo grigio
                      ),
                      minimumSize: MaterialStateProperty.all<Size>(const Size(
                          double.infinity,
                          40)), // Larghezza espansa e altezza 50
                    ),
                    child: const Text('Salva',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // final noteListProvider = StateNotifierProvider<NoteList, List<Note>>((ref) {
  //   return NoteList();
  // });

  // void _stampaNellaPage(String nota, WidgetRef ref) {
  //   ref.read(noteListProvider.notifier).add(nota);
  // }
}

// class Note {
//   String nota;
//   bool isEditing;

//   Note(this.nota, {this.isEditing = false});


//   Note copyWith({String? nota, bool? isEditing}) {
//     return Note(
//       nota ?? this.nota,
//       isEditing: isEditing ?? this.isEditing,
//     );
//   }
// }

// class NoteList extends StateNotifier<List<Note>> {
//   NoteList() : super([]);

//   void add(String nota) {
//     state = [...state, Note(nota)];
//   }

//   void remove(int index) {
//     state = List.from(state)..removeAt(index);
//   }

//   // Metodo per impostare lo stato di modifica per una nota specifica
//   void setEditing(int index, bool value) {
//     if (index >= 0 && index < state.length) {
//       state = [
//         ...state.sublist(0, index),
//         state[index].copyWith(isEditing: value),
//         ...state.sublist(index + 1),
//       ];
//     }
//   }
// }



// void _openCameraInterface(BuildContext context) {
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (context) => CameraPreviewPage(),
//      ),
//    );
//  }

//  class CameraPreviewPage extends StatefulWidget {
//    @override
//    _CameraPreviewPageState createState() => _CameraPreviewPageState();
//  }

//  class _CameraPreviewPageState extends State<CameraPreviewPage> {
//    late CameraController _controller;

//    @override
//    void initState() {
//      super.initState();
//      _initializeCamera();
//    }

//    Future<void> _initializeCamera() async {
//      final cameras = await availableCameras();
//      _controller = CameraController(
//        cameras[0],
//        ResolutionPreset.medium,
//      );
//      await _controller.initialize();
//      if (mounted) {
//        setState(() {});
//      }
//    }

//    @override
//    Widget build(BuildContext context) {
//      if (!_controller.value.isInitialized) {
//        return Center(
//          child: CircularProgressIndicator(),
//        );
//      }

//      return Scaffold(
//        appBar: AppBar(title: Text('Camera Preview')),
//        body: CameraPreview(_controller),
//      );
//    }

//    @override
//    void dispose() {
//      _controller.dispose();
//      super.dispose();
//    }
//  }




