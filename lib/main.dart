import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: MenuPage()),
);

// ============================================
// MENÚ PRINCIPAL
// ============================================
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Práctica 05 - Menú'), centerTitle: true),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UsuariosPage()),
            ),
            icon: const Icon(Icons.people),
            label: const Text('Usuarios (Ejemplo Guiado)'),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostsPage()),
            ),
            icon: const Icon(Icons.article),
            label: const Text('Posts (Ejercicio Evaluable)'),
          ),
        ],
      ),
    ),
  );
}

// ============================================
// MODELO: Usuario (Ejemplo Guiado)
// ============================================
class Usuario {
  final int id;
  final String nombre;
  final String correo;

  Usuario({required this.id, required this.nombre, required this.correo});

  factory Usuario.fromJson(Map<String, dynamic> j) =>
      Usuario(id: j['id'], nombre: j['name'], correo: j['email']);
}

// ============================================
// MODELO: Post (Ejercicio Evaluable)
// ============================================
class Post {
  final int id;
  final String titulo;
  final String cuerpo;

  Post({required this.id, required this.titulo, required this.cuerpo});

  factory Post.fromJson(Map<String, dynamic> j) =>
      Post(id: j['id'], titulo: j['title'], cuerpo: j['body']);
}

// ============================================
// PANTALLA: UsuariosPage (Ejemplo Guiado)
// ============================================
class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List<Usuario>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = cargar();
  }

  Future<List<Usuario>> cargar() async {
    final r = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );
    if (r.statusCode != 200) {
      throw Exception('HTTP ${r.statusCode}');
    }
    final data = jsonDecode(r.body) as List;
    return data.map((e) => Usuario.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Usuarios')),
    body: FutureBuilder<List<Usuario>>(
      future: futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final usuarios = snapshot.data ?? [];
        return ListView.builder(
          itemCount: usuarios.length,
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(child: Text('${usuarios[i].id}')),
            title: Text(usuarios[i].nombre),
            subtitle: Text(usuarios[i].correo),
          ),
        );
      },
    ),
  );
}

// ============================================
// PANTALLA: PostsPage (Ejercicio Evaluable)
// ============================================
class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late Future<List<Post>> futuro;

  @override
  void initState() {
    super.initState();
    futuro = cargar();
  }

  // 1. Consumo de API y validación de status (HTTP)
  Future<List<Post>> cargar() async {
    final r = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    // Validación de status
    if (r.statusCode != 200) {
      throw Exception('Error HTTP: ${r.statusCode}');
    }

    // Conversión JSON a objetos Dart
    final data = jsonDecode(r.body) as List;
    return data.map((e) => Post.fromJson(e)).toList();
  }

  // 2. Actualización mediante RefreshIndicator
  Future<void> _refrescar() async {
    setState(() => futuro = cargar());
    await futuro;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Publicaciones'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() => futuro = cargar()),
        ),
      ],
    ),
    body: FutureBuilder<List<Post>>(
      future: futuro,
      builder: (context, snapshot) {
        // 3. Estado de Carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 4. Manejo de Error
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(() => futuro = cargar()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // 5. Lista Vacía
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No hay publicaciones disponibles'));
        }

        // 6. Estado de Éxito (Lista y RefreshIndicator)
        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(child: Text('${posts[i].id}')),
                title: Text(
                  posts[i].titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  posts[i].cuerpo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                // 7. Navegación a pantalla de detalle
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallePostPage(post: posts[i]),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ============================================
// PANTALLA: DetallePostPage (Ejercicio Evaluable)
// ============================================
class DetallePostPage extends StatelessWidget {
  final Post post;

  const DetallePostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalle de Publicación')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            child: Text('${post.id}', style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          Text(
            post.titulo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(post.cuerpo, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
