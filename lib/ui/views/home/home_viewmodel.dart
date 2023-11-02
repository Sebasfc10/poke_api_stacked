import 'dart:async';

import 'package:my_first_app/app/app.bottomsheets.dart';
import 'package:my_first_app/app/app.dialogs.dart';
import 'package:my_first_app/app/app.locator.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:my_first_app/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _apiService = locator<ApiService>();
  List<Pokemon> _pokemons = [];
  List<Pokemon> _filteredPokemons = [];

  List<Pokemon> get filteredPokemons => _filteredPokemons;
  String get counterLabel => 'Counter is: $_counter';

  int _counter = 0;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  Future<void> fetchPokemons() async {
/*     setBusy(true); */
    try {
      _pokemons = await _apiService.getPokemons();
      for (final pokemon in _pokemons) {
        await _apiService.fetchPokemonDetails(pokemon);
      }
      await _apiService.fetchPokemonImages(_pokemons);
      _filteredPokemons = List.from(_pokemons);
    } catch (e) {
      print('error 1: ${e.toString()}');
    }
  }

  void filterPokemons(String query) {
    _filteredPokemons = _pokemons
        .where((pokemon) =>
            pokemon.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
