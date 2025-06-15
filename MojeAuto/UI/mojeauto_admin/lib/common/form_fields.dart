import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

Widget buildInputField({
  required TextEditingController controller,
  required String label,
  required String? Function(String?) validator,
  bool obscureText = false,
  Widget? suffixIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
          suffixIcon: suffixIcon,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}

Widget buildDatePickerField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String? Function(String?) validator,
  void Function(String)? onPicked,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return FormField<String>(
    validator: validator,
    initialValue: controller.text.isNotEmpty ? controller.text : null,
    builder: (FormFieldState<String> field) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: firstDate ?? DateTime(1900),
                lastDate: lastDate ?? DateTime.now(),
                builder: (context, child) =>
                    Theme(data: ThemeData.dark(), child: child!),
              );
              if (pickedDate != null) {
                final iso = pickedDate.toIso8601String();
                controller.text = DateFormat('dd.MM.yyyy').format(pickedDate);
                onPicked?.call(iso);
                field.didChange(iso);
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                  ),
                  errorText: field.errorText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    },
  );
}

Widget buildImagePickerPreview({
  required File? selectedImage,
  required String? existingBase64Image,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                selectedImage,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : existingBase64Image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(existingBase64Image),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.image_outlined, color: Colors.white38, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "Dodirnite za odabir slike",
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
    ),
  );
}

Widget buildDropdownField<T>({
  required T? value,
  required List<T> items,
  required String label,
  required String? Function(T?) validator,
  required void Function(T?) onChanged,
  required String Function(T) itemLabel,
  required T Function(T) itemValue,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DropdownSearch<T>(
        selectedItem: value != null
            ? items.firstWhere(
                (e) => itemValue(e) == value,
                orElse: () => items.first,
              )
            : null,
        items: items,
        itemAsString: itemLabel,
        validator: validator,
        onChanged: onChanged,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,
          fit: FlexFit.loose,
          constraints: const BoxConstraints(maxHeight: 300),
          searchFieldProps: TextFieldProps(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pretraga..',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
          ),
          menuProps: const MenuProps(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 3,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          itemBuilder: (context, item, isSelected) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2C2C2C) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              itemLabel(item),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem != null ? itemLabel(selectedItem) : '',
            style: const TextStyle(color: Colors.white),
          );
        },
      ),
    ],
  );
}
