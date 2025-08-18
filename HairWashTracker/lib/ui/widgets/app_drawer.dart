import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../pages/stats_page.dart';
import 'confirmation_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Hair Wash Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Estadísticas'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Importar Datos'),
            onTap: () => _handleImport(context),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Exportar Datos'),
            onTap: () => _handleExport(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Borrar Todos los Datos', style: TextStyle(color: Colors.red)),
            onTap: () => _handleClearData(context),
          ),
        ],
      ),
    );
  }

  void _handleImport(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      await Provider.of<AppController>(context, listen: false).importData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos importados exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
  }

  void _handleExport(BuildContext context) async {
    Navigator.of(context).pop();
    try {
      await Provider.of<AppController>(context, listen: false).exportData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos exportados exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  void _handleClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Confirmar',
          content: '¿Estás seguro de que quieres borrar todos los datos?',
          onConfirm: () async {
            Navigator.of(context).pop();
            try {
              await Provider.of<AppController>(context, listen: false).clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todos los datos han sido borrados')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al borrar datos: $e')),
                );
              }
            }
          },
        );
      },
    );
  }
}
