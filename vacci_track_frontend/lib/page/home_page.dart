import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/0';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;

  @override
  Widget build(BuildContext context) {
    return const NavWrapper(child: Placeholder());
  }
}
