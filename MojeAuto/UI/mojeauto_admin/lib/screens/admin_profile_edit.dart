import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';
import 'package:mojeauto_admin/helpers/token_manager.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mojeauto_admin/env_config.dart';

class AdminProfileEditPage extends StatefulWidget {
  const AdminProfileEditPage({super.key});

  @override
  State<AdminProfileEditPage> createState() => _AdminProfileEditPageState();
}

class _AdminProfileEditPageState extends State<AdminProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  int? _selectedCountryId;
  File? _selectedImage;
  String? _existingImageBase64;
  String? _birthDateIso;
  List<dynamic> _countries = [];
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _fetchAdminUser();
  }

  Future<void> _fetchCountries() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/countries"),
      headers: {'accept': 'text/plain'},
    );
    if (response.statusCode == 200) {
      setState(() => _countries = jsonDecode(response.body));
    }
  }

  Future<void> _fetchAdminUser() async {
    final userId = await TokenManager().userId;
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/users?id=$userId"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      setState(() {
        _firstNameController.text = user['firstName'];
        _lastNameController.text = user['lastName'];
        _emailController.text = user['email'];
        _addressController.text = user['address'];
        _phoneController.text = user['phoneNumber'];
        _birthDateController.text = DateFormat(
          'dd.MM.yyyy',
        ).format(DateTime.parse(user['birthDate']).toLocal());
        _birthDateIso = DateTime.parse(user['birthDate']).toIso8601String();
        _selectedCountryId = user['countryId'];
        _existingImageBase64 = user['imageData'];
      });
    }
  }

  Future<void> _updateAdminUser() async {
    final userId = await TokenManager().userId;
    final uri = Uri.parse("${EnvConfig.baseUrl}/users/$userId");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['address'] = _addressController.text.trim();
    request.fields['birthDate'] = _birthDateIso!;
    request.fields['countryId'] = _selectedCountryId.toString();
    if (_passwordController.text.trim().isNotEmpty) {
      request.fields['password'] = _passwordController.text.trim();
    }

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil uspješno ažuriran."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final error = extractErrorMessage(
        response,
        fallback: "Greška pri ažuriranju profila.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Uredi administratorski profil",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _firstNameController,
                    label: "Ime",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unesite ime';
                      }
                      final trimmed = value.trim();
                      if (trimmed.length < 2 || trimmed.length > 50) {
                        return 'Ime mora imati između 2 i 50 karaktera';
                      }
                      final nameRegex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ]+$');
                      if (!nameRegex.hasMatch(trimmed)) {
                        return 'Ime smije sadržavati samo slova bez razmaka';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _lastNameController,
                    label: "Prezime",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unesite prezime';
                      }
                      final trimmed = value.trim();
                      if (trimmed.length < 2 || trimmed.length > 50) {
                        return 'Prezime mora imati između 2 i 50 karaktera';
                      }
                      final nameRegex = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ]+$');
                      if (!nameRegex.hasMatch(trimmed)) {
                        return 'Prezime smije sadržavati samo slova bez razmaka';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _emailController,
                    label: "Email",
                    validator: (value) {
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (value == null || value.isEmpty) {
                        return 'Unesite email';
                      }
                      if (!emailRegex.hasMatch(value)) {
                        return 'Neispravan email format';
                      }
                      return null;
                    },
                  ),
                  buildDropdownField<dynamic>(
                    value: _countries.firstWhere(
                      (c) => c['countryId'] == _selectedCountryId,
                      orElse: () => null,
                    ),
                    items: _countries,
                    label: "Država",
                    validator: (v) => v == null ? 'Odaberite državu' : null,
                    onChanged: (val) => setState(() {
                      _selectedCountryId = val?['countryId'];
                    }),
                    itemLabel: (c) => c['name'],
                    itemValue: (c) => c,
                  ),
                  const SizedBox(height: 12),
                  buildInputField(
                    controller: _addressController,
                    label: "Adresa",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite adresu';
                      }
                      if (value.length < 2 || value.length > 100) {
                        return 'Adresa mora imati između 2 i 100 karaktera';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _phoneController,
                    label: "Broj mobitela",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite broj mobitela';
                      }
                      final numericRegex = RegExp(r'^\d+$');
                      if (!numericRegex.hasMatch(value)) {
                        return 'Broj smije sadržavati samo brojeve';
                      }
                      if (value.length < 6 || value.length > 15) {
                        return 'Broj mora imati između 6 i 15 cifara';
                      }
                      return null;
                    },
                  ),
                  buildDatePickerField(
                    context: context,
                    controller: _birthDateController,
                    label: "Datum rođenja",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite datum rođenja';
                      }
                      return null;
                    },

                    onPicked: (iso) => _birthDateIso = iso,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ),
                  const SizedBox(height: 20),
                  buildInputField(
                    controller: _passwordController,
                    label: "Nova lozinka (opcionalno)",
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.length < 8 || value.length > 50) {
                          return 'Lozinka mora imati između 8 i 50 znakova';
                        }
                        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                        final hasDigit = RegExp(r'\d').hasMatch(value);
                        if (!hasLetter || !hasDigit) {
                          return 'Lozinka mora sadržavati slova i brojeve';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _updateAdminUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Spremi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  const Text(
                    "Profilna slika",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  buildImagePickerPreview(
                    selectedImage: _selectedImage,
                    existingBase64Image: _existingImageBase64,
                    onTap: _pickImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
