import 'package:flutter/material.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';

class PokemondetailView extends StatefulWidget {
  final PokemonListItem pokemonListItem;

  const PokemondetailView({Key? key, required this.pokemonListItem})
      : super(key: key);

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  //load data
  void loadData() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text(widget.pokemonListItem.name),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text(widget.pokemonListItem.name),
            )));
  }
}
