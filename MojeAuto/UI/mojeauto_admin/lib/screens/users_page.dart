import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  final TextEditingController _searchController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _addUser() async {
    final uri = Uri.parse("${dotenv.env['API_BASE_URL']}/users");
    final request = http.MultipartRequest('POST', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['birthDate'] = _birthDateController.text.trim();
    request.fields['password'] = _passwordController.text.trim();

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
      setState(() => showForm = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Greška pri dodavanju korisnika: ${response.statusCode}",
          ),
          backgroundColor: Colors.red,
        ),
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
        "${dotenv.env['API_BASE_URL']}/users",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        users = result;
        hasNextPage = result.length == pageSize;
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
      Uri.parse("${dotenv.env['API_BASE_URL']}/users/$userId"),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Greška prilikom brisanja korisnika. (${response.statusCode})",
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _updateUser(int id) async {
    final uri = Uri.parse("${dotenv.env['API_BASE_URL']}/users/$id");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['firstName'] = _firstNameController.text.trim();
    request.fields['lastName'] = _lastNameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phoneNumber'] = _phoneController.text.trim();
    request.fields['birthDate'] = _birthDateController.text.trim();
    request.fields['password'] = _passwordController.text.trim();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri ažuriranju: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
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
    _passwordController.clear();
    _existingImageBase64 = null;
    _selectedImage = null;
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

  Widget _buildInputField({
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

  @override
  Widget build(BuildContext context) {
    if (showForm) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dodavanje korisnika",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
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
            _buildInputField(
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
            _buildInputField(
              controller: _emailController,
              label: "E-mail",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite e-mail';
                }

                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Unesite ispravan e-mail, npr. nedim@gmail.com';
                }

                return null;
              },
            ),
            _buildInputField(
              controller: _countryController,
              label: "Država",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite državu';
                }
                return null;
              },
            ),
            _buildInputField(
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
            _buildInputField(
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
            Text(
              "Slika korisnika",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _existingImageBase64 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(_existingImageBase64!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.image_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Dodirnite za odabir slike",
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
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
                    //ocistiti sve kontrolere
                    setState(() {
                      editingUserId = null;
                      showForm = false;
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
                                  Icons.directions_bus,
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
                                  "• Datum rođenja: ${user['birthDate']} • Adresa: ${user['address']}",
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
                                  _birthDateController.text = user['birthDate'];
                                  _existingImageBase64 = user['imageData'];
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: currentPage > 1
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Opacity(
                opacity: currentPage > 1 ? 1.0 : 0.3,
                child: ElevatedButton(
                  onPressed: currentPage > 1 ? _goToPreviousPage : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Prethodna"),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Stranica $currentPage",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            MouseRegion(
              cursor: hasNextPage
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Opacity(
                opacity: hasNextPage ? 1.0 : 0.3,
                child: ElevatedButton(
                  onPressed: hasNextPage ? _goToNextPage : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Sljedeća"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
