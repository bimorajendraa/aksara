import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WAJIB: Untuk fitur Copy Clipboard

class SupportContactScreen extends StatelessWidget {
  const SupportContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _SupportHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: const [
                  // 1. KARTU EMAIL
                  _DropdownCard(
                    title: "Our Email",
                    contentValue: "aksara@support.com",
                    iconData: Icons.email_outlined,
                    buttonText: "Kirim Email",
                    btnColor: Color(0xFF2C3E50),
                    isEmail: true,
                  ),
                  
                  SizedBox(height: 15),
                  
                  // 2. KARTU TELEPON
                  _DropdownCard(
                    title: "Our Phone Number",
                    contentValue: "+62 123 456 789",
                    iconData: Icons.phone,
                    buttonText: "Hubungi",
                    btnColor: Color(0xFF1E8449), // Hijau
                    isEmail: false,
                  ),
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
// WIDGET REUSABLE: DROPDOWN CARD (EMAIL & PHONE)
// ==========================================================
class _DropdownCard extends StatefulWidget {
  final String title;
  final String contentValue;
  final IconData iconData;
  final String buttonText;
  final Color btnColor;
  final bool isEmail;

  const _DropdownCard({
    required this.title,
    required this.contentValue,
    required this.iconData,
    required this.buttonText,
    required this.btnColor,
    required this.isEmail,
  });

  @override
  State<_DropdownCard> createState() => _DropdownCardState();
}

class _DropdownCardState extends State<_DropdownCard> {
  bool _isExpanded = false;

  // Fungsi Copy Clipboard
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.contentValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text("${widget.title} disalin!"),
          ],
        ),
        backgroundColor: const Color(0xFF2C3E50),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge, 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- HEADER (JUDUL) ---
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              // Efek klik transparan
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF455A64),
                      ),
                    ),
                    // Animasi Icon Putar
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- ISI KONTEN (ANIMATED) ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn, 
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 15),

                        // AREA COPYABLE (BOX DIHAPUS, TINGGAL TEKS & ICON)
                        GestureDetector(
                          onTap: () => _copyToClipboard(context),
                          // Container dihapus decoration-nya agar tidak ada kotak
                          child: Container(
                            color: Colors.transparent, // Agar area klik tetap luas
                            padding: const EdgeInsets.symmetric(vertical: 5), // Padding sedikit agar mudah diklik
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.iconData, color: Colors.black87, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  widget.contentValue,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Icon Copy Kecil
                                const Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // TOMBOL AKSI
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.isEmail) {
                                print("Action: Kirim Email");
                              } else {
                                print("Action: Telepon");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.btnColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              widget.buttonText,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity), 
          ),
        ],
      ),
    );
  }
}

// --- HEADER (SAMA SEPERTI SEBELUMNYA) ---
class _SupportHeader extends StatelessWidget {
  const _SupportHeader();

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
                 Navigator.pushReplacementNamed(context, '/help'); 
               }
             },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 15),
          const Text(
            "Support Contact",
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