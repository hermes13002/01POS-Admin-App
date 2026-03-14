import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// invokes [onReturn] when the current route becomes visible again
class RefreshOnReturn extends StatefulWidget {
  const RefreshOnReturn({
    super.key,
    required this.child,
    required this.onReturn,
  });

  final Widget child;
  final VoidCallback onReturn;

  @override
  State<RefreshOnReturn> createState() => _RefreshOnReturnState();
}

class _RefreshOnReturnState extends State<RefreshOnReturn> with RouteAware {
  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = ModalRoute.of(context);
    if (currentRoute == null || currentRoute == _route) {
      return;
    }

    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }

    _route = currentRoute;
    if (currentRoute is PageRoute) {
      appRouteObserver.subscribe(this, currentRoute);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    widget.onReturn();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
