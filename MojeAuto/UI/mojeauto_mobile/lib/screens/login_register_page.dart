import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/common/form_fields.dart';
import 'package:mojeauto_mobile/helpers/error_extractor.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';
import 'package:mojeauto_mobile/layout/main_page.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _birthDateIso;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();

  List<dynamic> _countries = [];
  String? _selectedCountryId;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
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

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse("${EnvConfig.baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await TokenManager().saveTokens(
          result['token'],
          result['refreshToken'],
          result['user'],
        );
        NotificationHelper.success(context, 'Uspješna prijava');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainPage()),
        );
      } else {
        NotificationHelper.error(context, 'Pogrešan email ili lozinka.');
        _passwordController.clear();
      }
    } catch (e) {
      NotificationHelper.error(context, 'Pogrešan email ili lozinka.');
      _passwordController.clear();
    }
  }

  Future<void> _registerUser() async {
    final uri = Uri.parse("${EnvConfig.baseUrl}/users");
    final request = http.MultipartRequest('POST', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['address'] = _addressController.text.trim();
    request.fields['password'] = _passwordController.text.trim();
    request.fields['userRoleId'] = '1';

    if (_birthDateIso != null) {
      request.fields['birthDate'] = _birthDateIso!;
    }

    if (_selectedCountryId != null) {
      request.fields['countryId'] = _selectedCountryId!;
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        NotificationHelper.success(
          context,
          'Uspješno ste se registrovali, prijavite se',
        );
        _clearForm();
        setState(() => _isLogin = true);
      } else {
        final error = extractErrorMessage(
          response,
          fallback: "Greška pri registraciji, pokušajte ponovo.",
        );
        NotificationHelper.error(context, error);
        _passwordController.clear();
      }
    } catch (e) {
      NotificationHelper.error(
        context,
        'Nešto je pošlo po krivu, pokušajte ponovo',
      );
      _passwordController.clear();
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _emailController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _birthDateController.clear();
    _selectedCountryId = null;
    _birthDateIso = null;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFF181A1C);
    final fieldFillColor = const Color(0xFF2A2D31);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
                  const Icon(
                    Icons.person_pin,
                    size: 80,
                    color: Color(0xFF7D5EFF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLogin ? "Prijavi se" : "Registruj se",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (!_isLogin)
                    TextFormField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
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
                      decoration: InputDecoration(
                        labelText: 'Ime',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: fieldFillColor,
                        border: border,
                      ),
                    ),

                  if (!_isLogin) const SizedBox(height: 16),

                  if (!_isLogin)
                    TextFormField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.white),
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
                      decoration: InputDecoration(
                        labelText: 'Prezime',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: fieldFillColor,
                        border: border,
                      ),
                    ),

                  if (!_isLogin) const SizedBox(height: 16),

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
                        return 'Format emaila je: primjer@gmail.com';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: fieldFillColor,
                      border: border,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (_isLogin) return null;

                      if (value == null || value.isEmpty) {
                        return 'Unesite lozinku';
                      }
                      if (value.length < 8 || value.length > 50) {
                        return 'Lozinka mora imati između 8 i 50 znakova';
                      }
                      final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                      final hasDigit = RegExp(r'\d').hasMatch(value);
                      if (!hasLetter || !hasDigit) {
                        return 'Lozinka mora sadržavati slova i brojeve';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Lozinka',
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
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  if (!_isLogin) const SizedBox(height: 16),

                  if (!_isLogin)
                    buildDropdownField<String>(
                      value: _selectedCountryId,
                      items: _countries
                          .map((c) => c['countryId'].toString())
                          .toList(),
                      label: 'Država',
                      validator: (val) => val == null || val.isEmpty
                          ? 'Odaberite državu'
                          : null,
                      onChanged: (val) =>
                          setState(() => _selectedCountryId = val),
                      itemLabel: (val) => _countries.firstWhere(
                        (c) => c['countryId'].toString() == val,
                      )['name'],
                      itemValue: (val) => val,
                    ),
                  if (!_isLogin) const SizedBox(height: 16),

                  if (!_isLogin)
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite adresu';
                        }
                        if (value.length < 2 || value.length > 100) {
                          return 'Adresa mora imati između 2 i 100 karaktera';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Adresa',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: fieldFillColor,
                        border: border,
                      ),
                    ),

                  if (!_isLogin) const SizedBox(height: 16),

                  if (!_isLogin)
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.phone,
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
                      decoration: InputDecoration(
                        labelText: 'Broj telefona',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: fieldFillColor,
                        border: border,
                      ),
                    ),

                  if (!_isLogin) const SizedBox(height: 16),

                  if (!_isLogin)
                    buildDatePickerField(
                      context: context,
                      controller: _birthDateController,
                      label: "Datum rođenja",
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite datum rođenja';
                        }
                        return null;
                      },
                      onPicked: (isoDate) {
                        _birthDateIso = isoDate;
                      },
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
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
                          if (_isLogin) {
                            _login();
                          } else {
                            _registerUser();
                          }
                        }
                      },

                      child: Text(
                        _isLogin ? "Prijavi se" : "Registruj se",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      _formKey.currentState?.reset();
                      _emailController.clear();
                      _passwordController.clear();
                      _firstNameController.clear();
                      _lastNameController.clear();
                      _addressController.clear();
                      _phoneController.clear();
                      _birthDateController.clear();
                      _selectedCountryId = null;
                      setState(() => _isLogin = !_isLogin);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: _isLogin ? "Nemate račun? " : "Imate račun? ",
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: _isLogin ? "Registrujte se" : "Prijavite se",
                            style: const TextStyle(
                              color: Color(0xFF7D5EFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
