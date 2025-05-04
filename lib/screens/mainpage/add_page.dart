import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:developer';
import 'dart:io';

import 'package:resepinajamobile/models/AppData.dart';

class AddRecipePage extends StatefulWidget {
  final VoidCallback? onRecipeAdded;
  const AddRecipePage({super.key, this.onRecipeAdded});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  File? _gambar;
  List<TextEditingController> _bahanControllers = [TextEditingController()];
  List<TextEditingController> _alatControllers = [TextEditingController()];
  List<TextEditingController> _langkahControllers = [TextEditingController()];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _gambar = File(pickedFile.path);
      });
    }
  }

  void _addField(List<TextEditingController> list) {
    setState(() {
      list.add(TextEditingController());
    });
  }

  void _removeField(List<TextEditingController> list, int index) {
    if (list.length > 1) {
      setState(() {
        list.removeAt(index);
      });
    }
  }

  void removeFormValue() {
    setState(() {
      _judulController.clear();
      _deskripsiController.clear();
      _gambar = null;
      for (var controller in _bahanControllers) {
        controller.clear();
      }
      for (var controller in _alatControllers) {
        controller.clear();
      }
      for (var controller in _langkahControllers) {
        controller.clear();
      }
      _bahanControllers = [TextEditingController()];
      _alatControllers = [TextEditingController()];
      _langkahControllers = [TextEditingController()];
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _gambar != null) {
      try {
        final token = AppData().token;
        var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8000/api/addresep'));
        request.headers['Accept'] = 'application/json';
        request.headers['Authorization'] = 'Bearer $token';

        // Add text fields
        request.fields['judul'] = _judulController.text;
        request.fields['deskripsi'] = _deskripsiController.text;
        request.fields['id_user'] = AppData().id_user.toString();
        request.fields['bahan'] = jsonEncode(_bahanControllers.map((c) => c.text).toList());
        request.fields['alat'] = jsonEncode(_alatControllers.map((c) => c.text).toList());
        request.fields['langkah'] = jsonEncode(_langkahControllers.map((c) => c.text).toList());

        request.files.add(
          await http.MultipartFile.fromPath('gambar', _gambar!.path, contentType: MediaType('image', '*')),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          if (widget.onRecipeAdded != null) widget.onRecipeAdded!();
          removeFormValue();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Resep berhasil disimpan!')));
        } else {
          var responseString = await response.stream.bytesToString();
          var jsonResponse = jsonDecode(responseString);
          log(jsonResponse.toString());
          throw Exception(Error);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    for (var c in _bahanControllers) {
      c.dispose();
    }
    for (var c in _alatControllers) {
      c.dispose();
    }
    for (var c in _langkahControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.redAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tambah Resepmu", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 226, 226, 226)),
              child: Text("Post"),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Resep', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan judul resep';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gambar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gambar Resep', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          _gambar == null
                              ? const Center(child: Icon(Icons.add_a_photo, size: 50))
                              : Image.file(_gambar!, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // deskripsi
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'deskripsi', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan deskripsi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bahan
              _buildDynamicFields(
                title: 'Bahan-bahan',
                controllers: _bahanControllers,
                hintText: 'Masukkan bahan',
              ),
              const SizedBox(height: 16),

              // Alat
              _buildDynamicFields(
                title: 'Alat-alat',
                controllers: _alatControllers,
                hintText: 'Masukkan alat',
              ),
              const SizedBox(height: 16),

              // Langkah Pembuatan
              _buildDynamicFields(
                title: 'Langkah Pembuatan',
                controllers: _langkahControllers,
                hintText: 'Masukkan langkah',
                isNumbered: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields({
    required String title,
    required List<TextEditingController> controllers,
    required String hintText,
    bool isNumbered = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  if (isNumbered)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  Expanded(
                    child: TextFormField(
                      maxLines: null,
                      controller: controllers[index],
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _removeField(controllers, index),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi field ini';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _addField(controllers),
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ),
      ],
    );
  }
}
