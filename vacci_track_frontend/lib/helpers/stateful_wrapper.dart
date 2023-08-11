import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/provider/user_provider.dart';

class StatefulWrapper extends ConsumerStatefulWidget {
  final Function onInit;
  final Widget child;
  const StatefulWrapper({required this.onInit, required this.child, super.key});
  @override
  ConsumerState<StatefulWrapper> createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends ConsumerState<StatefulWrapper> {
  bool? isAuthenticated;

  Future<void> checkAuth() async {
    // ignore: invalid_use_of_protected_member
    final userData = ref.watch(userProvider.notifier).state;
    final data = await Helpers.checkLoggedInPost(userData.token);
    print(data);
  }

  void initState() {
    checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
