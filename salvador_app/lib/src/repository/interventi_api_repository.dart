import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/models/intervento_model.dart';

part 'interventi_api_repository.g.dart';

final interventiApiRepositoryProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  final config = ref.read(configProvider);
  return InterventiApiRepository(dio: dio, config: config);
});

@Riverpod()
Future<List<Intervento>> interventiApi(InterventiApiRef ref, {String? numdoc}) async {
    var interventiRepository = ref.read(interventiApiRepositoryProvider);
    var interventiCollection = await interventiRepository.getInterventi(numDoc: numdoc);

    return interventiCollection;
}

class InterventiApiRepository {
  final Dio dio;
  final GlobalConfiguration config;

  InterventiApiRepository({required this.dio, required this.config}) {
    dio.interceptors.add(LogInterceptor());
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final HttpClient client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;


          return client;
        },
      );
  }

  Future<List<Intervento>> getInterventi({String? numDoc}) async {
  final salvadorApiUrl = config.getValue("SalvadorApiUrl");

    final Map<String, dynamic> requestData = {
      'utente': 'ADMIN',
      'dataLimite': '2023-01-01 01:00:00.000',
    };

    try {
      final response = await dio.post(
      '$salvadorApiUrl/commerciale/external/ordiniTabletSalvador',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: requestData,
      );

      final List<dynamic> rawData = response.data;
      List<Intervento> interventiList =
          rawData.map((data) => Intervento.fromJson(data)).toList();

      return interventiList;
    } catch (e) {
      print('Error during API call: $e');
      throw Exception('Failed to fetch Interventi Aperti');
    }
  }
}