import 'package:http/http.dart' as http;
import 'package:resepinajamobile/models/Alat.dart';
import 'package:resepinajamobile/models/AppData.dart';
import 'package:resepinajamobile/models/Bahan.dart';
import 'package:resepinajamobile/models/Detail.dart';
import 'dart:convert';
import 'package:resepinajamobile/models/Item.dart';
import 'package:resepinajamobile/models/Langkah.dart';

class Recipeservice {

  static Future<List<Item>?> showResepBaru() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/resepbaru'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'];
      return items
          .map(
            (json) => Item(
              (json['id_saved'] as int?) ?? 0,
              json['id_resep'] as int,
              json['bintang']?.toDouble() ?? 0.0,
              json['judul'] as String,
              json['gambar'] as String,
            ),
          )
          .toList();
    } else {
      return null;
    }
  }

  static Future<List<Item>?> showResepPopuler() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/reseppopuler'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'];
      return items
          .map(
            (json) => Item(
              (json['id_saved'] as int?) ?? 0,
              json['id_resep'] as int,
              json['bintang']?.toDouble() ?? 0.0,
              json['judul'] as String,
              json['gambar'] as String,
            ),
          )
          .toList();
    } else {
      return null;
    }
  }

  static Future<List<Item>?> showResepCari(String kunci) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/resepcari/$kunci'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'];
      return items
          .map(
            (json) => Item(
              (json['id_saved'] as int?) ?? 0,
              json['id_resep'] as int,
              json['bintang']?.toDouble() ?? 0.0,
              json['judul'] as String,
              json['gambar'] as String,
            ),
          )
          .toList();
    } else {
      return null;
    }
  }

  static Future<List<Item>?> showResepSendiri(int id_user) async {
    // final prefs = await SharedPreferences.getInstance();
    // final id_user = prefs.getInt('id_user');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/resepsendiri/$id_user'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'];
      return items
          .map(
            (json) => Item(
              (json['id_saved'] as int?) ?? 0,
              json['id_resep'] as int,
              json['bintang']?.toDouble() ?? 0.0,
              json['judul'] as String,
              json['gambar'] as String,
            ),
          )
          .toList();
    } else {
      return null;
    }
  }

  static Future<List<Item>?> showResepTersimpan(int id_user) async {
    final token = AppData().token;
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/tersimpanresep/$id_user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data['data'];
      return items
          .map(
            (json) => Item(
              (json['id_saved'] as int?) ?? 0,
              json['id_resep'] as int,
              json['bintang']?.toDouble() ?? 0.0,
              json['judul'] as String,
              json['gambar'] as String,
            ),
          )
          .toList();
    } else {
      return null;
    }
  }

  static Future<Detail?> showResepDetail(int id_resep) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/detailresep/$id_resep'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body)['data'];

        final Map<String, dynamic> resep = data['resep'];

        if (resep['bintang'] == null) {
          resep['bintang'] = 0;
        }

        final List<Alat> alatList =
            (data['alat'] as List)
                .map(
                  (json) =>
                      Alat(json['id_alat'] as int, json['id_resep'] as int, json['nama_alat'] as String),
                )
                .toList();

        final List<Bahan> bahanList =
            (data['bahan'] as List)
                .map(
                  (json) =>
                      Bahan(json['id_bahan'] as int, json['id_resep'] as int, json['nama_bahan'] as String),
                )
                .toList();

        final List<Langkah> langkahList =
            (data['langkah'] as List)
                .map(
                  (json) => Langkah(
                    json['id_langkah'] as int,
                    json['id_resep'] as int,
                    json['urutan'] as int,
                    json['cara_langkah'] as String,
                  ),
                )
                .toList();

        return Detail(
          resep['id_resep'] as int,
          resep['judul'] as String,
          resep['gambar'] as String,
          resep['deskripsi'] as String,
          resep['id_user'] as int,
          resep['username'] as String,
          resep['bintang'].toString(),
          alatList,
          bahanList,
          langkahList,
        );
      }
    } catch (e) {
      print('Error fetching recipe detail: $e');
    }
    return null;
  }
  
}
