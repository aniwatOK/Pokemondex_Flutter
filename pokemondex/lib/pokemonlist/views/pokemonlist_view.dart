import 'package:flutter/material.dart';
import 'package:pokemondex/pokemondetail/views/pokemondetail_view.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<PokemonListItem> _pokemons = []; // เก็บรายชื่อ Pokémon ทั้งหมด
  int _offset = 0; // ตำแหน่งเริ่มต้นสำหรับการโหลดข้อมูล
  final int _limit = 100; // จำนวน Pokémon ที่โหลดต่อครั้ง
  bool _isLoadingMore = false; // สถานะการโหลดเพิ่มเติม
  bool _hasMore = true; // เช็คว่ามี Pokémon ให้โหลดเพิ่มอีกหรือไม่

  @override
  void initState() {
    super.initState();
    loadData(); // โหลดข้อมูลครั้งแรก
  }

  // โหลดข้อมูล Pokémon จาก API
  Future<void> loadData() async {
    if (_isLoadingMore || !_hasMore)
      return; // ถ้ากำลังโหลด หรือ ไม่มีข้อมูลเพิ่ม หยุดการทำงาน

    setState(() {
      _isLoadingMore = true; // กำลังโหลดข้อมูล
    });

    final response = await http.get(
      Uri.parse(
          'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=$_limit'),
    );

    if (response.statusCode == 200) {
      final data = PokemonListResponse.fromJson(jsonDecode(response.body));

      setState(() {
        _pokemons.addAll(data.results); // เพิ่มข้อมูลใหม่เข้าในลิสต์
        _offset += _limit; // ปรับค่า offset สำหรับโหลดครั้งถัดไป
        _hasMore =
            data.results.isNotEmpty; // ถ้าข้อมูลหมดแล้วจะหยุดการโหลดเพิ่ม
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });
      throw Exception('Failed to load Pokémon');
    }
  }

  // ฟังก์ชันเพื่อดึง ID จาก URL
  String getPokemonId(String url) {
    final uriParts = url.split('/');
    return uriParts[uriParts.length - 2];
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _pokemons.length + 1, // เพิ่ม 1 สำหรับปุ่ม "โหลดเพิ่ม"
      itemBuilder: (context, index) {
        if (index == _pokemons.length) {
          // ปุ่มสำหรับโหลดข้อมูลเพิ่ม
          if (_hasMore) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoadingMore ? null : loadData,
                child: _isLoadingMore
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Load More Pokémon'),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No more Pokémon to load')),
            );
          }
        }

        final pokemon = _pokemons[index];
        final pokemonId = getPokemonId(pokemon.url);
        final imageUrl =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';

        return ListTile(
          leading: Image.network(
            imageUrl,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          ),
          title: Text(
            pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
            style: const TextStyle(fontSize: 18),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemondetailView(pokemonListItem: pokemon),
            ),
          ),
        );
      },
    );
  }
}
