import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection_container.dart';
import '../../core/router/route_names.dart';
import '../../models/user_model.dart';
import '../../core/enums/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_state_widget.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';
import '../../widgets/common/role_badge.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<UserManagementProvider>()..cargarUsuarios(),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatelessWidget {
  const _UsersView();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().usuario;

    return Scaffold(
      appBar: OryzaFlowAppBar(
        titulo: AppStrings.usuarios,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
      ),
      floatingActionButton: currentUser?.rol.puedeVerUsuarios == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.nuevoUsuario),
              backgroundColor: AppColors.verde,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text(AppStrings.nuevoUsuario,
                  style: TextStyle(color: Colors.white)),
            )
          : null,
      body: Consumer<UserManagementProvider>(
        builder: (_, prov, __) {
          if (prov.estaCargando) return const ShimmerList();
          if (prov.error != null) {
            return ErrorStateWidget(
                mensaje: prov.error, onReintentar: prov.cargarUsuarios);
          }
          if (prov.usuarios.isEmpty) {
            return const EmptyStateWidget(
                icono: Icons.people_outlined,
                mensaje: 'Sin usuarios registrados');
          }

          return RefreshIndicator(
            onRefresh: prov.cargarUsuarios,
            color: AppColors.verde,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: prov.usuarios.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.paddingS),
              itemBuilder: (_, i) {
                final u = prov.usuarios[i];
                return _UserCard(
                  user: u,
                  isCurrentUser: u.id == currentUser?.id,
                  onTap: () => context.push(RouteNames.detalleUsuarioPath(u.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.isCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.verdeFondo,
          child: Text(
            user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.verde),
          ),
        ),
        title: Row(
          children: [
            Text(user.nombre,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (isCurrentUser) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.verdeFondo,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Tú',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.verde)),
              ),
            ],
          ],
        ),
        subtitle: Text(user.email,
            style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RoleBadge(rol: user.rol),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: user.activo
                    ? AppColors.verdeFondo
                    : AppColors.borde,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.activo ? AppStrings.activo : AppStrings.inactivo,
                style: TextStyle(
                    fontSize: 10,
                    color: user.activo
                        ? AppColors.verde
                        : AppColors.textoSecundario),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
