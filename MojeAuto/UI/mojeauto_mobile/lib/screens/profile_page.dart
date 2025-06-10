import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/helpers/token_manager.dart';
import 'package:mojeauto_mobile/common/form_fields.dart';
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();

  List<dynamic> _countries = [];
  String? _selectedCountryId;
  String? _birthDateIso;
  File? _selectedImage;
  String? _existingImageBase64;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _fetchUserData();
  }

  Future<void> _fetchCountries() async {
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/countries"),
      headers: {'accept': 'text/plain'},
    );
    if (response.statusCode == 200) {
      setState(() => _countries = jsonDecode(response.body));
    }
  }

  Future<void> _fetchUserData() async {
    final userId = await TokenManager().userId;
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/users?id=$userId"),
    );
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      setState(() {
        _firstNameController.text = user['firstName'] ?? '';
        _lastNameController.text = user['lastName'] ?? '';
        _emailController.text = user['email'] ?? '';
        _addressController.text = user['address'] ?? '';
        _phoneController.text = user['phoneNumber'] ?? '';
        _selectedCountryId = user['countryId'].toString();
        _existingImageBase64 = user['imageData'];
        final parsedDate = DateTime.parse(user['birthDate']).toLocal();
        _birthDateIso = parsedDate.toIso8601String();
        _birthDateController.text = DateFormat('dd.MM.yyyy').format(parsedDate);
      });
    }
  }

  Future<void> _updateUser() async {
    final userId = await TokenManager().userId;
    final uri = Uri.parse("${EnvConfig.baseUrl}/users/$userId");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['address'] = _addressController.text.trim();
    request.fields['birthDate'] = _birthDateIso!;
    request.fields['countryId'] = _selectedCountryId!;
    request.fields['password'] = _passwordController.text.trim();

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 204) {
      NotificationHelper.success(context, "Profil ažuriran.");
    } else {
      NotificationHelper.error(context, "Greška pri ažuriranju profila.");
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
    final bgColor = const Color(0xFF181A1C);
    final fieldFillColor = const Color(0xFF2A2D31);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: bgColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _existingImageBase64 != null
                        ? MemoryImage(base64Decode(_existingImageBase64!))
                        : null,
                    backgroundColor: Colors.grey[800],
                    child:
                        _selectedImage == null && _existingImageBase64 == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white70,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Unesite ime';
                    if (trimmed.length < 3) {
                      return 'Ime mora imati najmanje 3 slova';
                    }
                    if (trimmed.length > 50) {
                      return 'Ime ne smije biti duže od 50 karaktera';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Ime',
                    hintText: 'Ime',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldFillColor,
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Unesite prezime';
                    if (trimmed.length < 3) {
                      return 'Prezime mora imati najmanje 3 slova';
                    }
                    if (trimmed.length > 50) {
                      return 'Prezime ne smije biti duže od 50 karaktera';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Prezime',
                    hintText: 'Prezime',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldFillColor,
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
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
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldFillColor,
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                buildDropdownField<String>(
                  value: _selectedCountryId,
                  items: _countries
                      .map((c) => c['countryId'].toString())
                      .toList(),
                  label: 'Država',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Odaberite državu' : null,
                  onChanged: (val) => setState(() => _selectedCountryId = val),
                  itemLabel: (val) => _countries.firstWhere(
                    (c) => c['countryId'].toString() == val,
                  )['name'],
                  itemValue: (val) => val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite adresu';
                    }
                    if (value.length < 3 || value.length > 100) {
                      return 'Adresa mora imati između 3 i 100 karaktera';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Adresa',
                    hintText: 'Adresa',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldFillColor,
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final phoneRegex = RegExp(r'^\d{3,20}$');
                    if (value == null || value.isEmpty) {
                      return 'Unesite broj telefona';
                    }
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Broj mora sadržavati 3-20 cifara';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Broj telefona',
                    hintText: 'Broj telefona',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldFillColor,
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                buildDatePickerField(
                  context: context,
                  controller: _birthDateController,
                  label: "Datum rođenja",
                  validator: (value) => value == null || value.isEmpty
                      ? 'Unesite datum rođenja'
                      : null,
                  onPicked: (iso) => _birthDateIso = iso,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nova lozinka (opcionalno)',
                    hintText: 'Nova lozinka (opcionalno)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: fieldFillColor,
                    border: border,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 3 || value.length > 50) {
                        return 'Lozinka mora imati između 3 i 50 karaktera';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D5EFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateUser();
                      }
                    },
                    child: const Text(
                      "Ažuriraj",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
