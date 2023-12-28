import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DosesAdministeredPage extends ConsumerStatefulWidget {
  static const String routeName = '/doses_recently_administered';

  const DosesAdministeredPage({super.key});

  @override
  ConsumerState<DosesAdministeredPage> createState() =>
      _DosesAdministeredPageState();
}

class _DosesAdministeredPageState extends ConsumerState<DosesAdministeredPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
