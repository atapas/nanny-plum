import 'package:flutter/material.dart';
import 'package:flutter_wavenet/TextToSpeechAPI.dart';
import 'dart:io';
import 'package:audioplayer/audioplayer.dart';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Nanny Plum',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new MyHomePage(title: 'Nanny Plum'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  AudioPlayer audioPlugin = AudioPlayer();
  final TextEditingController _mamaQuery = TextEditingController();
  final TextEditingController _babyQuery = TextEditingController();

  bool _visible = false;
  bool _isWrong = false;


  initState() {
    super.initState();
  }


  void synthesizeText(String text, String name) async {
      if (audioPlugin.state == AudioPlayerState.PLAYING) {
        await audioPlugin.stop();
      }
      // Hard coding the voice related settings
      final String audioContent = await TextToSpeechAPI().synthesizeText(text, 'en-US-Wavenet-F', 'en-US');
      if (audioContent == null) return;
      final bytes = Base64Decoder().convert(audioContent, 0, audioContent.length);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wavenet.mp3');
      await file.writeAsBytes(bytes);
      await audioPlugin.play(file.path, isLocal: true);
  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: new Stack(children: <Widget>[
        
        Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: TextField(
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Comic Sans',
                fontSize: 20.0
              ),
              autofocus: true,
              obscureText: true,
              controller: _mamaQuery,
              keyboardType: TextInputType.multiline,
              // maxLines: 2,
              
              decoration: InputDecoration(
                  icon: Icon(Icons.keyboard, size: 60.0),
                  hintText: 'Mama Types...',
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                    ),
                  ),
              ),
            ),
          ),
          
          FloatingActionButton(
            elevation: 4.0,
            child: Icon(Icons.play_circle_filled),
            onPressed: () {
              final text = _mamaQuery.text;
              if (text.length == 0) return;
              synthesizeText(text, '');
            },
          ),

          Divider(
            color: Colors.black,
            height: 36,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Comic Sans',
                fontSize: 20.0
              ),
              autofocus: true,
              obscureText: false,
              controller: _babyQuery,
              keyboardType: TextInputType.multiline,
              //maxLines: 2,
              
              decoration: InputDecoration(
                  icon: Icon(Icons.keyboard, size: 60.0),
                  hintText: 'Baby Types...',
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(
                    ),
                  ),
              ),
            ),
          ),
          
          FloatingActionButton(
            elevation: 4.0,
            child: Icon(Icons.play_circle_filled),
            onPressed: () {
              final text = _babyQuery.text;
              if (text.length == 0) return;
              synthesizeText(text, '');

              setState(() {
                if(_mamaQuery.text.toLowerCase() != _babyQuery.text.toLowerCase()) {
                  _isWrong = true;
                  return;
                } else {
                  _isWrong = false;
                }
                _visible = true;
                Timer(Duration(seconds: 3), () {
                  print("Yeah, this line is printed after 3 second");
                  setState(() {
                     _visible = false;
                  });
                });
              });
            },
          ),

          if(_isWrong) Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
            child: Image(
            image: new AssetImage("assets/wrong.gif"),
              fit: BoxFit.fill,
            )
          )
        ]),
       
        if(_visible) Image(
          image: new AssetImage("assets/nanny-trans.png"),
          fit: BoxFit.fill,
        )
      ]
      ))
    );
  }

}
