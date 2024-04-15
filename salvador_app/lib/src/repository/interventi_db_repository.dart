import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';

part 'interventi_db_repository.g.dart';

@Riverpod(keepAlive: true)
class InterventiDbRepository extends _$InterventiDbRepository {
  @override
  Future<List<Intervento>> build() async {
    var erpdb = await ref.read(erpdbProvider.future);
    var erpinterventi = await erpdb.interventos.where().build().findAllAsync();

    var localdb = await ref.read(localdbProvider.future);
    var localinterventi = await localdb.interventos.where().build().findAllAsync();

    var result = [...erpinterventi.where((ei) => !localinterventi.any((li) => li.idTestata == ei.idTestata)), ...localinterventi];

    return result;
  }

  Future<void> deleteInterventoById(int idTestata) async {
    try {
      var db = await ref.read(localdbProvider.future);
      
      await db.writeAsync((isar) {
        isar.interventos.delete(idTestata);
      });

    } catch (e) {
      print('Error deleting Intervento: $e');
    }
  }

  void updateInterventi(List<Intervento> erpinterventi) async {
    state = const AsyncLoading();
    var db = await ref.read(erpdbProvider.future);
    await db.writeAsync((isar) {
      isar.interventos.putAll(erpinterventi);
    });
    state = AsyncData(erpinterventi);
  }

     Future<void> saveChanges(Intervento interventoApertoState) async {
    var db = await ref.read(localdbProvider.future);
    // Utilizza writeAsync per scrivere in modo asincrono sul database Isar
    await db.writeAsync((isar) {
      // Utilizza putAll per salvare tutti gli interventi presenti nello stato
      isar.interventos.put(interventoApertoState);
    });
  }

  Future<void> addOrUpdate(Intervento nuovoIntervento) async {
    var db = await ref.read(localdbProvider.future);
    await db.writeAsync((isar) {
      isar.interventos.put(nuovoIntervento);
    });
  }

  Future<String?> getUltimoNumeroDocumento() async {
    var db = await ref.read(localdbProvider.future);
    var interventi = await db.interventos.where().findAllAsync();

  if (interventi.isNotEmpty) {
    interventi.sort((a, b) => b.dataDoc.compareTo(a.dataDoc));
    var ultimoIntervento = interventi.first;
    return ultimoIntervento.numDoc;
  } else {
    return null;
  }
  }
}
