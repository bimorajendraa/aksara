import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryModeScreen extends StatefulWidget {
  const StoryModeScreen({super.key});

  @override
  State<StoryModeScreen> createState() => _StoryModeScreenState();
}

class _StoryModeScreenState extends State<StoryModeScreen> {
  List<dynamic> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await Supabase.instance.client
          .from('book')
          .select('*')
          .order('id_book', ascending: true);

      setState(() {
        books = response;
        isLoading = false;
      });
    } catch (e) {
      print("Error Supabase fetchBooks(): $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 30),
                  ),
                  const Spacer(),
                  const Text(
                    "Story Mode",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (!isLoading)
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 280,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/story-detail',
                            arguments: {
                              'id_book': book['id_book'],
                              'book': book,
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F4156),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.network(
                                  book['cover_book'],
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "(${book['pages']} Pages)",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white30,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            book['difficulty'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 18,
                                        ),
                                        Text(
                                          book['rating'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
