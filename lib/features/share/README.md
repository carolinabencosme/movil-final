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

- Imagen oficial del Pokémon centrada
- Nombre y número de Pokédex
- Badges de tipos con colores temáticos
- Estadísticas principales (HP, ATK, DEF)
- Fondo degradado según el tipo del Pokémon
- Sombras y efectos visuales profesionales

## Dependencias

- `share_plus`: Para compartir archivos mediante el diálogo nativo
- `path_provider`: Para guardar imágenes temporalmente
