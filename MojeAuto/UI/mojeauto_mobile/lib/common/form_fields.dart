import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';

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
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2D31),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                  ),
                  errorText: field.errorText,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
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
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
            filled: true,
            fillColor: Color(0xFF2A2D31),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Pretraga..',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              filled: true,
              fillColor: Color(0xFF2A2D31),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          menuProps: const MenuProps(
            backgroundColor: Color(0xFF2A2D31),
            elevation: 3,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          itemBuilder: (context, item, isSelected) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3A3D40) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              itemLabel(item),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem != null ? itemLabel(selectedItem) : '',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          );
        },
      ),
    ],
  );
}
