import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ServicioVelia extends ChangeNotifier {
  ServicioVelia._();
  static final ServicioVelia instancia = ServicioVelia._();

  final FlutterLocalNotificationsPlugin _notificaciones =
      FlutterLocalNotificationsPlugin();
  SharedPreferences? _prefs;
  List<CuentaLocalVelia> _cuentas = [];
  List<CuentaLocalVelia> get cuentas => List.unmodifiable(_cuentas);
  String _grupoActivo = 'familia-demo';
  String _claveParaGrupo(String grupo, String clave) =>
      grupo == 'familia-demo' ? clave : 'grupo_${grupo}_$clave';
  String _claveDatos(String clave) => _claveParaGrupo(_grupoActivo, clave);
  bool _notificacionesActivas = false;
  bool get notificacionesActivas => _notificacionesActivas;

  Future<void> inicializar() async {
    tzdata.initializeTimeZones();
    final zona = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zona.identifier));
    _prefs = await SharedPreferences.getInstance();
    _grupoActivo = _prefs!.getString('grupo_actual') ?? 'familia-demo';
    await _cargarCuentas();
    const ajustes = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _notificaciones.initialize(settings: ajustes);
    await _cargarDatosIniciales();
    await _notificaciones.cancelAll();
    final android = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    _notificacionesActivas = await android?.areNotificationsEnabled() ?? true;
    if (!(_prefs!.getBool('permiso_solicitado') ?? false)) {
      await solicitarPermiso();
      await _prefs!.setBool('permiso_solicitado', true);
    }
    await programarAvisoDiario();
    await sincronizarAvisosCitas();
    await sincronizarAvisosMedicamentos();
  }

  Future<void> _cargarCuentas() async {
    final raw = _prefs!.getString('cuentas_velia');
    if (raw == null) {
      _cuentas = [
        CuentaLocalVelia(
            email: 'admin@velia.com',
            password: 'admin123',
            rol: 'admin',
            grupo: ''),
        CuentaLocalVelia(
            email: 'adulto@velia.com',
            password: 'adulto123',
            rol: 'cliente',
            grupo: 'familia-demo',
            codigoVinculacion: _generarCodigo(),
            nombre: 'Doña Carmen Ramírez'),
        CuentaLocalVelia(
            email: 'familiar@velia.com',
            password: 'familiar123',
            rol: 'familiar',
            grupo: 'familia-demo',
            nombre: 'Laura Ramírez',
            parentesco: 'Hija',
            adultoVinculado: 'adulto@velia.com',
            estadoVinculo: 'autorizado'),
      ];
      await _guardarCuentas();
    } else {
      _cuentas = (jsonDecode(raw) as List)
          .map(
              (item) => CuentaLocalVelia.fromJson(item as Map<String, dynamic>))
          .toList();
      var cambio = false;
      for (var i = 0; i < _cuentas.length; i++) {
        if (_cuentas[i].rol == 'cliente' &&
            _cuentas[i].codigoVinculacion == null) {
          _cuentas[i] =
              _cuentas[i].copyWith(codigoVinculacion: _generarCodigo());
          cambio = true;
        }
        final cuenta = _cuentas[i];
        final esFamiliarDePrueba =
            cuenta.rol == 'familiar' && cuenta.email == 'familiar@velia.com';
        if (esFamiliarDePrueba) {
          final indiceAdulto = _cuentas.indexWhere((posible) =>
              posible.rol == 'cliente' &&
              posible.email == 'adulto@velia.com' &&
              posible.grupo == cuenta.grupo);
          if (indiceAdulto >= 0 &&
              (cuenta.estadoVinculo != 'autorizado' ||
                  cuenta.adultoVinculado != 'adulto@velia.com')) {
            _cuentas[i] = cuenta.copyWith(
                adultoVinculado: 'adulto@velia.com',
                estadoVinculo: 'autorizado');
            cambio = true;
          }
        } else if (cuenta.rol == 'familiar' && cuenta.estadoVinculo.isEmpty) {
          CuentaLocalVelia? cliente;
          for (final posible in _cuentas) {
            if (posible.rol == 'cliente' && posible.grupo == cuenta.grupo) {
              cliente = posible;
              break;
            }
          }
          if (cliente != null &&
              cuenta.email == 'familiar@velia.com' &&
              cliente.email == 'adulto@velia.com') {
            _cuentas[i] = cuenta.copyWith(
                adultoVinculado: cliente.email,
                estadoVinculo: 'autorizado',
                nombre: cuenta.nombre.isEmpty ? 'Laura Ramírez' : cuenta.nombre,
                parentesco:
                    cuenta.parentesco.isEmpty ? 'Hija' : cuenta.parentesco);
            cambio = true;
          } else {
            _cuentas[i] = cuenta.copyWith(estadoVinculo: 'desvinculado');
            cambio = true;
          }
        }
      }
      if (cambio) await _guardarCuentas();
    }
  }

  Future<void> _guardarCuentas() async => _prefs!.setString('cuentas_velia',
      jsonEncode(_cuentas.map((cuenta) => cuenta.toJson()).toList()));

  CuentaLocalVelia? autenticarCuenta(String email, String password) {
    for (final cuenta in _cuentas) {
      if (cuenta.email == email.trim().toLowerCase() &&
          cuenta.password == password &&
          const {'admin', 'cliente', 'adulto', 'familiar'}
              .contains(cuenta.rol)) {
        return cuenta;
      }
    }
    return null;
  }

  Future<String?> crearCuenta(
      {required String email,
      required String password,
      required String rol,
      String? codigoVinculacion,
      String nombre = '',
      String fechaNacimiento = '',
      String telefonoEmergencia = '',
      String parentesco = '',
      String tipoContacto = '',
      String datoContacto = ''}) async {
    final normalizado = email.trim().toLowerCase();
    if (!normalizado.endsWith('@velia.com') ||
        normalizado.length <= '@velia.com'.length) {
      return 'El correo debe tener el formato usuario@velia.com.';
    }
    if (password.length < 6)
      return 'La contraseña debe tener al menos 6 caracteres.';
    if (rol != 'cliente' && rol != 'familiar')
      return 'Rol de cuenta no permitido.';
    if (_cuentas.any((c) => c.email == normalizado))
      return 'Ese correo ya está registrado.';
    var grupo = '';
    String? codigoCliente;
    String adultoVinculado = '';
    var estadoVinculo = 'autorizado';
    if (rol == 'cliente') {
      grupo = 'familia-$normalizado';
      codigoCliente = _generarCodigo();
    } else {
      final codigo = codigoVinculacion?.trim() ?? '';
      if (!RegExp(r'^\d{6}$').hasMatch(codigo))
        return 'Ingresa el código de vinculación de 6 dígitos.';
      CuentaLocalVelia? cliente;
      for (final existente in _cuentas) {
        if (existente.rol == 'cliente' &&
            existente.codigoVinculacion == codigo) {
          cliente = existente;
          break;
        }
      }
      if (cliente == null)
        return 'No se encontró un cliente con ese código en este dispositivo.';
      adultoVinculado = cliente.email;
      estadoVinculo = 'pendiente';
      grupo = 'pendiente-$normalizado';
      if (_cuentas
              .where((cuenta) =>
                  cuenta.rol == 'familiar' &&
                  cuenta.adultoVinculado == adultoVinculado &&
                  cuenta.estadoVinculo != 'desvinculado')
              .length >=
          2) {
        return 'Este cliente ya vinculó el máximo de dos familiares.';
      }
    }
    _cuentas.add(CuentaLocalVelia(
        email: normalizado,
        password: password,
        rol: rol,
        grupo: grupo,
        codigoVinculacion: codigoCliente,
        adultoVinculado: adultoVinculado,
        estadoVinculo: estadoVinculo,
        nombre: nombre.trim().isEmpty
            ? normalizado.split('@').first
            : nombre.trim(),
        fechaNacimiento: fechaNacimiento,
        telefonoEmergencia: telefonoEmergencia,
        parentesco: parentesco,
        tipoContacto: tipoContacto,
        datoContacto: datoContacto));
    await _guardarCuentas();
    notifyListeners();
    return null;
  }

  String? codigoParaCuenta(String email) {
    for (final cuenta in _cuentas) {
      if (cuenta.email == email.trim().toLowerCase())
        return cuenta.codigoVinculacion;
    }
    return null;
  }

  String _generarCodigo() {
    final random = Random.secure();
    String codigo;
    do {
      codigo = List.generate(6, (_) => random.nextInt(10)).join();
    } while (_cuentas.any((cuenta) => cuenta.codigoVinculacion == codigo));
    return codigo;
  }

  Future<void> activarCuenta(String email) async {
    CuentaLocalVelia? activa;
    for (final cuenta in _cuentas) {
      if (cuenta.email == email.trim().toLowerCase()) {
        activa = cuenta;
        break;
      }
    }
    if (activa == null ||
        activa.rol == 'admin' ||
        (activa.rol == 'familiar' && activa.estadoVinculo != 'autorizado'))
      return;
    _grupoActivo = activa.grupo;
    await _prefs!.setString('grupo_actual', _grupoActivo);
    await _notificaciones.cancelAll();
    await _reprogramarTodo();
    notifyListeners();
  }

  Future<void> autorizarVinculo(String emailFamiliar) async {
    final indiceFamiliar = _cuentas
        .indexWhere((c) => c.email == emailFamiliar && c.rol == 'familiar');
    if (indiceFamiliar < 0) return;
    final familiar = _cuentas[indiceFamiliar];
    CuentaLocalVelia? cliente;
    for (final posible in _cuentas) {
      if (posible.email == familiar.adultoVinculado &&
          posible.rol == 'cliente') {
        cliente = posible;
        break;
      }
    }
    if (cliente == null) return;
    _cuentas[indiceFamiliar] =
        familiar.copyWith(grupo: cliente.grupo, estadoVinculo: 'autorizado');
    await _guardarCuentas();
    notifyListeners();
  }

  Future<String?> solicitarVinculo(String emailFamiliar, String codigo) async {
    if (!RegExp(r'^\d{6}$').hasMatch(codigo.trim())) {
      return 'Ingresa un código de 6 dígitos.';
    }
    final indice = _cuentas
        .indexWhere((c) => c.email == emailFamiliar && c.rol == 'familiar');
    if (indice < 0) return 'No se encontró la cuenta familiar.';
    CuentaLocalVelia? cliente;
    for (final cuenta in _cuentas) {
      if (cuenta.rol == 'cliente' &&
          cuenta.codigoVinculacion == codigo.trim()) {
        cliente = cuenta;
        break;
      }
    }
    if (cliente == null) return 'Código no válido en este dispositivo.';
    final familiaresActivos = _cuentas
        .where((c) =>
            c.rol == 'familiar' &&
            c.adultoVinculado == cliente!.email &&
            c.email != emailFamiliar &&
            c.estadoVinculo != 'desvinculado')
        .length;
    if (familiaresActivos >= 2)
      return 'Este cliente ya vinculó dos familiares.';
    _cuentas[indice] = _cuentas[indice].copyWith(
        adultoVinculado: cliente.email,
        grupo: 'pendiente-${_cuentas[indice].email}',
        estadoVinculo: 'pendiente');
    await _guardarCuentas();
    notifyListeners();
    return null;
  }

  Future<void> desvincularFamiliar(String emailFamiliar) async {
    final indice = _cuentas
        .indexWhere((c) => c.email == emailFamiliar && c.rol == 'familiar');
    if (indice < 0) return;
    final familiar = _cuentas[indice];
    _cuentas[indice] = familiar.copyWith(
        grupo: 'pendiente-${familiar.email}', estadoVinculo: 'desvinculado');
    await _guardarCuentas();
    notifyListeners();
  }

  Future<void> guardarPerfil(
      {required String email,
      String? nombre,
      String? fechaNacimiento,
      String? telefonoEmergencia,
      String? parentesco,
      String? tipoContacto,
      String? datoContacto}) async {
    final indice = _cuentas.indexWhere((c) => c.email == email);
    if (indice < 0) return;
    _cuentas[indice] = _cuentas[indice].copyWith(
        nombre: nombre,
        fechaNacimiento: fechaNacimiento,
        telefonoEmergencia: telefonoEmergencia,
        parentesco: parentesco,
        tipoContacto: tipoContacto,
        datoContacto: datoContacto);
    await _guardarCuentas();
    if (telefonoEmergencia != null) {
      final cuenta = _cuentas[indice];
      await _prefs!.setString(
          _claveParaGrupo(cuenta.grupo, 'telefonos_emergencia'),
          telefonoEmergencia);
    }
    notifyListeners();
  }

  Future<void> eliminarCuenta(CuentaLocalVelia cuenta) async {
    if (cuenta.rol == 'admin') return;
    _cuentas.removeWhere((c) => c.email == cuenta.email);
    await _guardarCuentas();
    notifyListeners();
  }

  Future<void> registrarUsoCuenta(String email) async {
    final indice = _cuentas.indexWhere((c) => c.email == email);
    if (indice < 0) return;
    final cuenta = _cuentas[indice];
    _cuentas[indice] = cuenta.copyWith(
      usos: cuenta.usos + 1,
      ultimaActividad: DateTime.now().toIso8601String(),
      activa: true,
    );
    await _guardarCuentas();
    notifyListeners();
  }

  Future<void> registrarSalidaCuenta(String email) async {
    final indice = _cuentas.indexWhere((c) => c.email == email);
    if (indice < 0) return;
    _cuentas[indice] = _cuentas[indice].copyWith(activa: false);
    await _guardarCuentas();
    notifyListeners();
  }

  Future<void> solicitarPermiso() async {
    final android = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    _notificacionesActivas = await android?.areNotificationsEnabled() ?? true;
    notifyListeners();
    if (_notificacionesActivas) await _reprogramarTodo();
  }

  Future<void> actualizarEstadoNotificaciones() async {
    final android = _notificaciones.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    _notificacionesActivas = await android?.areNotificationsEnabled() ?? true;
    notifyListeners();
    if (_notificacionesActivas) await _reprogramarTodo();
  }

  Future<void> _reprogramarTodo() async {
    await programarAvisoDiario();
    await sincronizarAvisosCitas();
    await sincronizarAvisosMedicamentos();
  }

  String get horaAviso =>
      _prefs?.getString(_claveDatos('hora_aviso')) ?? '08:00';
  int get racha => _prefs?.getInt(_claveDatos('racha')) ?? 0;
  String? get ultimoAviso =>
      _prefs?.getString(_claveDatos('ultimo_aviso_fecha'));
  bool get avisoCumplidoHoy => ultimoAviso == fechaClave(DateTime.now());
  List<String> get telefonosEmergencia =>
      (_prefs?.getString(_claveDatos('telefonos_emergencia')) ?? '')
          .split(RegExp(r'[,;\n]'))
          .map((numero) => numero.trim())
          .where((numero) => numero.isNotEmpty)
          .toList();
  double get escalaTexto => _prefs?.getDouble('escala_texto') ?? 1.0;
  bool get altoContraste => _prefs?.getBool('alto_contraste') ?? false;

  Future<void> guardarTelefonosEmergencia(String telefonos) async {
    await _prefs!
        .setString(_claveDatos('telefonos_emergencia'), telefonos.trim());
    notifyListeners();
  }

  Future<void> guardarAccesibilidad({double? escala, bool? contraste}) async {
    if (escala != null) await _prefs!.setDouble('escala_texto', escala);
    if (contraste != null) await _prefs!.setBool('alto_contraste', contraste);
    notifyListeners();
  }

  Future<void> guardarHoraAviso(int hora, int minuto) async {
    await _prefs!.setString(_claveDatos('hora_aviso'),
        '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}');
    await programarAvisoDiario();
    notifyListeners();
  }

  Future<void> programarAvisoDiario() async {
    final partes = horaAviso.split(':').map(int.parse).toList();
    final ahora = tz.TZDateTime.now(tz.local);
    var cuando = tz.TZDateTime(
        tz.local, ahora.year, ahora.month, ahora.day, partes[0], partes[1]);
    if (!cuando.isAfter(ahora)) cuando = cuando.add(const Duration(days: 1));
    await _notificaciones.zonedSchedule(
      id: 1,
      title: '¿Cómo te sientes hoy?',
      body: 'Toca “Estoy bien” para completar tu aviso diario.',
      scheduledDate: cuando,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'aviso_diario',
          'Aviso diario',
          channelDescription: 'Recordatorio diario de bienestar',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<bool> registrarEstoyBien() async {
    final hoy = DateTime.now();
    final partes = horaAviso.split(':').map(int.parse).toList();
    if (hoy.isBefore(
            DateTime(hoy.year, hoy.month, hoy.day, partes[0], partes[1])) ||
        avisoCumplidoHoy) {
      return false;
    }
    final nuevaRacha = siguienteRacha(racha, ultimoAviso, hoy);
    await _prefs!.setInt(_claveDatos('racha'), nuevaRacha);
    await _prefs!.setString(_claveDatos('ultimo_aviso_fecha'), fechaClave(hoy));
    await _registrarHistorial('bienestar', 'Aviso diario confirmado');
    notifyListeners();
    return true;
  }

  List<Map<String, dynamic>> get historial {
    final raw = _prefs?.getString(_claveDatos('historial'));
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .reversed
        .toList();
  }

  Future<void> _registrarHistorial(String tipo, String detalle) async {
    final registros = _prefs!.getString(_claveDatos('historial'));
    final lista = registros == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(registros) as List).cast<Map<String, dynamic>>();
    lista.add({
      'tipo': tipo,
      'detalle': detalle,
      'fecha': DateTime.now().toIso8601String(),
    });
    if (lista.length > 500) lista.removeRange(0, lista.length - 500);
    await _prefs!.setString(_claveDatos('historial'), jsonEncode(lista));
  }

  Future<void> _cargarDatosIniciales() async {
    if (_grupoActivo != 'familia-demo') return;
    if (!_prefs!.containsKey(_claveDatos('eventos'))) {
      final ahora = DateTime.now();
      final prueba = <EventoPersistente>[
        EventoPersistente('Cita de prueba (en 20 minutos)',
            ahora.add(const Duration(minutes: 20)), 'cita', 'Aviso de prueba'),
        EventoPersistente('Prueba de aviso (en 20 minutos)',
            ahora.add(const Duration(days: 1, minutes: 20)), 'cita', 'Prueba'),
      ];
      await _guardarCitas(prueba);
    }
    if (!_prefs!.containsKey(_claveDatos('medicamentos'))) {
      final ejemplos = [
        MedicamentoPersistente('Losartán', '1 tableta con el desayuno', 8, 0),
        MedicamentoPersistente('Metformina', '1 tableta con la comida', 14, 0),
        MedicamentoPersistente('Omeprazol', '1 cápsula antes de cenar', 20, 0),
        MedicamentoPersistente(
            'Atorvastatina', '1 tableta antes de dormir', 22, 0),
      ];
      await _guardarMedicamentos(ejemplos);
    }
  }

  List<EventoPersistente> get eventos {
    final raw = _prefs?.getString(_claveDatos('eventos'));
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => EventoPersistente.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  Future<void> agregarEvento(EventoPersistente evento) async {
    await _guardarCitas([...eventos, evento]);
    await _programarCita(evento);
    await _registrarHistorial('cita', 'Se agregó ${evento.titulo}');
    notifyListeners();
  }

  Future<void> actualizarEvento(EventoPersistente evento) async {
    await _notificaciones.cancel(id: evento.idNotificacion);
    await _guardarCitas(
        eventos.map((e) => e.id == evento.id ? evento : e).toList());
    await _programarCita(evento);
    await _registrarHistorial('cita', 'Se actualizó ${evento.titulo}');
    notifyListeners();
  }

  Future<void> eliminarEvento(EventoPersistente evento) async {
    await _notificaciones.cancel(id: evento.idNotificacion);
    await _guardarCitas(eventos.where((e) => e.id != evento.id).toList());
    await _registrarHistorial('cita', 'Se eliminó ${evento.titulo}');
    notifyListeners();
  }

  Future<void> _guardarCitas(List<EventoPersistente> lista) async =>
      _prefs!.setString(_claveDatos('eventos'),
          jsonEncode(lista.map((e) => e.toJson()).toList()));

  Future<void> sincronizarAvisosCitas() async {
    for (final evento in eventos) {
      await _programarCita(evento);
    }
  }

  Future<void> _programarCita(EventoPersistente evento) async {
    if (evento.tipo != 'cita') return;
    final fechaAviso = DateTime(evento.fecha.year, evento.fecha.month,
        evento.fecha.day - 1, evento.fecha.hour, evento.fecha.minute);
    if (!fechaAviso.isAfter(DateTime.now())) return;
    await _notificaciones.zonedSchedule(
      id: evento.idNotificacion,
      title: 'Cita mañana: ${evento.titulo}',
      body: 'Tu cita está programada para ${formatearFecha(evento.fecha)}.',
      scheduledDate: tz.TZDateTime.from(fechaAviso, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'avisos_citas',
          'Avisos de citas',
          channelDescription: 'Recordatorios un día antes de cada cita',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  List<MedicamentoPersistente> get medicamentos {
    final raw = _prefs?.getString(_claveDatos('medicamentos'));
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => MedicamentoPersistente.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.minutosDia.compareTo(b.minutosDia));
  }

  Future<void> agregarMedicamento(MedicamentoPersistente medicamento) async {
    await _guardarMedicamentos([...medicamentos, medicamento]);
    await _programarMedicamento(medicamento);
    await _registrarHistorial('medicamento', 'Se agregó ${medicamento.nombre}');
    notifyListeners();
  }

  Future<void> actualizarMedicamento(MedicamentoPersistente medicamento) async {
    await _notificaciones.cancel(id: medicamento.idNotificacion);
    await _guardarMedicamentos(medicamentos
        .map((m) => m.id == medicamento.id ? medicamento : m)
        .toList());
    await _programarMedicamento(medicamento);
    await _registrarHistorial(
        'medicamento', 'Se actualizó ${medicamento.nombre}');
    notifyListeners();
  }

  Future<void> eliminarMedicamento(MedicamentoPersistente medicamento) async {
    await _notificaciones.cancel(id: medicamento.idNotificacion);
    await _guardarMedicamentos(
        medicamentos.where((m) => m.id != medicamento.id).toList());
    await _registrarHistorial(
        'medicamento', 'Se eliminó ${medicamento.nombre}');
    notifyListeners();
  }

  Future<void> _guardarMedicamentos(List<MedicamentoPersistente> lista) async =>
      _prefs!.setString(_claveDatos('medicamentos'),
          jsonEncode(lista.map((m) => m.toJson()).toList()));

  Future<void> sincronizarAvisosMedicamentos() async {
    for (final medicamento in medicamentos) {
      await _programarMedicamento(medicamento);
    }
  }

  Future<void> _programarMedicamento(MedicamentoPersistente medicamento) async {
    final ahora = tz.TZDateTime.now(tz.local);
    var fecha = tz.TZDateTime(tz.local, ahora.year, ahora.month, ahora.day,
        medicamento.hora, medicamento.minuto);
    if (!fecha.isAfter(ahora)) fecha = fecha.add(const Duration(days: 1));
    await _notificaciones.zonedSchedule(
      id: medicamento.idNotificacion,
      title: 'Hora de medicamento: ${medicamento.nombre}',
      body: medicamento.dosis,
      scheduledDate: fecha,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'avisos_medicamentos',
          'Avisos de medicamentos',
          channelDescription: 'Recordatorios diarios de medicamentos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  bool medicamentoTomadoHoy(MedicamentoPersistente medicamento) =>
      _prefs?.getString(_claveDatos('medicamento_${medicamento.id}')) ==
      fechaClave(DateTime.now());

  Future<void> registrarMedicamentoTomado(
      MedicamentoPersistente medicamento) async {
    await _prefs!.setString(_claveDatos('medicamento_${medicamento.id}'),
        fechaClave(DateTime.now()));
    await _registrarHistorial('medicamento', 'Tomado: ${medicamento.nombre}');
    notifyListeners();
  }

  static String fechaClave(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  static int siguienteRacha(int actual, String? ultimo, DateTime hoy) {
    if (ultimo == fechaClave(hoy)) return actual;
    final ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);
    return ultimo == fechaClave(ayer) ? actual + 1 : 1;
  }

  static String formatearFecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
}

class CuentaLocalVelia {
  final String email;
  final String password;
  final String rol;
  final String grupo;
  final int usos;
  final String? ultimaActividad;
  final bool activa;
  final String? codigoVinculacion;
  final String nombre;
  final String fechaNacimiento;
  final String telefonoEmergencia;
  final String parentesco;
  final String tipoContacto;
  final String datoContacto;
  final String adultoVinculado;
  final String estadoVinculo;

  const CuentaLocalVelia(
      {required this.email,
      required this.password,
      required this.rol,
      required this.grupo,
      this.usos = 0,
      this.ultimaActividad,
      this.activa = false,
      this.codigoVinculacion,
      this.nombre = '',
      this.fechaNacimiento = '',
      this.telefonoEmergencia = '',
      this.parentesco = '',
      this.tipoContacto = '',
      this.datoContacto = '',
      this.adultoVinculado = '',
      this.estadoVinculo = ''});

  CuentaLocalVelia copyWith(
          {int? usos,
          String? ultimaActividad,
          bool? activa,
          String? codigoVinculacion,
          String? grupo,
          String? nombre,
          String? fechaNacimiento,
          String? telefonoEmergencia,
          String? parentesco,
          String? tipoContacto,
          String? datoContacto,
          String? adultoVinculado,
          String? estadoVinculo}) =>
      CuentaLocalVelia(
          email: email,
          password: password,
          rol: rol,
          grupo: grupo ?? this.grupo,
          usos: usos ?? this.usos,
          ultimaActividad: ultimaActividad ?? this.ultimaActividad,
          activa: activa ?? this.activa,
          codigoVinculacion: codigoVinculacion ?? this.codigoVinculacion,
          nombre: nombre ?? this.nombre,
          fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
          telefonoEmergencia: telefonoEmergencia ?? this.telefonoEmergencia,
          parentesco: parentesco ?? this.parentesco,
          tipoContacto: tipoContacto ?? this.tipoContacto,
          datoContacto: datoContacto ?? this.datoContacto,
          adultoVinculado: adultoVinculado ?? this.adultoVinculado,
          estadoVinculo: estadoVinculo ?? this.estadoVinculo);

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'rol': rol,
        'grupo': grupo,
        'usos': usos,
        'ultimaActividad': ultimaActividad,
        'activa': activa,
        'codigoVinculacion': codigoVinculacion,
        'nombre': nombre,
        'fechaNacimiento': fechaNacimiento,
        'telefonoEmergencia': telefonoEmergencia,
        'parentesco': parentesco,
        'tipoContacto': tipoContacto,
        'datoContacto': datoContacto,
        'adultoVinculado': adultoVinculado,
        'estadoVinculo': estadoVinculo
      };

  factory CuentaLocalVelia.fromJson(Map<String, dynamic> json) =>
      CuentaLocalVelia(
          email: json['email'] as String,
          password: json['password'] as String,
          rol: json['rol'] as String,
          grupo: json['grupo'] as String,
          usos: json['usos'] as int? ?? 0,
          ultimaActividad: json['ultimaActividad'] as String?,
          activa: json['activa'] as bool? ?? false,
          codigoVinculacion: json['codigoVinculacion'] as String?,
          nombre: json['nombre'] as String? ?? '',
          fechaNacimiento: json['fechaNacimiento'] as String? ?? '',
          telefonoEmergencia: json['telefonoEmergencia'] as String? ?? '',
          parentesco: json['parentesco'] as String? ?? '',
          tipoContacto: json['tipoContacto'] as String? ?? '',
          datoContacto: json['datoContacto'] as String? ?? '',
          adultoVinculado: json['adultoVinculado'] as String? ?? '',
          estadoVinculo: json['estadoVinculo'] as String? ?? '');
}

class EventoPersistente {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String tipo;
  final String notas;

  EventoPersistente(this.titulo, this.fecha, this.tipo, this.notas)
      : id = '${DateTime.now().microsecondsSinceEpoch}';
  EventoPersistente.conId(
      this.id, this.titulo, this.fecha, this.tipo, this.notas);
  EventoPersistente._(this.id, this.titulo, this.fecha, this.tipo, this.notas);
  int get idNotificacion => 100000 + (int.parse(id) % 0x3fffffff);
  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'tipo': tipo,
        'notas': notas
      };
  factory EventoPersistente.fromJson(Map<String, dynamic> json) =>
      EventoPersistente._(
          json['id'] as String,
          json['titulo'] as String,
          DateTime.parse(json['fecha'] as String),
          json['tipo'] as String,
          json['notas'] as String);
}

class MedicamentoPersistente {
  final String id;
  final String nombre;
  final String dosis;
  final int hora;
  final int minuto;

  MedicamentoPersistente(this.nombre, this.dosis, this.hora, this.minuto)
      : id = '${DateTime.now().microsecondsSinceEpoch}';
  MedicamentoPersistente.conId(
      this.id, this.nombre, this.dosis, this.hora, this.minuto);
  int get minutosDia => hora * 60 + minuto;
  int get idNotificacion => 2000000000 + (int.parse(id) % 100000000);
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'hora': hora,
        'minuto': minuto
      };
  factory MedicamentoPersistente.fromJson(Map<String, dynamic> json) =>
      MedicamentoPersistente.conId(
          json['id'] as String,
          json['nombre'] as String,
          json['dosis'] as String,
          json['hora'] as int,
          json['minuto'] as int);
}
