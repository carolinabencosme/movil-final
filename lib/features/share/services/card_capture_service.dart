import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Servicio para capturar widgets como imágenes y compartirlas.
/// 
/// Utiliza RepaintBoundary y RenderRepaintBoundary para convertir
/// un widget en una imagen PNG que puede ser guardada y compartida.
class CardCaptureService {
  /// Captura un widget como imagen usando su GlobalKey.
  /// 
  /// El widget debe estar envuelto en un RepaintBoundary con el GlobalKey
  /// para que este método pueda acceder al RenderObject y renderizarlo.
  /// 
  /// Retorna los bytes de la imagen en formato PNG, o null si falla.
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      // Buscar el RenderRepaintBoundary del widget
      final boundary = key.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('[CardCaptureService] No se encontró RenderRepaintBoundary');
        return null;
      }

      // Capturar la imagen con alta calidad (pixelRatio 3.0)
      final image = await boundary.toImage(pixelRatio: 3.0);
      
      // Convertir a bytes PNG
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('[CardCaptureService] No se pudo convertir la imagen a bytes');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e, stackTrace) {
      debugPrint('[CardCaptureService] Error al capturar widget: $e');
      debugPrint('[CardCaptureService] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Guarda los bytes de una imagen en un archivo temporal.
  /// 
  /// Retorna la ruta del archivo guardado, o null si falla.
  Future<String?> saveImageToTemp(
    Uint8List imageBytes, {
    String filename = 'pokemon_card.png',
  }) async {
    try {
      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';
      
      // Crear el archivo y escribir los bytes
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      debugPrint('[CardCaptureService] Imagen guardada en: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      debugPrint('[CardCaptureService] Error al guardar imagen: $e');
      debugPrint('[CardCaptureService] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Comparte una imagen usando el diálogo nativo del sistema.
  /// 
  /// [imagePath] debe ser la ruta completa al archivo de imagen.
  /// [text] es un texto opcional para acompañar la imagen.
  /// 
  /// Retorna true si se compartió exitosamente, false si falló o fue cancelado.
  Future<bool> shareImage(
    String imagePath, {
    String? text,
  }) async {
    try {
      final xFile = XFile(imagePath);
      
      final result = await Share.shareXFiles(
        [xFile],
        text: text,
      );

      debugPrint('[CardCaptureService] Resultado de compartir: ${result.status}');
      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.unavailable; // unavailable = shared
    } catch (e, stackTrace) {
      debugPrint('[CardCaptureService] Error al compartir imagen: $e');
      debugPrint('[CardCaptureService] StackTrace: $stackTrace');
      return false;
    }
  }

  /// Método todo-en-uno: captura un widget, lo guarda y lo comparte.
  /// 
  /// [key] es el GlobalKey del RepaintBoundary que envuelve el widget.
  /// [filename] es el nombre del archivo temporal (por defecto: pokemon_card.png).
  /// [text] es un texto opcional para acompañar la imagen al compartir.
  /// 
  /// Retorna true si todo el proceso fue exitoso, false si hubo algún error.
  Future<bool> captureAndShare(
    GlobalKey key, {
    String filename = 'pokemon_card.png',
    String? text,
  }) async {
    // 1. Capturar el widget como imagen
    final imageBytes = await captureWidget(key);
    if (imageBytes == null) {
      debugPrint('[CardCaptureService] No se pudo capturar el widget');
      return false;
    }

    // 2. Guardar en archivo temporal
    final imagePath = await saveImageToTemp(imageBytes, filename: filename);
    if (imagePath == null) {
      debugPrint('[CardCaptureService] No se pudo guardar la imagen');
      return false;
    }

    // 3. Compartir usando el diálogo nativo
    final shared = await shareImage(imagePath, text: text);
    if (!shared) {
      debugPrint('[CardCaptureService] No se pudo compartir la imagen');
      return false;
    }

    return true;
  }
}
