import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<Pokemon>> getPokemons() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      return data.map((pokemon) => Pokemon.fromJson(pokemon)).toList();
    } else {
      throw Exception('Failed to load Pokemon data');
    }
  }

  Future<String> getPokemonsImageUrl(String pokemonName) async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'));
    if (response.statusCode == 200) {
      final imageUrl = json.decode(response.body)['sprites']['other']
          ['official-artwork']['front_default'];

      return imageUrl;
    } else {
      throw Exception('Failed to load Pokemon image');
    }
  }

  Future<void> fetchPokemonImages(List<Pokemon> pokemons) async {
    for (final pokemon in pokemons) {
      final imageUrl = await getPokemonsImageUrl(pokemon.name);
      pokemon.imageUrl = imageUrl;
      pokemon.isLoading = false;
    }
  }

  Future<void> fetchPokemonDetails(Pokemon pokemon) async {
    final response = await http.get(Uri.parse(pokemon.url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final types = data['types'] as List<dynamic>;
      pokemon.types = types.map((typeData) {
        final type = typeData['type'];
        final typeName = type['name'];
        return typeName.toString();
      }).toList();

      var stats = data['stats'] as List<dynamic>;
      pokemon.stats = stats.map((statData) {
        final statName = statData['stat']['name'];
        final statValue = statData['base_stat'];
        return Stat(name: statName, value: statValue);
      }).toList();

      final imageUrl =
          data['sprites']['other']['official-artwork']['front_default'];
      pokemon.imageUrl = imageUrl;
      pokemon.isLoading = false;
    } else {
      throw Exception('Failed to load Pokemon details');
    }
  }
}

class Pokemon {
  final String name;
  final String url;
  String imageUrl;
  bool isLoading;
  List<String> types;
  List<Stat> stats;

  Pokemon({
    required this.name,
    required this.url,
    this.imageUrl = "",
    this.isLoading = true,
    this.types = const [],
    this.stats = const [],
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
    );
  }
}

class Stat {
  final String name;
  final int value;

  Stat({required this.name, required this.value});
}
