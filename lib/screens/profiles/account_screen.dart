import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Variabel penampung data
  String _username = "Loading...";
  String _email = "Loading...";
  String _phoneNumber = "-"; // Default jika tidak ada di DB
  String _password = "••••••••"; // Default masked

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountData();
  }

  // --- FUNGSI AMBIL DATA SUPABASE ---
  Future<void> _fetchAccountData() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null) {
        final userEmail = session.user.email;

        // Query ke tabel 'akun' (sesuaikan nama tabel Anda)
        final data = await supabase
            .from('akun')
            .select()
            .eq('email', userEmail!)
            .single(); // Ambil 1 baris

        if (mounted) {
          setState(() {
            _username = data['username'] ?? "User";
            _email = data['email'] ?? userEmail;
            
            // Catatan: Pastikan kolom 'phone_number' ada di tabel 'akun' atau 'userdetails'.
            // Jika belum ada, ini akan menggunakan default value.
            _phoneNumber = data['phone_number'] ?? "+62 812 3456 7890"; 
            
            // Untuk password, biasanya tidak ditampilkan plain text.
            // Kita simpan panjangnya saja atau string dummy.
            // Jika ingin menampilkan asli (TIDAK DISARANKAN SECARA KEAMANAN):
            // _password = data['password'] ?? "••••••••"; 
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading account data: $e");
      if (mounted) {
        setState(() {
          _username = "Error";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          const _AccountHeader(),

          // 2. KONTEN (SCROLLABLE)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- PROFILE PICTURE SECTION ---
                        Center(
                          child: Column(
                            children: [
                              // Lingkaran Avatar Besar
                              Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF2C3E50), // Warna Navy Gelap
                                ),
                                child: ClipOval(
                                  child: Transform.translate(
                                    offset: const Offset(0, 10), // Geser gambar sedikit ke bawah
                                    child: Image.asset(
                                      'assets/icons/Monster Hijau Profile.png', // Pastikan aset ini ada
                                      fit: BoxFit.contain,
                                      width: 100,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Nama Besar
                              Text(
                                _username,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Email Kecil
                              Text(
                                _email,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- FORM FIELDS (READ ONLY) ---
                        
                        _buildAccountField(
                          label: "Username",
                          value: _username,
                        ),
                        
                        _buildAccountField(
                          label: "Email",
                          value: _email,
                        ),
                        
                        _buildAccountField(
                          label: "Phone Number",
                          value: _phoneNumber,
                        ),
                        
                        _buildAccountField(
                          label: "Password",
                          value: "********", // Selalu mask password untuk keamanan UI
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: FIELD ITEM ---
  Widget _buildAccountField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold, // Bold Label
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFF2C3E50), // Warna teks isi agak gelap
            ),
          ),
          const SizedBox(height: 8),
          // Garis Bawah (Divider)
          const Divider(
            color: Colors.grey, 
            thickness: 0.5,
            height: 1,
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// HEADER ACCOUNT (SAMA SEPERTI SCREEN LAIN)
// ==========================================================
class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFFD6E6F2), // Background biru muda
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
                 Navigator.pushReplacementNamed(context, '/settings'); 
               }
             },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 15),
          const Text(
            "Account",
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