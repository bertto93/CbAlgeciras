import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const kFeb = 'https://baloncestoenvivo.feb.es';

class Match {
  final int j;
  final String date, time, rival;
  final bool home;
  const Match(this.j, this.date, this.time, this.home, this.rival);
  DateTime get dt => DateTime.parse('${date}T${time.isEmpty ? '12:00' : time}:00');
  String get label {
    const d = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const m = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final x = dt;
    return '${d[x.weekday - 1]} ${x.day} ${m[x.month - 1]}${time.isEmpty ? ' · hora por confirmar' : ' · $time h'}';
  }
}

// Calendario parcial (fuentes FEB y prensa). Edita aquí para completarlo.
const fixtures = <Match>[
  Match(1, '2026-10-03', '19:30', true, 'BC Badajoz'),
  Match(4, '2026-10-25', '12:30', true, 'Jaén Paraíso Interior FS'),
  Match(6, '2026-11-08', '12:30', true, 'Clínica Ponferrada SDP'),
  Match(8, '2026-11-21', '19:30', true, 'Rival por confirmar'),
  Match(9, '2026-11-28', '', false, 'Movistar Estudiantes'),
  Match(12, '2026-12-19', '', true, 'Melilla Ciudad del Deporte'),
  Match(13, '2027-01-03', '', false, 'CB Getafe'),
  Match(14, '2027-01-09', '', false, 'BC Badajoz'),
  Match(15, '2027-01-16', '', true, 'Cáceres Patrimonio de la Humanidad'),
  Match(16, '2027-01-31', '12:30', true, 'CB Toledo Basket'),
  Match(17, '2027-02-06', '', false, 'Jaén Paraíso Interior FS'),
  Match(18, '2027-02-13', '19:30', true, 'UEMC Valladolid'),
  Match(19, '2027-02-20', '19:30', false, 'Clínica Ponferrada SDP'),
  Match(20, '2027-02-27', '19:30', true, 'Cultural y Deportiva Leonesa'),
  Match(22, '2027-03-14', '12:30', true, 'Movistar Estudiantes'),
  Match(24, '2027-03-27', '19:30', true, 'Spanish Basketball Academy'),
  Match(25, '2027-04-03', '', false, 'Melilla Ciudad del Deporte'),
  Match(26, '2027-04-10', '20:00', true, 'Rival por confirmar'),
];

const rivals = [
  'BC Badajoz', 'Jaén Paraíso Interior FS', 'Clínica Ponferrada SDP', 'Movistar Estudiantes',
  'Melilla Ciudad del Deporte', 'CB Getafe', 'Cáceres Patrimonio de la Humanidad', 'CB Toledo Basket',
  'UEMC Valladolid', 'Cultural y Deportiva Leonesa', 'Spanish Basketball Academy', 'CB Starlabs Morón', 'CB Tres Cantos',
];

Future<void> open(String u) => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'CB Algeciras',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0B5ED7), useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF0B5ED7), useMaterial3: true, brightness: Brightness.dark),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int i = 0;
  @override
  Widget build(BuildContext c) {
    const pages = [Next(), Calendar(), Rivals(), Live()];
    return Scaffold(
      appBar: AppBar(title: const Text('🏀 CB Algeciras · 2ª FEB')),
      body: pages[i],
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendario'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Rivales'),
          NavigationDestination(icon: Icon(Icons.sports_basketball), label: 'Directo'),
        ],
      ),
    );
  }
}

class Next extends StatelessWidget {
  const Next({super.key});
  @override
  Widget build(BuildContext c) {
    final now = DateTime.now().subtract(const Duration(hours: 3));
    final n = fixtures.where((m) => m.dt.isAfter(now)).toList();
    final m = n.isEmpty ? null : n.first;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: m == null
              ? const Text('Sin partidos pendientes')
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('PRÓXIMO PARTIDO CONOCIDO'),
                  const SizedBox(height: 8),
                  Text(m.home ? 'CB Algeciras – ${m.rival}' : '${m.rival} – CB Algeciras',
                      style: Theme.of(c).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Jornada ${m.j} · ${m.label}'),
                  Text('${m.home ? 'En casa' : 'Fuera'} · faltan ${m.dt.difference(DateTime.now()).inDays} días'),
                ]),
        ),
      ),
      const SizedBox(height: 8),
      const Text('Calendario parcial: faltan jornadas 2, 3, 5, 7, 10, 11, 21 y 23. Confirma en Baloncesto en Vivo.'),
      const SizedBox(height: 12),
      FilledButton.icon(
          onPressed: () => open(kFeb), icon: const Icon(Icons.open_in_new), label: const Text('Resultados y estadísticas (FEB)')),
    ]);
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});
  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  String f = 'all';
  @override
  Widget build(BuildContext c) {
    final list = fixtures.where((m) => f == 'all' || (f == 'H') == m.home).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(spacing: 8, children: [
          for (final e in {'all': 'Todos', 'H': 'Casa', 'A': 'Fuera'}.entries)
            ChoiceChip(label: Text(e.value), selected: f == e.key, onSelected: (_) => setState(() => f = e.key)),
        ]),
      ),
      Expanded(
        child: ListView(children: [
          for (final m in list)
            ListTile(
              leading: CircleAvatar(child: Text('J${m.j}')),
              title: Text(m.rival),
              subtitle: Text('${m.home ? 'CASA' : 'FUERA'} · ${m.label}'),
              textColor: m.dt.isBefore(DateTime.now()) ? Colors.grey : null,
            ),
        ]),
      ),
    ]);
  }
}

class Rivals extends StatelessWidget {
  const Rivals({super.key});
  @override
  Widget build(BuildContext c) => ListView(children: [
        for (final r in rivals)
          ExpansionTile(
            title: Text(r),
            children: [
              for (final m in fixtures.where((m) => m.rival == r))
                ListTile(dense: true, title: Text('J${m.j} · ${m.home ? 'En casa' : 'Fuera'}'), subtitle: Text(m.label)),
              ListTile(
                  dense: true,
                  leading: const Icon(Icons.open_in_new),
                  title: const Text('Plantilla y estadísticas (FEB)'),
                  onTap: () => open(kFeb)),
            ],
          ),
      ]);
}

class Live extends StatelessWidget {
  const Live({super.key});
  @override
  Widget build(BuildContext c) => ListView(children: [
        ListTile(
            leading: const Icon(Icons.sports_basketball),
            title: const Text('Baloncesto en Vivo (FEB)'),
            subtitle: const Text('Directo, clasificación, plantillas y estadísticas'),
            onTap: () => open(kFeb)),
        ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text('Noticias Segunda FEB'),
            onTap: () => open('https://www.feb.es/segundafeb')),
      ]);
}
