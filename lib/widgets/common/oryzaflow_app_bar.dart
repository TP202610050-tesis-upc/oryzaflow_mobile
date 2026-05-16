import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OryzaFlowAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? acciones;
  final bool mostrarBotonAtras;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onMenuTap;

  const OryzaFlowAppBar({
    super.key,
    required this.titulo,
    this.acciones,
    this.mostrarBotonAtras = false,
    this.leading,
    this.bottom,
    this.onMenuTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    Widget? resolvedLeading = leading;
    if (resolvedLeading == null) {
      if (mostrarBotonAtras) {
        resolvedLeading = IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        );
      } else if (onMenuTap != null) {
        resolvedLeading = IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: onMenuTap,
        );
      }
    }
    return AppBar(
      title: Text(titulo),
      actions: acciones,
      leading: resolvedLeading,
      bottom: bottom,
    );
  }
}
