// ignore_for_file: unnecessary_string_interpolations, duplicate_ignore

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/generale_details.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/intervento_aperto_state.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InterventiApertiDataSource extends DataGridSource {
  final List<Intervento> data;
  final List<Intervento> nuovoIntervento;
  final WidgetRef ref;
  final BuildContext context;

  InterventiApertiDataSource(
    this.data,
    this.nuovoIntervento,
    this.ref,
    this.context,
  );

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];

    rows.addAll(data.map((intervento) {
      InterventoCliente? cliente = intervento.cliente;
      List<Riga> righe = intervento.righe;

      //String? righeDescrizione = righe.isNotEmpty ? righe[0].descrizione : '';
      String? note = intervento.note ?? '';
      String? dataDocFormatted;
      dataDocFormatted = DateFormat('dd/MM/yyyy').format(intervento.dataDoc);
      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'idTestata',
          value: '${intervento.idTestata}',
        ),
        const DataGridCell<Widget>(columnName: 'button', value: null),
        DataGridCell<String>(
            columnName: 'numDoc', value: '${intervento.numDoc}'),
        DataGridCell<String>(columnName: 'dataDoc', value: dataDocFormatted),
        DataGridCell<String>(
          columnName: 'righe.descrizione',
          value: note,
        ),
        DataGridCell<String>(
          columnName: 'cliente.descrizione',
          value: '${cliente?.descrizione}',
        ),
        DataGridCell<String>(
          columnName: 'cliente.indirizzo',
          value: '${cliente?.indirizzo}',
        ),
        DataGridCell<String>(
          columnName: 'cliente.telefono1',
          value: '${cliente?.telefono1}',
        ),
        DataGridCell<String>(
          columnName: 'status',
          value: '${intervento.status}',
        ),
      ]);
    }).toList());

    rows.addAll(nuovoIntervento.map((nuovoIntervento) {
      var cliente = nuovoIntervento.cliente;
      //var righe = nuovoIntervento.righe;

      String? dataDocFormatted;
      dataDocFormatted =
          DateFormat('dd/MM/yyyy').format(nuovoIntervento.dataDoc);

      return DataGridRow(cells: [
        DataGridCell<String>(
          columnName: 'idTestata',
          value: '${nuovoIntervento.idTestata}',
        ),
        const DataGridCell<Widget>(columnName: 'button', value: null),
        DataGridCell<String>(
            columnName: 'numDoc', value: '${nuovoIntervento.numDoc}'),
        DataGridCell<String>(columnName: 'dataDoc', value: dataDocFormatted),
        DataGridCell<String>(
          columnName: 'righe.descrizione',
          value: '${nuovoIntervento.note}',
        ),
        DataGridCell<String>(
          columnName: 'cliente.descrizione',
          value: '${cliente?.descrizione}',
        ),
        DataGridCell<String>(
          columnName: 'cliente.indirizzo',
          value: '${cliente?.indirizzo}',
        ),
        DataGridCell<String>(
          columnName: 'cliente.telefono1',
          value: '${cliente?.telefono1}',
        ),
        DataGridCell<String>(
          columnName: 'status',
          value: '${nuovoIntervento.status}',
        ),
      ]);
    }).toList());

    return rows;
  }

@override
DataGridRowAdapter buildRow(DataGridRow row) {
  String idTestata = row.getCells()[0].value.toString();

  Intervento? intervento = data.firstWhereOrNull(
    (element) {
      return element.idTestata.toString().trim() ==
          idTestata.toString().trim();
    },
  );

  var nuovoInterventoButton = nuovoIntervento.firstWhereOrNull(
    (element) {
      return element.idTestata.toString().trim() ==
          idTestata.toString().trim();
    },
  );

  return DataGridRowAdapter(
    cells: row.getCells().map<Widget>((dataGridCell) {
      if (dataGridCell.columnName == 'button') {
        return IconButton(
          onPressed: () {
            if (intervento != null) {
              ref.read(interventoApertoStateProvider.notifier).setIntervento(intervento);
              _showDetailsPage(context);
              _updateStatus(intervento);
            } else if (nuovoInterventoButton != null) {
              ref.read(interventoApertoStateProvider.notifier).setIntervento(nuovoInterventoButton);
              _showDetailsPageNuovoIntervento(context);
              //_updateStatusNuovoIntervento(nuovoInterventoButton);
            }
          },
          icon: const Icon(Icons.open_in_new),
          color: Colors.orange,
          iconSize: 24,
        );
      } else {
        Color? backgroundColor;
        if (dataGridCell.columnName == 'status') {
          switch (dataGridCell.value) {
            case 'NO SYNCH':
              backgroundColor = Colors.yellow;
              break;
            case 'SOS':
              backgroundColor = Colors.grey;
              break;
            case 'MOD':
              backgroundColor = Colors.red;
              break;
            case 'COMPL':
              backgroundColor = Colors.green;
              break;
            default:
              backgroundColor = null;
              break;
          }
        }
        return GestureDetector(
          onTap: () {
            // if (dataGridCell.columnName == 'status') {
            //   _updateStatus(intervento!);
            // }
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            color: backgroundColor,
            child: Text(
              '${dataGridCell.value}',
              overflow: TextOverflow.ellipsis,
              maxLines: null,
              softWrap: true,
            ),
          ),
        );
      }
    }).toList(),
  );
}


  void _showDetailsPage(BuildContext context) {
    // String? righeDescrizione =
    //     intervento.righe.isNotEmpty ? intervento.righe[0].descrizione : '';
    // String righeDaFareDescrizione = intervento.righe.isNotEmpty
    //     ? intervento.righe.map((riga) => riga.descrizione).join(', ')
    //     : '';
    //String? righeStatusEvasione = intervento.righe.isNotEmpty ? intervento.righe[0].statusEvasione : '';
    // String? operatore =
    //     intervento.righe.isNotEmpty ? intervento.righe[0].operatore : '';
    //ref.read(interventoApertoStateProvider.notifier).set(intervento);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DetailsPage(),
      ),
    );
  }

  void _showDetailsPageNuovoIntervento(BuildContext context) {
    //String righeDescrizione = 'null';
    //String righeDaFareDescrizione = 'null';
    //String? righeStatusEvasione = intervento.righe.isNotEmpty ? intervento.righe[0].statusEvasione : '';
    //String? operatore = 'admin';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DetailsPage(),
      ),
    );
  }

  void _updateStatus(Intervento intervento) {
    intervento.status = 'MOD';

    // Aggiorna la tabella
    notifyListeners();
  }
}
