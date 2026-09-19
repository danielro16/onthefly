# Jev (TypeSafe) vía Vercel AI Gateway — referencia

> "JEF" = **Jev**, el modelo de TypeSafe AI. No es un LLM.

## Qué es

Jev es un **System One model**: no genera texto. Evalúa un `state` contra
**preguntas tipadas** y devuelve valores estructurados con probabilidades
calibradas. Sin prompt engineering, sin parsear JSON de un LLM.

- Context window: 32.000 tokens
- Modalidad en AI Gateway: `evaluation` · model id `typesafe-ai/jev`
- Precio: **$0.042 / 1M input tokens**, output **$0** (~1000x más barato que un LLM)
- ZDR y no-training: ambos `all`
- Versión del modelo: jev-1.13.x

## Los tres primitivos

| Tipo | En AI Gateway | En TypeSafe nativo | Devuelve |
|---|---|---|---|
| Sí/no | `boolean` | `noul` | `probability` 0–1 |
| Elegir una opción | `choice` | `choice` | `choice` + `probabilities` por opción |
| Calificar en escala | `score` | `score` | `score` interpolado + `probabilities` por nivel |

Varias preguntas se responden **en paralelo en un solo request**, contra el mismo state.

## Dos caminos (misma key `AI_GATEWAY_API_KEY`)

### A. Endpoint nativo del Gateway — para código nuevo

```bash
curl https://ai-gateway.vercel.sh/v1/evaluate \
  -H "Authorization: Bearer $AI_GATEWAY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "typesafe-ai/jev",
    "state": "Me cobraron dos veces la suscripción.",
    "questions": {
      "refund":  { "type": "boolean", "instructions": "¿Pide plata de vuelta?" },
      "route":   { "type": "choice",  "instructions": "Rutear el ticket.",
                   "criteria": { "billing": "cobros", "technical": "bugs" } },
      "urgency": { "type": "score",   "instructions": "Qué tan urgente.",
                   "criteria": ["low", "medium", "high"] }
    }
  }'
```

Respuesta:
```json
{
  "model": "typesafe-ai/jev",
  "answers": {
    "refund":  { "type": "boolean", "probability": 0.98 },
    "route":   { "type": "choice", "choice": "billing",
                 "probabilities": { "billing": 1, "technical": 0 } },
    "urgency": { "type": "score", "score": 2.1,
                 "probabilities": { "0": 0, "1": 0.9, "2": 0.1 } }
  },
  "usage": { "inputTokens": 275, "outputTokens": 20 }
}
```

AI SDK (requiere **AI SDK 7+**; no funciona por los endpoints OpenAI/Anthropic-compatible):

```typescript
import { experimental_evaluate as evaluate } from 'ai';

const result = await evaluate({
  model: 'typesafe-ai/jev',
  state: 'The build failed with exit code 1.',   // string, objeto o array
  questions: {
    passed: {
      type: 'boolean',
      instructions: 'Did the build succeed?',
      criteria: { true: 'exit code 0', false: 'any non-zero exit code' },
    },
  },
});
// result.answers.passed -> { type: 'boolean', probability: 0.01 }
```

Con instancia del provider: `gateway.evaluationModel('typesafe-ai/jev')`.

### B. Passthrough TypeSafe — para migrar código que ya usa el SDK de TypeSafe

Base URL: `https://ai-gateway.vercel.sh/typesafe`

```typescript
const client = new TypeSafeClient({
  apiKey: process.env.AI_GATEWAY_API_KEY,          // no TYPESAFE_API_KEY
  baseURL: 'https://ai-gateway.vercel.sh/typesafe',
});
```

- `POST /typesafe/v1/systemone` — evalúa
- `GET /typesafe/v1/models` — lista modelos de evaluación

Usa los nombres de campo de TypeSafe (`noul` en vez de `boolean`, `input_tokens`
en vez de `inputTokens`).

## API nativa de TypeSafe (sin gateway)

`POST https://api.typesafe.ai/v1/systemone` con `TYPESAFE_API_KEY`, model
`jev-latest`. SDKs: `pip install typesafe-sdk` / `@typesafe-ai/sdk`.
Dashboard de keys: https://console.typesafe.ai/keys

## Reglas de diseño

- **Un juicio por campo.** Preguntas multi-parte → confianza baja.
- **El contexto va en la pregunta, no en el prompt.** El `state` es el material
  a juzgar; `instructions` + `criteria` enmarcan qué se juzga.
- **`confidence`** es distinto de `probability`: mide certeza del modelo.
  Patrón: rutear a revisión humana cuando la confianza cae bajo un umbral.

## Lo que Jev NO hace

- Generar texto, imágenes, audio
- Aritmética y cálculos de fechas
- Razonamiento multi-paso
- Resistir inyección adversarial en el texto
- Responder si el contexto necesario no está en el `state`

## Links

- Docs TypeSafe: https://docs.typesafe.ai/introduction · API: https://docs.typesafe.ai/api.md
- Índice completo para agentes: https://docs.typesafe.ai/llms.txt
- Evaluation en AI Gateway: https://vercel.com/docs/ai-gateway/modalities/evaluation
- Passthrough TypeSafe: https://vercel.com/docs/ai-gateway/sdks-and-apis/typesafe
- Pydantic AI: https://pydantic.dev/docs/ai/models/typesafe/
- Cookbooks (18 recetas): https://docs.typesafe.ai/cookbooks/ — guardrails para LLMs,
  re-ranking, function calling, clasificación jerárquica, chequeo de citas, etc.

## Skill para Claude Code

```
claude plugin marketplace add typesafe-ai/skills
claude plugin install typesafe@typesafe-ai
```
Invocar con `/typesafe:typesafe-ai`.
