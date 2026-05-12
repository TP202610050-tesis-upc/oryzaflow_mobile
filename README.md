# OryzaFlow Mobile App

**OryzaFlow** es una solución de **IoT** diseñada para optimizar el proceso de secado de arroz en el Valle del Jequetepeque, Perú. Esta aplicación móvil permite a los operarios monitorear la telemetría en tiempo real y gestionar perfiles de secado para mejorar el rendimiento de arroz entero (HRY).

## Características Principales

* **Monitoreo en Tiempo Real:** Visualización de curvas de humedad y temperatura provenientes de nodos ESP32.
* **Gestión de Perfiles:** Configuración de parámetros de secado según la calidad del grano (Caserita, Despuntado, etc.).
* **Seguridad Industrial:** Autenticación robusta basada en **JWT (JSON Web Token)**.
* **Resiliencia:** Capacidad de visualización de datos históricos sincronizados desde una capa de persistencia local.

## Stack Tecnológico

* **Framework:** Flutter (SDK ^3.9.2)
* **Lenguaje:** Dart
* **Gestión de Estado:** Provider
* **Seguridad:** Flutter Secure Storage & JWT Decoder
* **Comunicación:** HTTP & MQTT (via ThingsBoard/Spring Boot)
* **Gráficos:** FL Chart

## Configuración del Proyecto

Para ejecutar este proyecto localmente, asegúrate de tener instalado el SDK de Flutter y sigue estos pasos:

1.  **Clonar el repositorio:**
    ```bash
    git clone https://github.com/TP202610050-tesis-upc/oryzaflow_mobile.git
    ```
2.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```
3.  **Configurar constantes:**
    Modifica el archivo `lib/core/constants.dart` con la IP de tu servidor backend.
4.  **Ejecutar la aplicación:**
    ```bash
    flutter run
    ```

## Contexto Académico

Este proyecto forma parte del **Capstone Project** para la carrera de Ingeniería de Software en la **Universidad Peruana de Ciencias Aplicadas (UPC)**, cumpliendo con los estándares de acreditación **ABET**.