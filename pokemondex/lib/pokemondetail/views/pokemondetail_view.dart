import 'package:flutter/material.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemondetailView extends StatefulWidget {
  final PokemonListItem pokemonListItem;

  const PokemondetailView({Key? key, required this.pokemonListItem})
      : super(key: key);

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  Map<String, dynamic>? _pokemonDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ดึงข้อมูลรายละเอียดของ Pokémon
  Future<void> loadData() async {
    final response = await http.get(Uri.parse(widget.pokemonListItem.url));

    if (response.statusCode == 200) {
      setState(() {
        _pokemonDetails = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  // ฟังก์ชันสร้าง URL สำหรับรูปภาพ Pokémon
  String getPokemonImage() {
    final id = _pokemonDetails?['id'] ?? '';
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  // แสดงประเภทของ Pokémon
  List<Widget> buildTypes() {
    final types = _pokemonDetails?['types'] ?? [];

    return types.map<Widget>((typeInfo) {
      final typeName = typeInfo['type']['name'];
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.purple.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          typeName.toUpperCase(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }).toList();
  }

  // แสดงสถานะของ Pokémon
  List<Widget> buildStats() {
    final stats = _pokemonDetails?['stats'] ?? [];

    return stats.map<Widget>((statInfo) {
      final statName = statInfo['stat']['name'];
      final statValue = statInfo['base_stat'];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
          children: [
            Text(
              statName.toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20), // ปรับให้เว้นระยะห่างเล็กน้อย
            Text(
              statValue.toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemonListItem.name.toUpperCase()),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // รูป Pokémon
                  Center(
                    child: Image.network(
                      getPokemonImage(),
                      height: 210,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ชื่อ Pokémon ตรงกลาง
                  Center(
                    child: Text(
                      widget.pokemonListItem.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ประเภทของ Pokémon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildTypes(),
                  ),
                  const SizedBox(height: 24),

                  // หัวข้อ Stats
                  const Center(
                    child: Text(
                      'STATS',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // สถานะของ Pokémon อยู่ตรงกลาง
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildStats(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
