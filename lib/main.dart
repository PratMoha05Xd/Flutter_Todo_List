import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        hintColor: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListaTareasPage(),
    );
  }
}

class Tarea {
  String nombre;
  bool completada;
  String categoria;
  int prioridad;

  Tarea(this.nombre, {this.categoria = 'General', this.completada = false, this.prioridad = 2});
}

class ListaTareasPage extends StatefulWidget {
  @override
  _ListaTareasPageState createState() => _ListaTareasPageState();
}

class _ListaTareasPageState extends State<ListaTareasPage> {
  List<Tarea> tareas = [];
  String filtroCategoria = 'Todas';

  void _agregarTarea(String nombreTarea, String categoria, int prioridad) {
    setState(() {
      tareas.add(Tarea(nombreTarea, categoria: categoria, prioridad: prioridad));
    });
  }

  void _eliminarTarea(int index) {
    setState(() {
      tareas.removeAt(index);
    });
  }

  void _borrarTodasLasTareas() {
    setState(() {
      tareas.clear();
    });
  }

  String _prioridadTexto(int prioridad) {
    switch (prioridad) {
      case 1:
        return 'Alta';
      case 2:
        return 'Media';
      default:
        return 'Baja';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Tarea> tareasFiltradas = filtroCategoria == 'Todas'
        ? tareas
        : tareas.where((tarea) => tarea.categoria == filtroCategoria).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Tareas'),
        actions: [
          _selectorCategoria(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: tareasFiltradas.isEmpty
                ? Center(child: Text('No hay tareas en esta categoría'))
                : ListView.builder(
              itemCount: tareasFiltradas.length,
              itemBuilder: (context, index) {
                Tarea tarea = tareasFiltradas[index];
                return Card(
                  color: tarea.completada ? Colors.green.shade100 : Colors.white,
                  child: ListTile(
                    title: Text(
                      tarea.nombre,
                      style: TextStyle(
                        decoration: tarea.completada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text('Categoría: ${tarea.categoria} - Prioridad: ${_prioridadTexto(tarea.prioridad)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarTarea(index),
                    ),
                    onTap: () {
                      setState(() {
                        tarea.completada = !tarea.completada;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          if (tareas.length > 3)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _borrarTodasLasTareas,
                child: Text('Borrar Todas las Tareas'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNuevaTarea(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _selectorCategoria() {
    return PopupMenuButton<String>(
      onSelected: (String valor) {
        setState(() {
          filtroCategoria = valor;
        });
      },
      itemBuilder: (BuildContext context) {
        return ['Todas', 'Personal', 'Trabajo', 'Otras']
            .map((String categoria) => PopupMenuItem<String>(
          value: categoria,
          child: Text(categoria),
        ))
            .toList();
      },
    );
  }

  void _mostrarDialogoNuevaTarea(BuildContext context) {
    String nuevaTarea = '';
    String categoria = '';
    int prioridad = 2; // Valor inicial para la prioridad

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Agregar nueva tarea'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (valor) => nuevaTarea = valor,
                    decoration: InputDecoration(hintText: 'Nombre de la tarea'),
                  ),
                  TextField(
                    onChanged: (valor) => categoria = valor,
                    decoration: InputDecoration(hintText: 'Categoría'),
                  ),
                  DropdownButton<int>(
                    value: prioridad,
                    items: [
                      DropdownMenuItem(value: 1, child: Text('Alta')),
                      DropdownMenuItem(value: 2, child: Text('Media')),
                      DropdownMenuItem(value: 3, child: Text('Baja')),
                    ],
                    onChanged: (valor) => setState(() => prioridad = valor!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('Agregar'),
                  onPressed: () {
                    if (nuevaTarea.isNotEmpty) {
                      _agregarTarea(nuevaTarea, categoria.isEmpty ? 'General' : categoria, prioridad);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
