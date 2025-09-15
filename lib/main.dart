import 'package:flutter/material.dart';

void main() => runApp(const CopaFacilDemoApp());

class CopaFacilDemoApp extends StatelessWidget {
  const CopaFacilDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confirmação de Remoção',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F1B36),
        brightness: Brightness.light,
      ),
      home: const ChampionshipsPage(),
    );
  }
}

class Championship {
  final String id;
  final String name;
  final String category;

  Championship({
    required this.id,
    required this.name,
    required this.category,
  });
}

class ChampionshipsPage extends StatefulWidget {
  const ChampionshipsPage({super.key});

  @override
  State<ChampionshipsPage> createState() => _ChampionshipsPageState();
}

class _ChampionshipsPageState extends State<ChampionshipsPage> {
  final List<Championship> _items = List.generate(
    2,
    (i) => Championship(
      id: 'c$i',
      name: 'Campeonato ${i + 1}',
      category: i.isEven ? 'Futebol' : 'Futebol 7',
    ),
  );

  //  Confirmação inicial
  //  - showDialog<bool> é a FUNÇÃO que exibe o diálogo (overlay modal)
  //  - Retorna true (confirmado) ou false (cancelado)
  Future<bool> _confirmStep1(BuildContext context) async {
    final theme = Theme.of(context);
    final bool confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // impede fechar tocando fora do diálogo
          builder: (context) => AlertDialog( 
            title: Text(
              'Remover Campeonato',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Você tem certeza que deseja Remover este campeonato? '
              '(Não será possível recuperá-lo)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remover'),
              ),
            ],
          ),
        ) ??
        false;
    return confirmed;
  }

  //  Confirmação final com consentimento explícito
  //    dentro do diálogo para habilitar/desabilitar o botão com base no checkbox
  Future<bool> _confirmStep2(BuildContext context) async {
    final theme = Theme.of(context);
    bool ack = false; // marcação do "Entendo que..."

    final bool finalConfirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => StatefulBuilder(
            // WIDGET responsável por manter estado local no diálogo
            builder: (ctx, setState) => AlertDialog( 
              title: Text(
                'Confirmação final',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Esta ação é permanente e não pode ser desfeita.',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: ack,
                    onChanged: (v) => setState(() => ack = v ?? false),
                    title: const Text(
                      'Entendo que o campeonato será removido definitivamente.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  //  Botão só habilita quando o checkbox está marcado (consentimento)
                  onPressed: ack ? () => Navigator.of(ctx).pop(true) : null,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Remover definitivamente'),
                ),
              ],
            ),
          ),
        ) ??
        false;

    return finalConfirm;
  }

  // Orquestração da dupla confirmação e "remoção"
  Future<void> _doubleConfirmAndDelete(Championship c) async {
    final messenger = ScaffoldMessenger.of(context);

    final step1 = await _confirmStep1(context);
    if (!step1) return;

    final step2 = await _confirmStep2(context);
    if (!step2) return;

    // Aqui você executaria a chamada para remover no backend.
    setState(() => _items.removeWhere((e) => e.id == c.id));

    messenger.showSnackBar(
      SnackBar(
        content: Text('Campeonato "${c.name}" excluído.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campeonatos'),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text(
                'Nenhum campeonato.',
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  final c = _items[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.emoji_events, size: 64, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  c.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c.category,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                //    ao tocar em "Remover campeonato" inicia a dupla confirmação.
                                Center(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => _doubleConfirmAndDelete(c),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        'Remover campeonato',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
