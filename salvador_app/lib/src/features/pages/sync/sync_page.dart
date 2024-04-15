import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/add_righe_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';

class SyncPage extends ConsumerWidget {
  const SyncPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInterventi = ref.watch(interventiDbRepositoryProvider);

    return asyncInterventi.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (interventiState) {
        final interventi = interventiState.where((intervento) => intervento.status == 'NO SYNCH').toList();

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Interventi da sincronizzare',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: interventi.length,
                  itemBuilder: (context, index) {
                    final intervento = interventi[index];
                    final formattedDate = DateFormat('yyyy-MM-dd').format(intervento.dataDoc);
                    return Column(
                      children: [
                        ListTile(
                          leading: Text(intervento.idTestata.toString()),
                          title: Text(intervento.cliente!.descrizione!),
                          subtitle: Text(formattedDate),
                          trailing: IconButton(
                            icon: Icon(Icons.sync), // Aggiungi un'icona al pulsante
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
                            dtOraIni: null,
                            dtOraFin: null,
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
                          ),
                        ),
                        Divider(), // Divider tra ogni ListTile
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
