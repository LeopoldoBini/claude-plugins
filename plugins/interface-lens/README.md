# interface-lens

Juzgar, diseñar y construir interfaces con psicología UX **más la brújula que las
listas de heurísticas no traen**: un eje ético (ético → persuasivo → oscuro) y la
prueba del arrepentimiento de Nir Eyal.

## La idea en una línea

La psicología del enganche (bucle disparador→acción→recompensa→inversión, dopamina,
recompensas variables) es un **motor** que sirve para dos fines opuestos: capturar al
usuario o servirlo. Este plugin encapsula el motor como conocimiento de referencia y
pone el juicio de dirección en el centro de las cuatro skills.

## Skills (cuatro verbos, invocación explícita)

| Skill | Verbo | Qué hace |
|---|---|---|
| `/ui-judge` | **Juzgar** | Audita screenshot/URL/código contra 37 principios en 7 familias (A–G). Hallazgos con evidencia concreta, score por familia, banderas de dark patterns, fixes priorizados. |
| `/ux-design` | **Diseñar** | Propone flujos mapeados al bucle, declarando qué principio usa cada decisión y por qué sirve al usuario. Guardas éticas y trade-offs obligatorios. |
| `/ab-variant` | **Variar** | Convierte una pantalla de decisión en un par A|B: nombra la pregunta que le hace al usuario, la canjea por una más fácil y deriva deltas mínimos con principio, gate ético e implementación. |
| `/dark-pattern-scan` | **Construir** | Escaneo adversarial pre-ship: rastrea flujos (suscripción, checkout, consentimiento), mide asimetría de fricción entrada/salida, reporte pasa/falla con evidencia por línea. |

## Estructura

```
interface-lens/
  CONTEXT.md                 ← lenguaje compartido: bucle, eje ético, escalas, el par
  references/
    principles.md            ← catálogo de 37 principios (familias A–G)
    dark-patterns.md         ← taxonomía operativa con señales de código por patrón
    ab-pairs.md              ← método de la familia G: la pregunta, el canje, los deltas
  skills/
    ui-judge/  ux-design/  ab-variant/  dark-pattern-scan/
```

## Principios de diseño del plugin

- **Evidencia o nada:** ningún hallazgo sin elemento concreto, cita o `archivo:línea`. El prompting genérico contra heurísticas ronda 50–75% de precisión; el anclaje a evidencia es lo que lo sube.
- **Flujos, no pantallas:** los dark patterns más graves (roach motel, forced continuity) solo emergen en la interacción — por eso el scan rastrea rutas de entrada/salida en el código.
- **Honestidad sobre límites:** cada auditoría declara qué NO pudo evaluarse desde el input recibido.
- **Norte time-well-spent:** tarea cumplida bien, no tiempo en app.
- **Un cambio atribuible:** un par A|B con la presentación como única variable enseña algo; un rediseño entero no, porque el resultado no se puede atribuir a nada.

## Vecinos

Complementa (no solapa) a `ui-ux-pro-max` (design intelligence visual: estilos,
paletas, layout): ese cubre *cómo se ve*; interface-lens cubre *cómo se comporta y
su ética*.

## Origen

Destilado de dos videos de uxpeak del acervo — *"The UX Psychology Behind Apps People
Can't Stop Using"* (`2TlIg3VokY8`, familias A–F) y *"Top 3 UX/UI Redesigns"*
(`zr37ibqXl1U`, familia G y el método del par) —, cruzado con BJ Fogg (B=MAP), Nir Eyal
(*Hooked*), [Laws of UX](https://lawsofux.com/) (Jon Yablonski), Kahneman & Tversky y
Cialdini, más la capa ética (taxonomía de dark patterns, prueba del arrepentimiento,
time-well-spent). Las citas por familia están en `references/`.
