import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({Key? key}) : super(key: key);

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  //初めはからのListを入れておく
  // List hits = [];
  List<PixabayImage> pixabayImages = [];

  Future<void> fetchImages(String text) async {
    final Response response = await Dio().get(
      'https://pixabay.com/api/?key=28087500-0a022241e0c3cf20895a099c3&q=$text&image_type=photo&pretty=true&per_page=100',
    );
    // hits = response.data['hits'];
    final List hits = response.data['hits'];
    pixabayImages = hits
        .map(
          (e) {
            return PixabayImage.formMap(e);
          },
        )
        .toList();
    setState(() {});
  }

  Future<void> shareImage(String url) async {
    //1.URLから画像をダウンロード
    final Response response = await Dio().get(
      url,
      //引数のurlに置き換え hit['webformatURL'],
      options: Options(responseType: ResponseType.bytes),
    );
    //2.ダウンロードしたデータをファイルに保存
    final Directory dir = await getTemporaryDirectory();
    final File file =
        await File('${dir.path}/image.png').writeAsBytes(response.data);
    //3.Shareパッケージを呼び出して共有
    Share.shareFiles([file.path]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: '花',
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            print(text);
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: pixabayImages.length,
        itemBuilder: (BuildContext context, int index) {
          final pixabayImage = pixabayImages[index];
          return InkWell(
            onTap: () async {
              shareImage(pixabayImage.webformatURL);
              // //1.URLから画像をダウンロード
              // final Response response = await Dio().get(
              //   hit['webformatURL'],
              //   options: Options(responseType: ResponseType.bytes),
              // );
              // //2.ダウンロードしたデータをファイルに保存
              // final Directory dir = await getTemporaryDirectory();
              // final File file = await File('${dir.path}/image.png')
              //     .writeAsBytes(response.data);
              // //3.Shareパッケージを呼び出して共有
              // Share.shareFiles([file.path]);
            },
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                pixabayImage.previewURL,
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 14,
                      ),
                      Text('${pixabayImage.likes}'),
                    ],
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class PixabayImage {
  final String webformatURL;
  final String previewURL;
  final int likes;

  PixabayImage(
      {required this.webformatURL,
      required this.previewURL,
      required this.likes});

  factory PixabayImage.formMap(Map<String, dynamic> map) {
    return PixabayImage(
      webformatURL: map['webformatURL'],
      previewURL: map['previewURL'],
      likes: map['likes'],
    );
  }
}
