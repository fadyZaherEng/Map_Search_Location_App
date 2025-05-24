import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:map_search_places/theme/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  final List<Prediction> predictions;

  final TextEditingController searchController;

  final void Function(String query) getPredictions;
  final void Function() clearSearch;

  const HeaderWidget({
    super.key,
    required this.predictions,
    required this.searchController,
    required this.getPredictions,
    required this.clearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "yourLocation",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: searchController,
          onChanged: (value) => getPredictions(value),
          decoration: InputDecoration(
            hintText: "searchAboutYourLocation",
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.color999999,
            ),
            prefixIcon: const Icon(
              Icons.my_location,
              color: AppColors.color999999,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.color999999,
              ),
              onPressed: clearSearch,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
