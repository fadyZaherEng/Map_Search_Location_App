import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_search_places/presentation/screens/map_search/map_search_screen.dart';
 import 'package:map_search_places/generated/l10n.dart';
import 'package:map_search_places/presentation/screens/map_search/map_search_screen.dart';
import 'package:map_search_places/presentation/screens/map_search/widgets/save_location_toggle_widget.dart';
import 'package:map_search_places/theme/app_colors.dart';

class BottomContentWidget extends StatelessWidget {
  final LatLng? currentPosition;
  final TextEditingController addressController;
  final List<Relationship> relationship;
  final int relationshipIndex;
  final void Function(int relationInedx) onRelationshipChanged;
  final bool isSaveLocation;
  final Function(bool ) onSaveLocation;
  final Function({
    required String address,
    required bool isSaveLocation,
    required String relationship,
  }) onContinue;

  const BottomContentWidget({
    super.key,
    required this.currentPosition,
    required this.addressController,
    required this.isSaveLocation,
    required this.onSaveLocation,
    required this.onContinue,
    required this.relationship,
    required this.onRelationshipChanged,
    required this.relationshipIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 3,
                  width: 100,
                  color: AppColors.color999999,
                  margin: const EdgeInsets.only(bottom: 10, top: 6),
                ),
                Text(
                  S.of(context).detailsYourLocation,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width * 0.9,
            color: AppColors.color999999.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).location,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 55,
            child: TextField(
              readOnly: true,
              controller: addressController,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.location_pin),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: AppColors.color999999,
                    width: 0.005,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                S.of(context).wantToSaveThisLocation,
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              if (currentPosition != null)
                SaveLocationToggleWidget(
                  value: isSaveLocation,
                  onTap: (value) {
                    onSaveLocation(value);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _locationTag(S.of(context).home, 0, Icons.home,
                  isSelected: relationshipIndex == 0),
              _locationTag(S.of(context).work, 1, Icons.work,
                  isSelected: relationshipIndex == 1),
              _locationTag(S.of(context).friend, 2, Icons.person,
                  isSelected: relationshipIndex == 2),
              _locationTag(S.of(context).restaurant, 3, Icons.restaurant,
                  isSelected: relationshipIndex == 3),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onContinue(
                address: addressController.text,
                isSaveLocation: isSaveLocation,
                relationship: relationship[relationshipIndex].name,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: currentPosition == null
                  ? AppColors.background
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              S.of(context).continues,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _locationTag(
    String label,
    int index,
    IconData icon, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        onRelationshipChanged(index);
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: currentPosition == null
                  ? Border.all(color: AppColors.background, width: 1.0)
                  : Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.color999999,
                    ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: currentPosition == null
                  ? AppColors.background
                  : isSelected
                      ? AppColors.primary
                      : AppColors.background,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.color999999,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            relationship[index].name,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
