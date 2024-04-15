// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_dropdown_search/reactive_dropdown_search.dart';
import 'package:salvador_task_management/src/features/main_view/main_view.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/generale_details.dart';
import 'package:salvador_task_management/src/features/pages/interventi_aperti/intervento_aperto_state.dart';
import 'package:salvador_task_management/src/features/pages/nuovo_intervento/clienti_controller.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';
import 'package:salvador_task_management/src/repository/elencomatricole_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';

class NuovoInterventoPage extends ConsumerWidget {
  NuovoInterventoPage({super.key});
  final _targaController = TextEditingController();
  final _telaioController = TextEditingController();
  final _notaController = TextEditingController();
  final _matricolaController = TextEditingController();
  final _contMatricolaController = TextEditingController();
  String? _selectedClient = '';
  String? _selectedClientValue;
  String? _selectedTipoDocCodiceValue;
  String? _selectedTipoDocDescrizioneValue;
  int? _selectedTipoDocIdValue;
  //String? _numeroDoc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var clientiData = ref.watch(clientiControllerProvider);
    //var clientiData = ref.watch(clientiCollectionRepositoryProvider);

    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      textStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      side: const BorderSide(
        color: Colors.black,
        width: 2,
      ),
    );

//final nuovoInterventoRepository = ref.read(nuovoInterventoDbRepositoryProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10),
                alignment: Alignment.topRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final clientiData =
                        await ref.read(clientiControllerProvider.future);
                    final clientiFiltrati = clientiData
                        .where((cliente) =>
                            cliente.descrizione.isNotEmpty &&
                            cliente.descrizione == _selectedClientValue)
                        .toList();

                    // List<dynamic> clientiFiltrati = [];

                    // clientiData.when(
                    //   data: (data) {
                    //     if (data is List<dynamic>) {
                    //       clientiFiltrati = data
                    //           .where((cliente) =>
                    //               cliente.descrizione != null &&
                    //               cliente.descrizione!.isNotEmpty &&
                    //               cliente.descrizione == _selectedClientValue)
                    //           .toList();
                    //     }
                    //   },
                    //   loading: () {
                    //     // Gestisci il caricamento
                    //   },
                    //   error: (error, stackTrace) {
                    //     // Gestisci l'errore
                    //   },
                    // );

                    List<dynamic> codiciClienti = clientiFiltrati
                        .map((cliente) => cliente.codice)
                        .toList();
                    List<dynamic> idClientiFiltrati = clientiFiltrati
                        .map((cliente) =>
                            int.tryParse(cliente.id.toString()) ?? 0)
                        .toList();
                    List<dynamic> partitaIvaClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.partitaIva ?? '')
                        .toList();
                    List<dynamic> codFiscaleClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.codFiscale ?? '')
                        .toList();
                    List<dynamic> indirizzoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.indirizzo ?? '')
                        .toList();
                    List<dynamic> capClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.cap ?? '')
                        .toList();
                    List<dynamic> localitaClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.localita ?? '')
                        .toList();
                    List<dynamic> provinciaClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.provincia ?? '')
                        .toList();
                    List<dynamic> nazioneClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.nazione ?? '')
                        .toList();
                    List<dynamic> faxClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.fax ?? '')
                        .toList();
                    List<dynamic> emailClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.email ?? '')
                        .toList();
                    List<dynamic> telefono1ClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.telefono1 ?? '')
                        .toList();
                    List<dynamic> telefono2ClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.telefono2 ?? '')
                        .toList();
                    List<dynamic> codListinoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.codListino ?? '')
                        .toList();
                    List<dynamic> categoriaIvaClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.categoriaIva ?? '')
                        .toList();
                    List<dynamic> aspettoBeniClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.aspettoBeni ?? '')
                        .toList();
                    List<dynamic> gruppoVenditaClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.gruppoVendita ?? '')
                        .toList();
                    List<dynamic> notePalmareClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.notePalmare ?? '')
                        .toList();
                    List<dynamic> portoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.porto ?? '')
                        .toList();
                    List<dynamic> modTrasportoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.modTrasporto ?? '')
                        .toList();
                    List<dynamic> modConsegnaClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.modConsegna ?? '')
                        .toList();
                    List<dynamic> causTrasportoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.causTrasporto ?? '')
                        .toList();
                    List<dynamic> vettoreClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.vettore ?? '')
                        .toList();
                    List<dynamic> pagamentoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.pagamento ?? '')
                        .toList();
                    List<dynamic> abiClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.abi ?? '')
                        .toList();
                    List<dynamic> cabClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.cab ?? '')
                        .toList();
                    List<dynamic> contocorrenteClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.contocorrente ?? '')
                        .toList();
                    List<dynamic> ibanClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.iban ?? '')
                        .toList();
                    List<dynamic> statusBloccoClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.statusBlocco ?? '')
                        .toList();
                    List<dynamic> datiContabiliClientiFiltrati = clientiFiltrati
                        .map((cliente) => cliente.datiContabili ?? '')
                        .toList();
                    String codiciClientiString = codiciClienti.join(',');
                    String partitaIvaClientiString =
                        partitaIvaClientiFiltrati.join(',');
                    String codFiscaleClientiString =
                        codFiscaleClientiFiltrati.join(',');
                    String indirizzoClientiString =
                        indirizzoClientiFiltrati.join(',');
                    String capClientiString = capClientiFiltrati.join(',');
                    String localitaClientiString =
                        localitaClientiFiltrati.join(',');
                    String provinciaClientiString =
                        provinciaClientiFiltrati.join(',');
                    String nazioneClientiString =
                        nazioneClientiFiltrati.join(',');
                    String faxClientiString = faxClientiFiltrati.join(',');
                    String emailClientiString = emailClientiFiltrati.join(',');
                    String telefono1ClientiString =
                        telefono1ClientiFiltrati.join(',');
                    String telefono2ClientiString =
                        telefono2ClientiFiltrati.join(',');
                    String codListinoClientiString =
                        codListinoClientiFiltrati.join(',');
                    String categoriaIvaClientiString =
                        categoriaIvaClientiFiltrati.join(',');
                    String aspettoBeniClientiString =
                        aspettoBeniClientiFiltrati.join(',');
                    String gruppoVenditaClientiString =
                        gruppoVenditaClientiFiltrati.join(',');
                    String notePalmareClientiString =
                        notePalmareClientiFiltrati.join(',');
                    String portoClientiString = portoClientiFiltrati.join(',');
                    String modTrasportoClientiString =
                        modTrasportoClientiFiltrati.join(',');
                    String modConsegnaClientiString =
                        modConsegnaClientiFiltrati.join(',');
                    String causTrasportoClientiString =
                        causTrasportoClientiFiltrati.join(',');
                    String vettoreClientiString =
                        vettoreClientiFiltrati.join(',');
                    String pagamentoClientiString =
                        pagamentoClientiFiltrati.join(',');
                    String abiClientiString = abiClientiFiltrati.join(',');
                    String cabClientiString = cabClientiFiltrati.join(',');
                    String contocorrenteClientiString =
                        contocorrenteClientiFiltrati.join(',');
                    String ibanClientiString = ibanClientiFiltrati.join(',');
                    String statusBloccoClientiString =
                        statusBloccoClientiFiltrati.join(',');
                    String datiContabiliClientiString =
                        datiContabiliClientiFiltrati.join(',');

                    int idClientiFiltratiInt =
                        int.tryParse(idClientiFiltrati.join('')) ?? 0;

                        double? contMatricola = double.tryParse(_contMatricolaController.text);

                    var interventiDbProvider =
                        ref.read(interventiDbRepositoryProvider.notifier);
                    // _numeroDoc =
                    //     await interventiDbProvider.getUltimoNumeroDocumento();

                    // String numeroDocumento = _numeroDoc ?? '';

                    // List<String> partiNumero = numeroDocumento.split('/');
                    // int numeroDaIncrementare =
                    //     int.parse(partiNumero[1].substring(2, 5));

                    // int numeroIncrementato = numeroDaIncrementare + 1;

                    // String numeroIncrementatoString =
                    //     numeroIncrementato.toString().padLeft(5, '0');

                    // String nuovoNumeroDocumento =
                    //     "${partiNumero[0]}/$numeroIncrementatoString${partiNumero[1].substring(5, 9)}";

                    // print("Nuovo numero del documento: $nuovoNumeroDocumento");

                    //int? _numeroRiga = 1;

                    final nuovoIntervento = Intervento(
                        id: null,
                        idTestata: DateTime.now().microsecondsSinceEpoch * -1,
                        barcode: null,
                        numDoc: 'null',
                        dataDoc: DateTime.now(),
                        totaleDoc: null,
                        tipoDoc: TipoDoc(
                            id: _selectedTipoDocIdValue,
                            codice: _selectedTipoDocCodiceValue,
                            descrizione: _selectedTipoDocDescrizioneValue),
                        cliente: InterventoCliente(
                          id: idClientiFiltratiInt,
                          codice: codiciClientiString,
                          descrizione: _selectedClientValue,
                          partitaIva: partitaIvaClientiString,
                          codFiscale: codFiscaleClientiString,
                          indirizzo: indirizzoClientiString,
                          cap: capClientiString,
                          localita: localitaClientiString,
                          provincia: provinciaClientiString,
                          nazione: nazioneClientiString,
                          fax: faxClientiString,
                          email: emailClientiString,
                          telefono1: telefono1ClientiString,
                          telefono2: telefono2ClientiString,
                          codListino: codListinoClientiString,
                          categoriaIva: categoriaIvaClientiString,
                          aspettoBeni: aspettoBeniClientiString,
                          gruppoVendita: gruppoVenditaClientiString,
                          notePalmare: notePalmareClientiString,
                          porto: portoClientiString,
                          modTrasporto: modTrasportoClientiString,
                          modConsegna: modConsegnaClientiString,
                          causTrasporto: causTrasportoClientiString,
                          vettore: vettoreClientiString,
                          pagamento: pagamentoClientiString,
                          abi: abiClientiString,
                          cab: cabClientiString,
                          contocorrente: contocorrenteClientiString,
                          iban: ibanClientiString,
                          statusBlocco: statusBloccoClientiString,
                          datiContabili: datiContabiliClientiString,
                        ),
                        status: 'NO SYNCH',
                        magazzino: null,
                        metodoPagamento: null,
                        dataConsegna: null,
                        indirizzoSpedizione: null,
                        modalitaSpedizione: null,
                        totaleDocumento: null,
                        modTrasp: null,
                        modCons: null,
                        aspBeni: null,
                        causTrasp: null,
                        vettore: null,
                        totPesoLordo: null,
                        totPesoNetto: null,
                        totVolume: null,
                        numColli: null,
                        numPallet: null,
                        stPrezziDdt: null,
                        telefono1: null,
                        telefono2: null,
                        matricola: _matricolaController.text,
                        telaio: _telaioController.text,
                        rifMatricolaCliente: _targaController.text,
                        contMatricola: contMatricola,
                        note: _notaController.text,
                        righe: []
                        );

                    interventiDbProvider.addOrUpdate(nuovoIntervento);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Intervento salvato con successo!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MainView(),
                    ));
                    _showDetailsPageNuovoIntervento(nuovoIntervento, context, ref);
                  },
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: const Text(
                    'Salva',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: buttonStyle,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: clientiData.when(
                  data: (clientiCollection) {
                    var clienti = List<String>.from(clientiCollection
                        .map<String>((item) => item.descrizione.toString()))
                      ..removeWhere((description) =>
                          description.isEmpty || description.trim().isEmpty);

                    return DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Cerca...",
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                      items: ['SELEZIONA CLIENTE', ...clienti],
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "SELEZIONA CLIENTE",
                          hintStyle: const TextStyle(color: Colors.black),
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      onChanged: (String? value) {
                        _selectedClientValue = value;
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Cerca...",
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                items: const [
                  'RIPAUTES - RIPARAZIONE AUTOMEZZI ESTERNA',
                  'RIPAUTIN - RIPARAZIONE AUTOMEZZI INTERNA',
                  'RIPCLI - RIPARAZIONE A CARICO DEL CLIENTE'
                ],
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "SELEZIONA TIPO INTERVENTO",
                    hintStyle: const TextStyle(color: Colors.black),
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                onChanged: (String? value) {
                  switch (value) {
                    case 'RIPAUTES - RIPARAZIONE AUTOMEZZI ESTERNA':
                      _selectedTipoDocCodiceValue = 'RIPAUTES';
                      _selectedTipoDocDescrizioneValue = 'ORDINE RIPAUTES';
                      _selectedTipoDocIdValue = 112271;
                      break;
                    case 'RIPAUTIN - RIPARAZIONE AUTOMEZZI INTERNA':
                      _selectedTipoDocCodiceValue = 'RIPAUTIN';
                      _selectedTipoDocDescrizioneValue = 'ORDINE RIPAUTIN';
                      _selectedTipoDocIdValue = 112276;
                      break;
                    case 'RIPCLI - RIPARAZIONE A CARICO DEL CLIENTE':
                      _selectedTipoDocCodiceValue = 'RIPCLI';
                      _selectedTipoDocDescrizioneValue = 'RICHIESTA SERVIZI';
                      _selectedTipoDocIdValue = 112274;
                      break;
                    default:
                      _selectedTipoDocDescrizioneValue = null;
                      break;
                  }
                },
              ),
              const SizedBox(height: 20),
Row(
  children: [
    Expanded(
      child: TextField(
        controller: _targaController,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: "Inserisci la targa",
          hintStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        onChanged: (value) async {
          // final repository = ref.read(elencoMatricoleApiRepositoryProvider);
          // final matricola = await repository.getMatricola(
          //   utente: 'ADMIN',
          //   rifMatricolaCliente: targa,
          // );
          // if (matricola != null && matricola[0]['codice'] != null) {
          //   _matricolaController.text = matricola[0]['codice'].toString(); 
          //   _telaioController.text = matricola[0]['telaio'].toString();
          // }
        },
      ),
    ),
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () async {
        final repository = ref.read(elencoMatricoleApiRepositoryProvider);
final matricola = await repository.getMatricola(
  utente: 'ADMIN',
  rifMatricolaCliente: _targaController.text,
);

if (matricola != null && matricola.isNotEmpty) {
  _matricolaController.text = matricola[0]['codice'].toString(); 
  _telaioController.text = matricola[0]['telaio'].toString();
} else {
  _matricolaController.text = ''; 
  _telaioController.text = '';
}

      },
    ),
  ],
),

const SizedBox(height: 20),
TextField(
  controller: _matricolaController,
  style: const TextStyle(color: Colors.black),
  decoration: InputDecoration(
    hintText: "Matricola",
    hintStyle: const TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
  readOnly: false, // Imposta il campo di testo come non modificabile
),
              const SizedBox(height: 20),
              TextField(
                controller: _telaioController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Inserisci il telaio",
                  hintStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
  controller: _contMatricolaController,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  style: const TextStyle(color: Colors.black),
  decoration: InputDecoration(
    hintText: "Inserisci Km/Pz",
    hintStyle: const TextStyle(color: Colors.black),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    filled: true,
    fillColor: const Color.fromARGB(255, 255, 255, 255),
  ),
),
              const SizedBox(height: 20),
              TextField(
                controller: _notaController,
                maxLines: 10,
                maxLength: 500,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Inserisci una nota",
                  hintStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    return _targaController.text.isNotEmpty &&
        _telaioController.text.isNotEmpty &&
        _selectedClient!.isNotEmpty;
  }

  void _showDetailsPageNuovoIntervento(
      Intervento nuovoIntervento, BuildContext context, WidgetRef ref) {
    //String righeDescrizione = 'null';
    //String righeDaFareDescrizione = 'null';
    //String? righeStatusEvasione = intervento.righe.isNotEmpty ? intervento.righe[0].statusEvasione : '';
    ref.read(interventoApertoStateProvider.notifier).setIntervento(nuovoIntervento);
    //String? operatore = 'admin';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DetailsPage(),
      ),
    );
  }
}
