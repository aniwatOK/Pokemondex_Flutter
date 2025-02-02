import 'package:flutter/material.dart';
import 'package:pokemondex/pokemondetail/views/pokemondetail_view.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({
    super.key,
  });

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  PokemonListResponse? _data;
  late Future<List<PokemonListItem>> _list;

  @override
  void initState() {
    super.initState();
    _list = loadData();
  }

  //load data
  Future<List<PokemonListItem>> loadData() async {
    //fetch data
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon'));
    if (response.statusCode == 200) {
      final PokemonListResponse data =
          PokemonListResponse.fromJson(jsonDecode(response.body));
      return data.results;
    } else {
      throw Exception('Failed to load Pokemon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PokemonListItem>>(
        future: _list,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Pokemon found'));
          } else {
            final List<PokemonListItem> response =
                snapshot.data as List<PokemonListItem>;

            return ListView.builder(
              itemCount: response.length,
              itemBuilder: (context, index) {
                final PokemonListItem pokemon = response[index];
                return ListTile(
                    title: Text(pokemon.name),
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PokemondetailView(
                              pokemonListItem: pokemon,
                            ),
                          ),
                        ));
              },
            );
          }
        });
  }
}
