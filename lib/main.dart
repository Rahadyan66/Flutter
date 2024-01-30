import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TES PKL',
      home: MyHomePage(title: 'TES_PKL'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String profileImageStatus = 'No Image';
  List<Uint8List> imageBytesList = [];

  Future<void> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();

    try {
      XFile? pickedImage = await imagePicker.pickImage(
        maxHeight: 1080,
        maxWidth: 1080,
        source: source,
      );

      if (pickedImage != null) {
        Uint8List imageBytes = await pickedImage.readAsBytes();
        setState(() {
          profileImageStatus = 'Gambar di Unggah';
          imageBytesList.add(imageBytes);
        });

        // Memanggil fungsi untuk mengirim gambar ke API Laravel
        sendImageToLaravelApi(imageBytes);
      } else {
        // Handle jika pickedImage null
        print('Gambar tidak dipilih');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> sendImageToLaravelApi(Uint8List imageBytes) async {
    final apiUrl = 'http://127.0.0.1:8000/api/image';

    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'image':
            await MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
      });

      final response = await dio.post(
        apiUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        // Sukses, lakukan sesuatu sesuai kebutuhan
        print('Gambar berhasil diunggah ke API Laravel');
      } else {
        // Tangani respon error
        print('Gagal mengunggah gambar. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Tangani kesalahan jaringan atau kesalahan lainnya
      print('Error mengunggah gambar ke API Laravel: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            if (imageBytesList.isEmpty)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              )
            else
              Container(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageBytesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: 140,
                      margin: EdgeInsets.only(right: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(imageBytesList[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 40),
            Text(
              profileImageStatus,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                pickImage(ImageSource.gallery);
              },
              child: const Text(
                'Pilih Gambar dari Galeri',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                pickImage(ImageSource.camera);
              },
              child: const Text(
                'Ambil Gambar dari Kamera',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
