import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class CapturedCardImage {
  const CapturedCardImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

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
  /// [paintTimeout] permite ajustar el tiempo máximo de espera según el
  /// dispositivo o las pruebas.
  /// Retorna la imagen capturada (bytes + dimensiones) o null si falla.
  Future<CapturedCardImage?> captureWidget(
    GlobalKey key, {
    Duration paintTimeout = const Duration(seconds: 5),
  }) async {
    try {
      // Buscar el RenderRepaintBoundary del widget
      final boundary = key.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('[CardCaptureService] No se encontró RenderRepaintBoundary');
        return null;
      }

      // Esperar a que el widget esté completamente pintado con timeout
      final paintStopwatch = Stopwatch()..start();

      if (boundary.debugNeedsPaint) {
        debugPrint(
          '[CardCaptureService] Widget necesita ser pintado, esperando hasta '
          '${paintTimeout.inMilliseconds}ms...',
        );
      }

      while (boundary.debugNeedsPaint && paintStopwatch.elapsed < paintTimeout) {
        await _waitForPaint();
        // Pequeña espera para conceder frames extra antes de desistir.
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (boundary.debugNeedsPaint) {
        debugPrint(
          '[CardCaptureService] El widget no se pintó tras esperar '
          '${paintTimeout.inMilliseconds}ms',
        );
        return null;
      }

      if (boundary.layer == null) {
        debugPrint('[CardCaptureService] RenderRepaintBoundary no tiene capa para pintar');
        return null;
      }

      // Capturar la imagen con tamaño real (1080x1920) y pixelRatio 1.0
      final image = await boundary.toImage(pixelRatio: 1.0);
      
      // Convertir a bytes PNG
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('[CardCaptureService] No se pudo convertir la imagen a bytes');
        return null;
      }

      return CapturedCardImage(
        bytes: byteData.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
    } catch (e, stackTrace) {
      debugPrint('[CardCaptureService] Error al capturar widget: $e');
      debugPrint('[CardCaptureService] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Espera a que el próximo frame sea pintado.
  Future<void> _waitForPaint() async {
    final completer = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    await completer.future;
  }

  /// Guarda los bytes de una imagen en un archivo temporal.
  /// 
  /// Retorna la ruta del archivo guardado, o null si falla.
  Future<String?> saveImageToTemp(
    Uint8List imageBytes, {
    String filename = 'pokemon_card.png',
  }) async {
    try {
      final normalizedFilename =
          filename.toLowerCase().endsWith('.png') ? filename : '$filename.png';

      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$normalizedFilename';
      
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
  /// Retorna el resultado del intento de compartir la imagen.
  Future<ShareResult> shareImage(
    String imagePath, {
    String? text,
  }) async {
    if (!await canShareFiles) {
      final platformLabel = kIsWeb ? 'Web' : Platform.operatingSystem;
      debugPrint(
        '[CardCaptureService] Compartir omitido: plataforma no soportada ($platformLabel).',
      );
      return ShareResult.unavailable;
    }

    try {
      debugPrint('[CardCaptureService] Preparando archivo para compartir: $imagePath');
      final xFile = XFile(
        imagePath,
        mimeType: 'image/png',
      );

      final result = await Share.shareXFiles(
        [xFile],
        subject: text,
        text: text,
      );

      debugPrint('[CardCaptureService] Resultado de compartir: ${result.status}');
      return result;
    } catch (e, stackTrace) {
      debugPrint('[CardCaptureService] Error al compartir imagen: $e');
      debugPrint('[CardCaptureService] StackTrace: $stackTrace');
      return ShareResult.unavailable;
    }
  }

  /// Método todo-en-uno: captura un widget, lo guarda y lo comparte.
  ///
  /// [key] es el GlobalKey del RepaintBoundary que envuelve el widget.
  /// [filename] es el nombre del archivo temporal (por defecto: pokemon_card.png).
  /// [text] es un texto opcional para acompañar la imagen al compartir.
  /// [paintTimeout] permite ajustar el tiempo máximo de espera según el
  /// dispositivo o las pruebas.
  ///
  /// Retorna true si todo el proceso fue exitoso, false si hubo algún error.
  Future<bool> captureAndShare(
    GlobalKey key, {
    String filename = 'pokemon_card.png',
    String? text,
    Duration paintTimeout = const Duration(seconds: 5),
  }) async {
    // 1. Capturar el widget como imagen
    final capturedImage = await captureWidget(
      key,
      paintTimeout: paintTimeout,
    );
    if (capturedImage == null) {
      debugPrint('[CardCaptureService] Falló la captura del widget');
      return false;
    }

    final hasFullHdSize =
        capturedImage.width >= 1080 && capturedImage.height >= 1920;
    if (!hasFullHdSize) {
      debugPrint(
        '[CardCaptureService] Imagen capturada con tamaño incorrecto: '
        '${capturedImage.width}x${capturedImage.height}',
      );
      return false;
    }

    // 2. Guardar en archivo temporal
    final imagePath =
        await saveImageToTemp(capturedImage.bytes, filename: filename);
    if (imagePath == null) {
      debugPrint('[CardCaptureService] Falló al guardar la imagen capturada');
      return false;
    }

    final tempFile = File(imagePath);
    final exists = await tempFile.exists();
    if (!exists) {
      debugPrint(
        '[CardCaptureService] El archivo temporal no existe en la ruta: $imagePath',
      );
      return false;
    }

    // 3. Compartir usando el diálogo nativo
    final shareResult = await shareImage(imagePath, text: text);
    final shared = shareResult.status == ShareResultStatus.success;
    if (!shared) {
      debugPrint(
        '[CardCaptureService] Falló el envío del archivo. Estado: ${shareResult.status}',
      );
      return false;
    }

    return true;
  }

  /// Indica si la plataforma actual soporta compartir archivos.
  Future<bool> get canShareFiles async {
    if (kIsWeb) {
      // Web sharing is handled by share_plus internally
      return true;
    }

    final isMobile = Platform.isAndroid || Platform.isIOS;
    final isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    return isMobile || isDesktop;
  }
}
