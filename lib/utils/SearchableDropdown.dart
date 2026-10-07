import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:get/get.dart';

class SearchableDropdown extends StatelessWidget {
  final List<String> items;
  final String label;
  final RxString selected;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.label,
    required this.selected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Obx(() {
      // Debug: Print items when widget builds
      print('🔍 SearchableDropdown for $label: ${items.length} items');
      if (items.isEmpty) {
        print('⚠️ No items available for $label');
      }

      return DropdownSearch<String>(
        items: (filter, loadProps) {
          // Return all items - the dropdown handles filtering
          print('📋 Loading items for $label: ${items.length}');
          return items;
        },
        selectedItem: selected.value.isEmpty ? null : selected.value,
        onChanged: (value) {
          if (value != null) {
            print('✅ Selected $label: $value');
            selected.value = value;
          }
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              hintText: "Search $label",
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          constraints: const BoxConstraints(maxHeight: 400), // Increased height
          menuProps: const MenuProps(elevation: 8),
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.blue),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: theme.onSecondaryFixedVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        validator: validator,
        dropdownBuilder: (context, selectedItem) {
          // Custom display for selected item
          return Text(
            selectedItem ?? 'Select $label',
            style: TextStyle(
              color: selectedItem == null ? Colors.grey : Colors.black,
            ),
          );
        },
      );
    });
  }
}
