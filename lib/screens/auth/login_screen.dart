import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _ocultarPass = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final ok = await auth.iniciarSesion(
          email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(auth.error ?? AppStrings.credencialesInvalidas),
            backgroundColor: AppColors.critico,
            behavior: SnackBarBehavior.floating,
          ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.critico,
            behavior: SnackBarBehavior.floating,
          ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _usarCredencial(String email, String pass) {
    _emailCtrl.text = email;
    _passCtrl.text = pass;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 16),
              _buildForgotPassword(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              const SizedBox(height: 40),
              _buildDemoCredentials(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borde),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/oryzaflow-logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        Text(AppStrings.appNombre,
            style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 6),
        Text(AppStrings.appSlogan,
            style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: AppStrings.correoElectronico,
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.campoRequerido;
              if (!v.contains('@')) return AppStrings.correoInvalido;
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.paddingM),
          TextFormField(
            controller: _passCtrl,
            obscureText: _ocultarPass,
            decoration: InputDecoration(
              labelText: AppStrings.contrasena,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                    _ocultarPass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18),
                onPressed: () =>
                    setState(() => _ocultarPass = !_ocultarPass),
              ),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? AppStrings.campoRequerido : null,
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => context.push(RouteNames.recuperarContrasena),
        child: const Text(AppStrings.olvidasteContrasena),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text(AppStrings.iniciarSesion,
                style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    const creds = [
      ('Administrador', 'admin@oryzaflow.pe', 'admin123'),
    ];

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(AppStrings.credencialesDePrueba,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textoSecundario)),
        iconColor: AppColors.textoSecundario,
        collapsedIconColor: AppColors.textoDeshabilitado,
        children: creds
            .map((c) => ListTile(
                  dense: true,
                  leading: RoleBadgeSmall(label: c.$1),
                  title: Text(c.$2,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text('Contraseña: ${c.$3}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textoSecundario)),
                  onTap: () => _usarCredencial(c.$2, c.$3),
                ))
            .toList(),
      ),
    );
  }
}

class RoleBadgeSmall extends StatelessWidget {
  final String label;
  const RoleBadgeSmall({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.verdeFondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.verde)),
    );
  }
}
