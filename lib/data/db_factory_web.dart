import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

bool _configurado = false;

/// Navegador: usa o SQLite compilado para WebAssembly (dados no IndexedDB).
void configurarFabricaBanco() {
  if (_configurado) return;
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
  _configurado = true;
}
