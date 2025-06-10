import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';
import 'package:intl/intl.dart';
import 'package:mojeauto_admin/helpers/token_manager.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingUserId;
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String? _existingImageBase64;
  List<dynamic> _countries = [];
  int? _selectedCountryId;
  String? _birthDateIso;
  List<dynamic> _userRoles = [];
  int? _selectedRoleId;
  int? _currentUserId;

  final TextEditingController _searchController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserId();
    _fetchUsers();
    _fetchCountries();
    _fetchUserRoles();
  }

  Future<void> _initUserId() async {
    final id = await TokenManager().userId;
    setState(() => _currentUserId = id);
  }

  Future<void> _fetchUserRoles() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/user-roles"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _userRoles = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchCountries() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/countries"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _countries = jsonDecode(response.body);
      });
    }
  }

  Future<void> _addUser() async {
    final uri = Uri.parse("${EnvConfig.baseUrl}/users");
    final request = http.MultipartRequest('POST', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['address'] = _addressController.text.trim();
    request.fields['password'] = _passwordController.text.trim();

    if (_selectedRoleId != null) {
      request.fields['userRoleId'] = _selectedRoleId.toString();
    }

    if (_birthDateIso != null) {
      request.fields['birthDate'] = _birthDateIso!;
    }

    if (_selectedCountryId != null) {
      request.fields['countryId'] = _selectedCountryId.toString();
    }

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Korisnik uspješno dodan."),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
      _fetchUsers();
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri dodavanju korisnika.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      users = [];
    });

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };

    if (searchQuery.length >= 2) {
      queryParams['FirstName'] = searchQuery;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${EnvConfig.baseUrl}/users",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      hasNextPage = result.length == pageSize + 1;
      final trimmed = hasNextPage ? result.take(pageSize).toList() : result;

      setState(() {
        users = trimmed.where((u) => u['userId'] != _currentUserId).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        users = [];
        isLoading = false;
      });
    }
  }

  Future<void> _deleteUser(BuildContext context, int userId) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/users/$userId"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Korisnik je uspješno obrisan."),
          backgroundColor: Colors.green,
        ),
      );
      _fetchUsers();
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška prilikom brisanja korisnika.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateUser(int id) async {
    final uri = Uri.parse("${EnvConfig.baseUrl}/users/$id");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['address'] = _addressController.text.trim();

    if (_selectedRoleId != null) {
      request.fields['userRoleId'] = _selectedRoleId.toString();
    }

    if (_birthDateIso != null) {
      request.fields['birthDate'] = _birthDateIso!;
    }

    if (_selectedCountryId != null) {
      request.fields['countryId'] = _selectedCountryId.toString();
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
          content: Text("Korisnik je uspješno ažuriran."),
          backgroundColor: Colors.green,
        ),
      );
      editingUserId = null;
      _clearForm();
      _fetchUsers();
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška prilikom ažuriranja korisnika.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _birthDateController.clear();
    _addressController.clear();
    _selectedCountryId = null;
    _existingImageBase64 = null;
    _selectedImage = null;
    _selectedRoleId = null;
    showForm = false;
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchUsers();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchUsers();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showForm) {
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
                    Text(
                      editingUserId != null
                          ? "Uređivanje korisnika"
                          : "Dodavanje korisnika",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildInputField(
                      controller: _firstNameController,
                      label: "Ime",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite ime';
                        }
                        if (value.length < 2 || value.length > 50) {
                          return 'Ime mora imati između 2 i 50 znakova';
                        }
                        return null;
                      },
                    ),
                    buildInputField(
                      controller: _lastNameController,
                      label: "Prezime",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite prezime';
                        }
                        if (value.length < 2 || value.length > 50) {
                          return 'Prezime mora imati između 2 i 50 znakova';
                        }
                        return null;
                      },
                    ),
                    buildInputField(
                      controller: _emailController,
                      label: "E-mail",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite e-mail';
                        }

                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Unesite ispravan e-mail, npr. nedim@gmail.com';
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
                      validator: (value) =>
                          value == null ? 'Odaberite državu' : null,
                      onChanged: (value) => setState(
                        () => _selectedCountryId = value?['countryId'],
                      ),
                      itemLabel: (c) => c['name'],
                      itemValue: (c) => c,
                    ),

                    const SizedBox(height: 12),
                    buildInputField(
                      controller: _addressController,
                      label: "Unesite adresu",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Unesite prezime';
                        }
                        if (value.length < 2 || value.length > 50) {
                          return 'Prezime mora imati između 2 i 100 znakova';
                        }
                        return null;
                      },
                    ),
                    buildInputField(
                      controller: _phoneController,
                      label: "Unesite broj mobitela",
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
                    if (editingUserId == null)
                      buildInputField(
                        controller: _passwordController,
                        label: "Lozinka",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Unesite lozinku';
                          }
                          if (value.length < 3 || value.length > 100) {
                            return 'Lozinka mora imati između 3 i 50 znakova';
                          }
                          return null;
                        },
                      ),
                    buildDropdownField<dynamic>(
                      value: _userRoles.firstWhere(
                        (r) => r['userRoleId'] == _selectedRoleId,
                        orElse: () => null,
                      ),
                      items: _userRoles,
                      label: "Uloga",
                      validator: (value) =>
                          value == null ? 'Odaberite ulogu' : null,
                      onChanged: (value) => setState(
                        () => _selectedRoleId = value?['userRoleId'],
                      ),
                      itemLabel: (r) => r['name'],
                      itemValue: (r) => r,
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (editingUserId != null) {
                                _updateUser(editingUserId!);
                              } else {
                                _addUser();
                              }
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            editingUserId != null ? "Uredi" : "Dodaj",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            _clearForm();
                            setState(() {
                              editingUserId = null;
                            });
                          },

                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text("Nazad"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Slika korisnika",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Korisnici",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _existingImageBase64 = null;
                  _selectedImage = null;
                  showForm = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Dodaj korisnika",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (_) => _onSearchChanged(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Pretraži po imenu ili prezimenu..',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.isNotEmpty
                        ? "Nijedan korisnik ne odgovara unesenom pojmu."
                        : "Nema dostupnih korisnika.",
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          user['imageData'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(user['imageData']),
                                    width: 70,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${user['firstName']} ${user['lastName']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Datum rođenja: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(user['birthDate']).toLocal())} • Broj mobitela: ${user['phoneNumber']} • Adresa: ${user['address']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: const Color(0xFF0F131A),
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color.fromARGB(141, 255, 255, 255),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                setState(() {
                                  editingUserId = user['userId'];
                                  _firstNameController.text = user['firstName'];
                                  _lastNameController.text = user['lastName'];
                                  _emailController.text = user['email'];
                                  _addressController.text = user['address'];
                                  _phoneController.text = user['phoneNumber'];
                                  _birthDateController
                                      .text = DateFormat('dd.MM.yyyy').format(
                                    DateTime.parse(user['birthDate']).toLocal(),
                                  );
                                  _existingImageBase64 = user['imageData'];
                                  _selectedCountryId = user['countryId'];
                                  _selectedRoleId = user['userRoleId'];
                                  _selectedImage = null;
                                  showForm = true;
                                });
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF1E1E1E),
                                      title: const Text(
                                        "Potvrda brisanja",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                        "Jeste li sigurni da želite obrisati korisnika \"${user['firstName']} ${user['lastName']}\"?",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2A2A2A,
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Poništi"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF3B82F6,
                                            ),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text("Da"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteUser(
                                              context,
                                              user['userId'],
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  'Uredi',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Obriši',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        PaginationControls(
          currentPage: currentPage,
          hasNextPage: hasNextPage,
          onPrevious: _goToPreviousPage,
          onNext: _goToNextPage,
        ),
      ],
    );
  }
}
