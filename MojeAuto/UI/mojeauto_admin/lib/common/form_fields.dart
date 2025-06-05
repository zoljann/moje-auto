import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildInputField({
  required TextEditingController controller,
  required String label,
  required String? Function(String?) validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        validator: validator,
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
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
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
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.white54),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: validator,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) =>
                Theme(data: ThemeData.dark(), child: child!),
          );
          if (pickedDate != null) {
            controller.text = DateFormat('dd.MM.yyyy').format(pickedDate);

            if (onPicked != null) {
              onPicked(pickedDate.toIso8601String());
            }
          }
        },
      ),
      const SizedBox(height: 12),
    ],
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
      DropdownButtonFormField<T>(
        value: value,
        items: items.map<DropdownMenuItem<T>>((item) {
          return DropdownMenuItem<T>(
            value: itemValue(item),
            child: Text(itemLabel(item)),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white),
      ),
    ],
  );
}
