import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) {
  runApp(const MaterialApp(
    title: 'Semantics - The Finding Word App',
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum QueryState { meanLike, spellLike, soundLike, oppositeOf, partOf, fillIn }
List<String> commandStates = [
  "means like...",
  "sounds like...",
  "spells like...",
  "are opposite of...",
  "are part of...",
  "could fill in..."
];

class WordResult {
  final String word;
  final int score;
  final List<String> tags;

  const WordResult({
    required this.word,
    required this.score,
    required this.tags,
  });

  factory WordResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('tags')) {
      return WordResult(
          word: json['word'], score: json['score'], tags: [...json['tags']]);
    }
    return WordResult(word: json['word'], score: json['score'], tags: []);
  }
}

class DatamuseApi {
  final String baseURL = "api.datamuse.com";

  Future<List<WordResult>> getWordsMeanLike(String str) async {
    List<WordResult> result = [];
    Uri finalUrl = Uri.https(baseURL, '/words', {'ml': str});

    var response = await http.get(finalUrl);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var response in jsonResponse) {
        result.add(WordResult.fromJson(response));
      }
    } else {
      throw Exception('Failed fetching data');
    }

    return result;
  }

  Future<List<WordResult>> getWordsSoundLike(String str) async {
    List<WordResult> result = [];
    Uri finalUrl = Uri.https(baseURL, '/words', {'sl': str});

    var response = await http.get(finalUrl);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var response in jsonResponse) {
        result.add(WordResult.fromJson(response));
      }
    } else {
      throw Exception('Failed fetching data');
    }

    return result;
  }

  Future<List<WordResult>> getWordsSpellLike(String str) async {
    List<WordResult> result = [];
    Uri finalUrl = Uri.https(baseURL, '/words', {'sp': str});

    var response = await http.get(finalUrl);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var response in jsonResponse) {
        result.add(WordResult.fromJson(response));
      }
    } else {
      throw Exception('Failed fetching data');
    }

    return result;
  }

  Future<List<WordResult>> getWordsOppositeOf(String str) async {
    List<WordResult> result = [];
    Uri finalUrl = Uri.https(baseURL, '/words', {'rel_ant': str});

    var response = await http.get(finalUrl);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var response in jsonResponse) {
        result.add(WordResult.fromJson(response));
      }
    } else {
      throw Exception('Failed fetching data');
    }

    return result;
  }

  Future<List<WordResult>> getWordsPartOf(String str) async {
    List<WordResult> result = [];
    Uri finalUrl = Uri.https(baseURL, '/words', {'rel_par': str});

    var response = await http.get(finalUrl);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var response in jsonResponse) {
        result.add(WordResult.fromJson(response));
      }
    } else {
      throw Exception('Failed fetching data');
    }

    return result;
  }

  Future<List<WordResult>> getWordsCouldFill(String str) async {
    String beforeWord = "";
    String afterWord = "";

    List<String> sentenceSplit = str.split(' ');
    if (sentenceSplit.contains("???")) {
      for (int i = 0; i < sentenceSplit.length; i++) {
        if (sentenceSplit[i] == "???") {
          if (i == 0 && i == sentenceSplit.length - 1) {
            break;
          }

          if (i == 0) {
            afterWord = sentenceSplit[i + 1];
            break;
          }

          if (i == sentenceSplit.length - 1) {
            beforeWord = sentenceSplit[i - 1];
            break;
          }

          if (i > 0 && i < sentenceSplit.length) {
            beforeWord = sentenceSplit[i - 1];
            afterWord = sentenceSplit[i + 1];
            break;
          }
        }
      }
    }

    List<WordResult> result = [];

    Uri finalUrl;
    if (beforeWord != "" && afterWord != "") {
      finalUrl = Uri.https(
          baseURL, '/words', {'rel_bga': beforeWord, 'rel_bgb': afterWord});
    } else if (beforeWord != "") {
      finalUrl = Uri.https(baseURL, '/words', {'rel_bga': beforeWord});
    } else if (afterWord != "") {
      finalUrl = Uri.https(baseURL, '/words', {'rel_bgb': afterWord});
    } else {
      return result;
    }

    print(beforeWord + ' ' + afterWord);

    var response = await http.get(finalUrl);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      for (var response in jsonResponse) {
        result.add(WordResult.fromJson(response));
      }
    } else {
      throw Exception('Failed fetching data');
    }

    return result;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // States
  QueryState? _queryState = QueryState.meanLike;
  String _queryCommandState = commandStates[0];
  bool _apiLoad = false;
  bool _showTopFAB = false;

  late Future<List<WordResult>>? futureResult;

  // Controller
  final queryFieldController = TextEditingController();
  late ScrollController scrollController;

  void changeHeaderText(int index) {
    setState(() {
      _queryCommandState = commandStates[index];
    });
  }

  Future<List<WordResult>>? callDatamuseApi(String str) {
    var datamuse = DatamuseApi();

    switch (_queryState) {
      case QueryState.meanLike:
        return datamuse.getWordsMeanLike(str).whenComplete(() => setState(() {
              _apiLoad = false;
            }));
      case QueryState.soundLike:
        return datamuse.getWordsSoundLike(str).whenComplete(() => setState(() {
              _apiLoad = false;
            }));
      case QueryState.spellLike:
        return datamuse.getWordsSpellLike(str).whenComplete(() => setState(() {
              _apiLoad = false;
            }));
      case QueryState.oppositeOf:
        return datamuse.getWordsOppositeOf(str).whenComplete(() => setState(() {
              _apiLoad = false;
            }));
      case QueryState.partOf:
        return datamuse.getWordsPartOf(str).whenComplete(() => setState(() {
              _apiLoad = false;
            }));
      case QueryState.fillIn:
        return datamuse.getWordsCouldFill(str).whenComplete(() => setState(() {
              _apiLoad = false;
            }));
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    futureResult = null;

    scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (scrollController.offset >= 400) {
            _showTopFAB = true;
          } else {
            _showTopFAB = false;
          }
        });
      });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollTop() {
    scrollController.animateTo(0,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: SizedBox(
            child: Padding(
                padding: const EdgeInsets.only(left: 0),
                child: SvgPicture.asset('assets/image/semantics.svg')),
            width: 120,
            height: 120,
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext builder) {
                        return SimpleDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 20, right: 20),
                                  child: RichText(
                                      text: const TextSpan(
                                          text: 'About',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.bold)))),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 20, right: 20),
                                  child: RichText(
                                      text: const TextSpan(
                                          text:
                                              'Semantics is word finding app that utilizes Datamuse\'s API for a variety of use cases. The powerful query engine built by Datamuse enables this application to be running.',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Quicksand',
                                          )))),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 20, right: 20),
                                  child: RichText(
                                      text: const TextSpan(
                                          text: 'How it Works?',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.bold)))),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, left: 20, right: 20),
                                  child: RichText(
                                      text: const TextSpan(
                                          text:
                                              'Simple, you just input a word or a sentence and it finds it for you. Hint: If you are using the \'Could Fill In\' feature, make sure to fill in the blanks with \'???\'',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Quicksand',
                                          )))),
                            ]);
                      });
                },
                icon: const Icon(Icons.help_outline_rounded))
          ],
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leadingWidth: 0,
        ),
        floatingActionButton: _showTopFAB == false
            ? null
            : FloatingActionButton(
                onPressed: _scrollTop,
                child: const Icon(Icons.arrow_upward),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white),
        body: SingleChildScrollView(
          controller: scrollController,
          // scrollDirection: Axis.vertical,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 40, bottom: 40, left: 20, right: 20),
              child: Container(
                alignment: Alignment.center,
                child: Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      RichText(
                          text: TextSpan(
                              text: 'Words that ',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Quicksand',
                                  fontSize: 18),
                              children: <TextSpan>[
                            TextSpan(
                                text: '$_queryCommandState',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Quicksand',
                                    fontSize: 18))
                          ])),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context, StateSetter state) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 40,
                                        bottom: 20,
                                        left: 10,
                                        right: 10),
                                    child: ListView(children: <Widget>[
                                      RadioListTile<QueryState>(
                                          title: RichText(
                                              text: const TextSpan(
                                                  text:
                                                      'Words that means like...',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          value: QueryState.meanLike,
                                          groupValue: _queryState,
                                          activeColor: Colors.green,
                                          onChanged: (QueryState? value) {
                                            state(() {
                                              _apiLoad = true;
                                              _queryState = value;
                                              changeHeaderText(0);
                                              futureResult = callDatamuseApi(
                                                  queryFieldController.text)!;
                                            });
                                          }),
                                      RadioListTile<QueryState>(
                                          title: RichText(
                                              text: const TextSpan(
                                                  text:
                                                      'Words that sounds like...',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          value: QueryState.soundLike,
                                          groupValue: _queryState,
                                          activeColor: Colors.green,
                                          onChanged: (QueryState? value) {
                                            state(() {
                                              _apiLoad = true;
                                              _queryState = value;
                                              changeHeaderText(1);
                                              futureResult = callDatamuseApi(
                                                  queryFieldController.text)!;
                                            });
                                          }),
                                      RadioListTile<QueryState>(
                                          title: RichText(
                                              text: const TextSpan(
                                                  text:
                                                      'Words that spells like...',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          value: QueryState.spellLike,
                                          groupValue: _queryState,
                                          activeColor: Colors.green,
                                          onChanged: (QueryState? value) {
                                            state(() {
                                              _apiLoad = true;
                                              _queryState = value;
                                              changeHeaderText(2);
                                              futureResult = callDatamuseApi(
                                                  queryFieldController.text)!;
                                            });
                                          }),
                                      RadioListTile<QueryState>(
                                          title: RichText(
                                              text: const TextSpan(
                                                  text:
                                                      'Words that are opposite of...',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          value: QueryState.oppositeOf,
                                          groupValue: _queryState,
                                          activeColor: Colors.green,
                                          onChanged: (QueryState? value) {
                                            state(() {
                                              _apiLoad = true;
                                              _queryState = value;
                                              changeHeaderText(3);
                                              futureResult = callDatamuseApi(
                                                  queryFieldController.text)!;
                                            });
                                          }),
                                      RadioListTile<QueryState>(
                                          title: RichText(
                                              text: const TextSpan(
                                                  text:
                                                      'Words that are part of...',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          value: QueryState.partOf,
                                          groupValue: _queryState,
                                          activeColor: Colors.green,
                                          onChanged: (QueryState? value) {
                                            state(() {
                                              _apiLoad = true;
                                              _queryState = value;
                                              changeHeaderText(4);
                                              futureResult = callDatamuseApi(
                                                  queryFieldController.text)!;
                                            });
                                          }),
                                      RadioListTile<QueryState>(
                                          title: RichText(
                                              text: const TextSpan(
                                                  text:
                                                      'Words that can fill the blank of...',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'Quicksand'))),
                                          value: QueryState.fillIn,
                                          groupValue: _queryState,
                                          activeColor: Colors.green,
                                          onChanged: (QueryState? value) {
                                            state(() {
                                              _apiLoad = true;
                                              _queryState = value;
                                              changeHeaderText(5);
                                              futureResult = callDatamuseApi(
                                                  queryFieldController.text)!;
                                            });
                                          }),
                                    ]),
                                  );
                                });
                              });
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(content: Text('BottomSheet')));
                        },
                        icon: const Icon(Icons.expand_more),
                        splashColor: Colors.transparent,
                      )
                    ],
                  ),
                  TextFormField(
                    controller: queryFieldController,
                    minLines: 2,
                    maxLines: 2,
                    autocorrect: true,
                    cursorColor: Colors.green,
                    style: const TextStyle(
                        fontFamily: 'Quicksand', fontWeight: FontWeight.w200),
                    decoration: const InputDecoration(
                        fillColor: Color.fromARGB(135, 241, 241, 241),
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 150,
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            if (queryFieldController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Text not Found!")));
                              return;
                            }
                            setState(() {
                              _apiLoad = true;
                              futureResult =
                                  callDatamuseApi(queryFieldController.text)!;
                            });
                          },
                          child: RichText(
                              text: const TextSpan(
                                  text: 'Search',
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.bold))),
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            backgroundColor: Colors.green,
                            alignment: Alignment.center,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: FutureBuilder<List<WordResult>>(
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.none &&
                                snapshot.hasData == null) {
                              return Container();
                            }

                            if (_apiLoad) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 80, bottom: 20),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                      color: Colors.green,
                                    ),
                                  ));
                            }

                            return Center(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data?.length ?? 0,
                                  itemBuilder: ((context, index) {
                                    return ListTile(
                                      title: RichText(
                                          text: TextSpan(
                                              text: snapshot.data![index].word,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: 'Quicksand',
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      subtitle: RichText(
                                          text: TextSpan(
                                              text: snapshot.data![index].tags
                                                  .join(' '),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Quicksand',
                                              ))),
                                      trailing: RichText(
                                        text: TextSpan(
                                            text: snapshot.data![index].score
                                                .toString(),
                                            style: const TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green)),
                                      ),
                                    );
                                  })),
                            );
                          },
                          future: futureResult))
                ]),
              ),
            ),
          ]),
        ),
      )),
    );
  }
}
