import 'package:flutter/foundation.dart';
import 'package:salvador_task_management/src/config/navigation/navigation_service.dart';
import 'package:salvador_task_management/src/config/providers.dart';
import 'package:salvador_task_management/src/features/pages/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:salvador_task_management/src/features/signin/signin_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salvador_task_management/src/repository/clienti_api_repository.dart';
import 'package:salvador_task_management/src/repository/clienti_db_repository.dart';
import 'package:salvador_task_management/src/repository/datalimite_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_api_repository.dart';
import 'package:salvador_task_management/src/repository/interventi_db_repository.dart';
import 'package:salvador_task_management/src/repository/item_api_repository.dart';
import 'package:salvador_task_management/src/repository/item_db_repository.dart';

class SettingsView extends ConsumerWidget {
  //String? lastInitializationDate;

  const SettingsView({super.key});

  onThemePressed(WidgetRef ref, ThemeMode themeMode) {
    ref.read(settingsControllerProvider.notifier).updateThemeMode(themeMode);
  }

  onSignOutPressed(WidgetRef ref, String redirectRoute) async {
    var prefs = ref.read(sharedPreferencesProvider).asData!.value;
    await prefs.remove("user");
    ref.read(navigationServiceProvider).routeTo(redirectRoute);
  }

void onInitializeArchivesPressed(BuildContext context, WidgetRef ref) async {
  bool isLoading = false;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Inizializza archivi'),
            content: isLoading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotatingHourglass(),
                      SizedBox(height: 16),
                      Text("Inizializzazione in corso..."),
                      Text("Si prega di attendere qualche minuto"),
                    ],
                  )
                : const Text('Vuoi davvero inizializzare gli archivi?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annulla'),
              ),
              if (!isLoading)
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      var datalimite = await ref.read(dataLimiteRepositoryProvider.future);
                      if (kDebugMode) {
                        datalimite = '1900-01-01 01:00:00.000';
                      }
                      var data = await ref.read(itemsApiProvider.call(datalimite).future);
                      var itemDbNotifier = ref.read(itemDbRepositoryProvider.notifier);
                      itemDbNotifier.updateItems(data);
                      var dataLimiteNotifier = ref.read(dataLimiteRepositoryProvider.notifier);
                      dataLimiteNotifier.updateDataLimite();
                      var clienti = await ref.read(clientiApiProvider.future);
                      var clientiDbNotifier = ref.read(clientiDbRepositoryProvider.notifier);
                      clientiDbNotifier.updateClienti(clienti);
                      var interventi = await ref.read(interventiApiProvider.call().future);
                      var interventiDbNotifier = ref.read(interventiDbRepositoryProvider.notifier);
                      interventiDbNotifier.updateInterventi(interventi);
                    } catch (error) {
                      print(error);
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Conferma'),
                ),
            ],
          );
        },
      );
    },
  );
}



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          alignment: Alignment.center,
          child: ListView(
            children: [
              _SingleSection(
                title: "Themes",
                children: [
                  const SizedBox(height: 20),
                  _CustomListTile(
                    title: "Dark Mode",
                    icon: Icons.dark_mode,
                    trailing: TextButton(
                      onPressed: () => {
                        onThemePressed(ref, ThemeMode.dark),
                      },
                      child: const Text("Seleziona"),
                    ),
                  ),
                  _CustomListTile(
                    title: "Light Mode",
                    icon: Icons.light_mode,
                    trailing: TextButton(
                      onPressed: () => {
                        onThemePressed(ref, ThemeMode.light),
                      },
                      child: const Text("Seleziona"),
                    ),
                  ),
                  _CustomListTile(
                    title: "System Mode",
                    icon: Icons.cloud,
                    trailing: TextButton(
                      onPressed: () => {
                        onThemePressed(ref, ThemeMode.system),
                      },
                      child: const Text("Seleziona"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _SingleSection(
                children: [
                  _CustomListTile(
                    title: "Aggiorna archivi",
                    icon: Icons.archive,
                    trailing: TextButton(
                      onPressed: () {
                        onInitializeArchivesPressed(context, ref);
                      },
                      child: const Text("Seleziona"),
                    ),
                  ),
                  // _CustomListTile(
                  //   title: "Aggiorna dati",
                  //   icon: Icons.update,
                  //   trailing: TextButton(
                  //     onPressed: () {
                  //       onUpdateDataPressed(context);
                  //     },
                  //     child: const Text("Seleziona"),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  Consumer(builder: ((context, ref, child) {
                    var lastInitializationDate =
                        ref.watch(dataLimiteRepositoryProvider.future);

                    return FutureBuilder(
                        future: lastInitializationDate,
                        builder: ((context, snapshot) {
                          return Text(
                            "Ultimo Aggiornamento: ${snapshot.data}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 73, 73, 73)),
                          );
                        }));
                  })),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _SingleSection(children: [
                _CustomListTile(
                  title: "Sign out",
                  icon: Icons.exit_to_app_rounded,
                  trailing: TextButton(
                    onPressed: () => {
                      onSignOutPressed(ref, SignInView.routeName),
                    },
                    child: const Text("Seleziona"),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  const _CustomListTile(
      {required this.title, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: () {},
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SingleSection({
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}

class RotatingHourglass extends StatefulWidget {
  const RotatingHourglass({super.key});

  @override
  RotatingHourglassState createState() => RotatingHourglassState();
}

class RotatingHourglassState extends State<RotatingHourglass>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: const Icon(
        Icons.hourglass_bottom,
        size: 40,
      ),
    );
  }
}
