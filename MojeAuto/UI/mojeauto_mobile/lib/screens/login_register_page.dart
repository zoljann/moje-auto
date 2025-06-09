import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool _isLogin = true;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        if (value == null || value.isEmpty) {
                          return 'Unesite ime';
                        }
                        if (value.length > 50) {
                          return 'Ime ne smije biti duže od 50 karaktera';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Ime',
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
                        if (value == null || value.isEmpty) {
                          return 'Unesite prezime';
                        }
                        if (value.length > 50) {
                          return 'Prezime ne smije biti duže od 50 karaktera';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Prezime',
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
                        return 'Neispravan email format';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Email',
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
                      if (value == null || value.isEmpty) {
                        return 'Unesite lozinku';
                      }
                      if (value.length < 6 || value.length > 50) {
                        return 'Lozinka mora imati između 6 i 50 karaktera';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Lozinka',
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
                    DropdownButtonFormField<String>(
                      value: _selectedCountryId,
                      dropdownColor: fieldFillColor,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Odaberite državu';
                        }
                        return null;
                      },
                      items: _countries.map<DropdownMenuItem<String>>((
                        country,
                      ) {
                        return DropdownMenuItem<String>(
                          value: country['countryId'].toString(),
                          child: Text(country['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCountryId = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Država',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: fieldFillColor,
                        border: border,
                      ),
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
                        if (value.length < 3 || value.length > 100) {
                          return 'Adresa mora imati između 3 i 100 karaktera';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Adresa',
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
                        final phoneRegex = RegExp(r'^\d{3,20}\$');
                        if (value == null || value.isEmpty) {
                          return 'Unesite broj telefona';
                        }
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Broj mora sadržavati 3-20 cifara';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Broj telefona',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: fieldFillColor,
                        border: border,
                      ),
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
                          // TODO: handle login or register logic
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
