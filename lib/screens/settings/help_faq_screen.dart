import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/oryzaflow_app_bar.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  static const _faqs = [
    (
      '¿Qué es OryzaFlow?',
      'OryzaFlow es un sistema de monitoreo IoT para el secado de arroz. Permite controlar temperatura, humedad, flujo de aire y humedad del grano en tiempo real a través de sensores ESP32 instalados en los silos.',
    ),
    (
      '¿Cómo inicio un proceso de secado?',
      'Ve a la sección "Lotes", crea un nuevo lote seleccionando la variedad, silo, nodo y perfil de secado. Luego abre el detalle del lote y presiona "Iniciar Secado".',
    ),
    (
      '¿Qué significa una alerta crítica?',
      'Una alerta crítica indica que un parámetro (temperatura, humedad, etc.) ha superado los umbrales configurados. Requiere atención inmediata para evitar pérdida del grano.',
    ),
    (
      '¿Cómo configuro los umbrales de alerta?',
      'Ve a Monitoreo → Parámetros, selecciona el nodo y ajusta los valores mínimos y máximos para cada sensor.',
    ),
    (
      '¿Puedo exportar reportes?',
      'Sí. Ve a Reportes → Exportar Reporte, selecciona el rango de fechas y el formato (PDF o CSV), y presiona Exportar.',
    ),
    (
      '¿Qué roles existen en el sistema?',
      'Existen tres roles: Operador (puede ver y registrar datos), Supervisor (puede editar perfiles de secado) y Administrador (acceso completo, gestión de usuarios y configuración de nodos).',
    ),
    (
      '¿Cómo agrego un nuevo silo?',
      'Ve a Silos (desde el menú lateral) y presiona el botón "Nuevo Silo". Completa nombre, ubicación y capacidad. Requiere rol de Administrador.',
    ),
    (
      '¿Qué es el modo manual en Control de Campo?',
      'En modo manual puedes encender o apagar directamente los ventiladores y calefactores de cada nodo. En modo automático, el sistema los controla según el perfil de secado activo.',
    ),
    (
      '¿Cómo calibro los sensores?',
      'Ve a Configuración → Calibrar Sensores. Selecciona el nodo y ajusta el offset (corrección) de cada sensor. El valor real reportado será: lectura_sensor + offset.',
    ),
    (
      '¿Cómo contacto al soporte técnico?',
      'Envía un correo a soporte@oryzaflow.com o llama al +51 900 000 000. Horario de atención: Lunes a Viernes 8:00 AM - 6:00 PM (hora de Lima).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OryzaFlowAppBar(
        titulo: AppStrings.ayudaFaq,
        mostrarBotonAtras: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            decoration: BoxDecoration(
              color: AppColors.verdeFondo,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_rounded,
                    size: 32, color: AppColors.verde),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preguntas Frecuentes',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.verde)),
                      const Text(
                        'Encuentra respuestas a las dudas más comunes sobre el uso de OryzaFlow.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          ..._faqs.map((faq) => _FaqTile(
                pregunta: faq.$1,
                respuesta: faq.$2,
              )),
          const SizedBox(height: AppDimensions.paddingL),
          _ContactoSection(),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String pregunta;
  final String respuesta;
  const _FaqTile({required this.pregunta, required this.respuesta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(pregunta,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: const BorderSide(color: AppColors.borde),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: const BorderSide(color: AppColors.verde),
        ),
        iconColor: AppColors.verde,
        collapsedIconColor: AppColors.textoSecundario,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(respuesta,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textoSecundario,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _ContactoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.informacionFondo,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.informacion.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent_rounded,
                  size: 18, color: AppColors.informacion),
              const SizedBox(width: 8),
              Text('Contacto de Soporte',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: AppColors.informacion)),
            ],
          ),
          const SizedBox(height: 8),
          const _ContactRow(Icons.email_outlined, 'soporte@oryzaflow.com'),
          const _ContactRow(Icons.phone_outlined, '+51 900 000 000'),
          const _ContactRow(Icons.access_time_rounded,
              'Lun–Vie, 8:00 AM – 6:00 PM (Lima)'),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.informacion),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textoSecundario)),
        ],
      ),
    );
  }
}
