import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Pastikan SVG package aktif

class DifficultiesScreen extends StatefulWidget {
  const DifficultiesScreen({super.key});

  @override
  State<DifficultiesScreen> createState() => _DifficultiesScreenState();
}

class _DifficultiesScreenState extends State<DifficultiesScreen> {
  String? _selectedCategory;
  final List<String> _categories = [
    "Technical Issue",
    "Account Problem",
    "Content Error",
    "Other"
  ];

  final TextEditingController _descController = TextEditingController();

  // --- RESET FORM SETELAH SUKSES ---
  void _resetForm() {
    setState(() {
      _selectedCategory = null;
      _descController.clear();
    });
  }

  // --- FUNGSI MEMUNCULKAN POPUP ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Pass fungsi reset ke dialog
        return DifficultiesSuccessDialog(onClose: _resetForm);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _DifficultiesHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- DROPDOWN CATEGORY ---
                  const Text(
                    "Category Difficulties",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Container Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Rounding sama
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text(
                          "Choose Category...",
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        dropdownColor: Colors.white, // Pastikan dropdown putih bersih
                        borderRadius: BorderRadius.circular(15), // Rounding Menu Dropdown
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- DESCRIPTION TEXT AREA ---
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    maxLines: 15,
                    decoration: InputDecoration(
                      hintText: "Describe Difficulties..",
                      hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white, // Pastikan background putih
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- TOMBOL KIRIM ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedCategory != null && _descController.text.isNotEmpty) {
                          _showSuccessDialog();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please fill all fields")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Kirim",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 3. WIDGET POPUP DIALOG (THANK YOU) - UPDATED
// ==========================================================
class DifficultiesSuccessDialog extends StatelessWidget {
  // Callback function untuk reset form
  final VoidCallback onClose; 

  const DifficultiesSuccessDialog({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Tutup Dialog
                  onClose(); // Reset Form
                },
                child: const Icon(Icons.close, color: Colors.grey, size: 24),
              ),
            ),
            
            const SizedBox(height: 10),

            // Image Monster
            SizedBox(
              height: 120,
              width: 120,
              child: SvgPicture.asset(
                'assets/icons/pink-monster.svg',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "THANK YOU",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            
            // Subtitle
            const Text(
              "Your report has sent to us!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 10),

            // Description
            const Text(
              "You will be redirect to homepage\nshortly, or click okay to return to\nhomepage",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // Button OKAY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // --- LOGIKA BARU: CUKUP TUTUP DIALOG ---
                  Navigator.of(context).pop(); 
                  onClose(); // Panggil fungsi reset form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8449),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "OKAY",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 4. HEADER DIFFICULTIES (TETAP SAMA)
// ==========================================================
class _DifficultiesHeader extends StatelessWidget {
  const _DifficultiesHeader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFFD6E6F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
               if (Navigator.canPop(context)) {
                 Navigator.pop(context);
               } else {
                 Navigator.pushReplacementNamed(context, '/home'); 
               }
             },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 15),
          const Text(
            "Difficulties",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}