import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/signin/signin_view.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/movimento_magazzino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class RegistrazioneInterventoDataSource extends DataGridSource {
  final List<Intervento> data;
  final WidgetRef _ref;
  final BuildContext context;
  final int idTestata;

  RegistrazioneInterventoDataSource(
    this.data,
    this._ref,
    this.context,
    this.idTestata,
  );

  @override
  List<DataGridRow> get rows {
    final filteredData =
        data.where((intervento) => intervento.idTestata == idTestata);

    return filteredData.expand((intervento) {
      return intervento.righe.map((riga) {
        String? codiceArticolo = riga.articolo?.codice;
        String? descrizioneArticolo = riga.articolo?.descrizione;
        String righeOperatore = _getOperatorName(context, _ref);
        dynamic righeqtaInserita = riga.qtaInserita;
        dynamic idRiga = riga.idRiga;

        return DataGridRow(cells: [
          DataGridCell<Object>(
            columnName: 'idRiga',
            value: idRiga,
          ),
          const DataGridCell<Widget>(columnName: 'button', value: null),
          DataGridCell<String>(columnName: 'numDoc', value: intervento.numDoc),
          DataGridCell<String>(
            columnName: 'articolo.codice',
            value: codiceArticolo,
          ),
          DataGridCell<String>(
            columnName: 'articolo.descrizione',
            value: descrizioneArticolo,
          ),
          DataGridCell<String>(
            columnName: 'righe.operatore',
            value: righeOperatore,
          ),
          DataGridCell<String>(
            columnName: 'dataInserimento',
            value: DateTime.now().toString().substring(0, 16),
          ),
          DataGridCell<Object>(
            columnName: 'righe.qtaInserita',
            value: righeqtaInserita,
          ),
        ]);
      }).toList();
    }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    String idRiga = row.getCells()[0].value.toString();

    ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 255, 0, 0),
    );

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'button') {
          return Container(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return IconButton(
                  style: elevatedButtonStyle,
                  onPressed: () {
                    //_showConfirmationDialog(context, idRiga);
                  },
                  icon: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 22,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return Container(
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${dataGridCell.value}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: null,
                          softWrap: true,
                          // style: TextStyle(
                          //   fontSize: fontSize,
                          // ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      }).toList(),
    );
  }

  String _getOperatorName(BuildContext context, WidgetRef ref) {
    final userName =
        ref.read(sharedPreferencesProvider).asData!.value.getString("user");
    return operatorNames[userName] ?? '';
  }

    // void _showDetailsPage(Intervento intervento, String idRiga, BuildContext context) {
    //   String righeDescrizione = intervento.righe.isNotEmpty ? intervento.righe[0].descrizione : '';
    //   String? righeStatusEvasione = intervento.righe.isNotEmpty ? intervento.righe[0].statusEvasione : '';
    //   String? operatore = intervento.righe.isNotEmpty ? intervento.righe[0].operatore : '';
    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => DetailsPage(
    //         idTestata: intervento.idTestata,
    //         clienteCodice: intervento.cliente.codice,
    //         numDoc: intervento.numDoc,
    //         descrizioneCliente: intervento.cliente.descrizione,
    //         dataDoc: intervento.dataDoc,
    //         indirizzoSpedizione: intervento.cliente.indirizzo,
    //         telefono1: intervento.cliente.telefono1,
    //         telefono2: intervento.cliente.telefono2,
    //         email: intervento.cliente.email,
    //         note: intervento.note,
    //         statusEvasione: righeStatusEvasione,
    //         matricola: intervento.matricola,
    //         rifMatricolaCliente: intervento.rifMatricolaCliente,
    //         telaio: intervento.telaio,
    //         contMatricola: intervento.contMatricola,
    //         descrizioneIntervento: righeDescrizione,
    //         autoreModifica: operatore, ultimaModifica: DateTime.now(),
    //       ),
    //     ),
    //   );
    // }
}
