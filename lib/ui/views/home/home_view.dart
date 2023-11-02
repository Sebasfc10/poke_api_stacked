import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

final TextEditingController searchController = TextEditingController();

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, HomeViewModel viewModel, Widget? child) {
    List<Pokemon> filteredPokemons = viewModel.filteredPokemons;
    return Scaffold(
      body: viewModel.isBusy
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (query) {
                      viewModel.filterPokemons(query);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Pokémon',
                    ),
                  ),
                  FutureBuilder(
                    future: viewModel.fetchPokemons(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: viewModel.filteredPokemons.length,
                            itemBuilder: (context, index) {
                              final pokemon = viewModel.filteredPokemons[index];
                              return ListTile(
                                leading: pokemon.isLoading
                                    ? CircularProgressIndicator()
                                    : Image.network(pokemon.imageUrl),
                                title: Text(pokemon.name),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(pokemon.name),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Types: ${pokemon.types.join(', ')}"),
                                            Text("Stats:"),
                                            for (var stat in pokemon.stats)
                                              Text(
                                                  "${stat.name}: ${stat.value}"),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}
