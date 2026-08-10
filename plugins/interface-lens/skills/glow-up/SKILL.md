---
name: glow-up
description: Glow-up de una vista: la deja hermosa y más funcional editando el código — adopta el sistema del proyecto, aplica craft visual y los principios de decisión, y la verifica corriendo con screenshot del antes y el después.
disable-model-invocation: true
---

# /glow-up — dejala hermosa y que funcione mejor

Te pasan una vista y la devolvés **mejorada y andando**. No auditás, no puntuás, no
listás lo que está mal: editás el código y mostrás el resultado.

Dos pases sobre la misma vista: **el visual** (que se vea terminada) y **el funcional**
(que sea más fácil de usar y de decidir). Los dos se aplican; ninguno se reporta como
diagnóstico.

## Paso 0 — Cargar el cómo

1. `${CLAUDE_PLUGIN_ROOT}/references/craft.md` — las diez reglas del pase visual y los antipatrones. Es tu lista de ejecución.
2. `${CLAUDE_PLUGIN_ROOT}/references/ab-pairs.md`, sección **los siete lugares donde vive un delta** — el pase funcional.

`principles.md` solo si necesitás el nombre canónico de un principio para explicar un
cambio. Nada más se lee.

## Paso 1 — Ubicar la vista y su sistema

Identificá los archivos que la componen (componente, estilos, tokens, datos que recibe).
Si el input es un screenshot o una URL sin código, pedí la ruta del componente: sin
código no hay glow-up, hay opinión.

Después extraé del proyecto, **antes de tocar nada**:

| Qué | Dónde mirar |
|---|---|
| Tokens de color, radios, sombras | `tailwind.config.*`, CSS custom properties, tema de shadcn |
| Escala tipográfica y fuentes cargadas | config de Tailwind, `@font-face`, `<link>` de fuentes, layout raíz |
| Componentes que ya resuelven el patrón | carpeta de UI del proyecto (`components/ui`, design system interno) |
| Cómo se ve el resto de la app | dos o tres vistas vecinas ya terminadas |

Cerrás el paso con la lista de tokens y componentes que vas a **reutilizar**. Un valor
nuevo entra solo si ninguno existente sirve, y entra como token del sistema. Una vista
con paleta propia desentona con la app entera, aunque aislada se vea mejor.

## Paso 2 — Ver el antes

Levantá la app y sacá screenshot de la vista como está (usá el runner del proyecto; si
hay skill de `run` o Playwright disponible, esa). Guardalo.

Si la vista no se puede levantar (falta backend, datos, credenciales), decilo en una
línea y seguí desde el código — pero probá primero.

## Paso 3 — Pase visual

Aplicá `craft.md` en su orden, editando los archivos. Los cuatro que más mueven el
resultado, si hay que priorizar: **espaciado por grupos**, **jerarquía de tres niveles
con un solo primario**, **estados completos** (hover, focus-visible, active, disabled,
loading, vacío, error) y **contraste de texto**.

Barré también los antipatrones de `craft.md`: si la vista tiene emojis como iconos,
sombra + borde en la misma tarjeta, cinco tamaños de fuente sueltos o todo el texto en
el mismo gris, eso sale.

El paso cierra cuando las diez reglas de `craft.md` están **aplicadas o descartadas con
motivo** (ej.: "movimiento: no hay transiciones que agregar acá"). Recorrelas de una a
diez sin saltear.

## Paso 4 — Pase funcional

Recorré los siete lugares de `ab-pairs.md` sobre la vista y aplicá el que corresponda:

1. **Campos vacíos → defaults** con la opción más común pre-seleccionada.
2. **Control principal** que diga qué pasa al tocarlo, en verbo de comienzo ("Ver 12 resultados", "Empezar"), no genérico ("Enviar", "Buscar").
3. **Rangos y promesas vagas → número exacto** cuando el dato existe ("5 noches", "en 2 pasos").
4. **El total donde se decide**, no en la pantalla siguiente.
5. **La objeción obvia contestada en pantalla**, en una línea (qué pasa si cancelo, cuándo se cobra, si puedo cambiarlo).
6. **El progreso nunca en cero** cuando el usuario ya hizo algo: contá lo hecho como paso 1.
7. **Imágenes que muestren la cosa**, no que decoren el espacio.

**Regla de construcción:** todo dato que muestres sale de datos reales del producto. Si
el dato no existe, el elemento no se pone.

## Paso 5 — Verificar corriendo

1. Screenshot del **después**, misma vista, mismo viewport.
2. Repetir en **360px** de ancho: sin scroll horizontal, sin nada cortado.
3. Recorrer con **teclado**: cada control alcanzable y con foco visible.
4. Chequear que la app compila y que la vista no perdió funcionalidad (los handlers siguen conectados, los datos siguen llegando).

Si el después no se ve mejor que el antes, no terminó el trabajo: volvé al Paso 3. El
screenshot es el criterio, no tu descripción del cambio.

## Paso 6 — Entregar

Corto y sin diagnóstico:

```
## Antes / después
Los dos screenshots. Si no se pudo levantar la app, decirlo acá en una línea.

## Qué cambió
Lista de una línea por cambio, agrupada en "se ve" y "se usa".
Cada línea nombra el elemento concreto, no el principio.

## Del sistema
Tokens y componentes reutilizados; y los valores nuevos que hubo que agregar, si hubo.

## Si querés seguir
Máximo tres cosas que quedaron afuera por alcance, en una línea cada una.
```

Sin score, sin tabla de familias, sin sección de trade-offs. El entregable es la vista
funcionando mejor; el texto solo dice qué le hiciste.

Cuando la vista es de conversión y querés **testear** una presentación contra otra en vez
de mejorarla de una, eso es `/ab-variant`.
