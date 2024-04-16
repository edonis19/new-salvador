import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/models/articolo_model.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';

part 'intervento_aperto_state.g.dart';

@Riverpod(keepAlive: true)
class InterventoApertoState extends _$InterventoApertoState {
  @override
  Intervento build() {
    var defaultIntervento = Intervento.empty();
    return defaultIntervento;
  }

  void setIntervento(Intervento intervento) {
    state = intervento;
  }

  void addRiga(Articolo item, Map<String, dynamic> params) {
    //double? qtaDouble = double.tryParse(params['quantita']);
    var intervento = state;
    int countRighe = state.righe.length;
    var nuovaRiga = Riga(
      id: null,
      idTestata: 0,
      idRiga: null,
      numOrdine: null,
      riga: countRighe++,
      descrizione: params['note'],
      barcode: null,
      statusEvasione: null,
      articolo: InterventoArticolo(
        id: item.id,
        idListino: null,
        codice: item.codice,
        descrizione: item.descrizione,
        barcode: null,
        servizio: null,
        umPrincipale: item.unimis.codice,
        umProduzione: null,
        tipoArt: null,
        sottotipoArt: null,
        settore: null,
        gruppo: null,
        sottogruppo: null,
        marca: null,
        sagoma: null,
        modello: null,
        serie: null,
        caratteristica: null,
        codArtFornitore: null,
        gestitoDimensioni: false,
        dimensione1: null,
        dimensione2: null,
        dimensione3: null,
        dimensione4: null,
        dimensione5: null,
        attivaDim1: false,
        attivaDim2: false,
        attivaDim3: false,
        attivaDim4: false,
        attivaDim5: false,
        colore: null,
        categoriaIva: null,
        categoriaEconomica: null,
        tipoParte: null,
        aziendaPiva: null,
        prezzoBase: 0.0,
        costoBase: 0.0,
        gestitoMag: false,
        magazzino: null,
        magazzinoAcq: null,
        magazzinoVen: null,
        magazzinoProd: null,
        giacenza: null,
        disponibilita: null,
        disponibilitaTot: null,
        gestitoUbicazione: false,
        ubicazione: null,
        gestitoLotto: false,
        lotto: null,
        gestitoMatricola: false,
        matricola: null,
        cliente: null,
        fornitoreAbituale: null,
        updCostoBase: false,
        updCostoBaseForzatura: false,
      ),
      tipoRiga: null,
      destDes: null,
      destInd: null,
      pagamento: null,
      scontoPag: 0.0,
      sc1Tes: 0.0,
      sc2Tes: 0.0,
      sc3Tes: 0.0,
      cigCup: null,
      codIvaTes: null,
      colli: 0.0,
      qta: params['quantita'],
      qtaEvasa: 0.0,
      qtaResidua: 0.0,
      qtaGiacenza: 0.0,
      qtaInserita: 0.0,
      iva: 0.0,
      sconto1: 0.0,
      sconto2: 0.0,
      sconto3: 0.0,
      sconto4: 0.0,
      sconto5: 0.0,
      sconto6: 0.0,
      magg1: 0.0,
      magg2: 0.0,
      magg3: 0.0,
      magg4: 0.0,
      magg5: 0.0,
      magg6: 0.0,
      prezzo: 0.0,
      moltPrz: 0.0,
      prezzoUni: 0.0,
      nettoRiga: 0.0,
      dtOraIni: params['durataIni'],
      dtOraFin: params['durataFin'],
      operatore: params['operatore'],
      saldaRiga: false,
      dataRichConsegna: null,
      dataConfConsegna: null,
      note: null,
      noteDaStampare: null,
      origine: null,
      matricola: null,
      gestioneLotti: false,
      recordCancellato: false,
      recordSelezionato: false,
      recordInviato: false,
      info: null,
      warning: null,
      error: null,
      matricole: null,
      lotti: null,
    );

    // Aggiungi la nuova riga alla lista delle righe dell'intervento
    intervento.righe.add(nuovaRiga);

    // Imposta il flag dirty per indicare che lo stato è stato modificato
    intervento.isDirty = true;

    state = intervento;

                            var interventiDbProvider =
                        ref.read(interventiDbRepositoryProvider.notifier);

  interventiDbProvider.saveChanges(state);
  }

  void updateRiga(Riga riga) {
    var intervento = state;
    var index =
        intervento.righe.indexWhere((element) => element.idRiga == riga.idRiga);
    intervento.righe[index] = riga;
    intervento.isDirty = true;

    state = intervento;

                                var interventiDbProvider =
                        ref.read(interventiDbRepositoryProvider.notifier);

  interventiDbProvider.saveChanges(state);
  }

  void addNote(String note) {
    var intervento = state;
    intervento.note = note;
    intervento.isDirty = true;

    state = intervento;

  var interventiDbProvider =
  ref.read(interventiDbRepositoryProvider.notifier);

  interventiDbProvider.saveChanges(state);
  }

void removeRiga(WidgetRef ref, int numRiga) {
  int numIndex = numRiga;
  if (numIndex >= 0 && numIndex < state.righe.length) {
    state.righe.removeAt(numIndex);
    var interventiDbProvider = ref.read(interventiDbRepositoryProvider.notifier);
    interventiDbProvider.addOrUpdate(state);
  } else {
    print('Indice di riga non valido: $numRiga');
  }
}
}