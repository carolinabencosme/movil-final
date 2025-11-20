# Share Feature

Este módulo implementa la funcionalidad de compartir tarjetas de Pokémon como imágenes.

## Estructura

- **widgets/pokemon_share_card.dart**: Widget que renderiza una tarjeta visual estilo "Pokémon Trading Card" con diseño optimizado para redes sociales (1080x1920).

- **services/card_capture_service.dart**: Servicio que convierte widgets en imágenes PNG y maneja el proceso de compartir usando el diálogo nativo del sistema.

## Uso

La funcionalidad está integrada en `DetailScreen` mediante un FloatingActionButton. Al presionarlo:

1. Se muestra un diálogo con vista previa de la tarjeta
2. El usuario puede compartir la tarjeta usando el botón "Compartir"
3. Se captura el widget como imagen PNG de alta calidad
4. Se abre el diálogo nativo de compartir del sistema operativo

## Características de la tarjeta

- **Diseño Full HD (1080×1920)**: Optimizado para compartir en redes sociales con calidad profesional
- **Responsive y sin overflow**: Usa `FittedBox` y `Wrap` para adaptarse a cualquier tamaño de pantalla
- **Bordes redondeados modernos**: BorderRadius de 40px para un look profesional
- Imagen oficial del Pokémon centrada
- Nombre y número de Pokédex
- Badges de tipos con colores temáticos (usa `Wrap` para evitar overflow)
- Estadísticas principales (HP, ATK, DEF, SPD) (usa `Wrap` para adaptabilidad)
- Fondo degradado según el tipo del Pokémon
- Logo "ExploreDex" en el footer

## Diseño técnico

### PokemonShareCard Widget

El widget implementa un diseño de doble `FittedBox` para optimizar tanto la vista previa como la captura:

```dart
Center(
  child: FittedBox(  // Escala el contenedor completo
    fit: BoxFit.contain,
    child: Container(
      width: 1080,  // Dimensión fija para export Full HD
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(...),
        borderRadius: BorderRadius.circular(40),  // Bordes modernos
      ),
      child: Column(
        children: [
          // Imagen, nombre, tipos (Wrap), stats (Wrap), footer
        ],
      ),
    ),
  ),
)
```

### Prevención de overflow

- **Tipos**: Usa `Wrap` en lugar de `Row` con `spacing: 20` y `runSpacing: 12`
- **Stats**: Usa `Wrap` en lugar de `Row` con `spacing: 40` y `runSpacing: 20`
- **Preview en Dialog**: Envuelve la tarjeta en otro `FittedBox` para escalar a 300px de altura

### Captura y compartir

El proceso de captura funciona correctamente porque:
1. El `RepaintBoundary` captura el widget completo en sus dimensiones reales (1080×1920)
2. El `FittedBox` en el dialog solo afecta la visualización, no la captura
3. Se usa `pixelRatio: 3.0` para máxima calidad en la exportación

## Dependencias

- `share_plus`: Para compartir archivos mediante el diálogo nativo
- `path_provider`: Para guardar imágenes temporalmente
