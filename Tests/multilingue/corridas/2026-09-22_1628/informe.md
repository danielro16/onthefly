# Jev en páginas reales — 2026-09-22_1628

6 casos · idiomas en, ja, pt · semilla 8889 · Jev contra gemini-3.1-flash-lite · 105 s en total

## Resumen

- **¿Cuál lleva a lo pedido?** Jev y Gemini coinciden en 5 de 6.
- **¿Está en la página?** 5 de 6.
- **Jev:** mediana 4.94 s por página, US$0.00730 en total, 0 pedidos fallidos.

**Ruido** (lo que marca Jev, medido contra lo que marca Gemini, según el umbral de Jev):

| umbral | precisión | cobertura | marcados |
|---|---|---|---|
| 0.5 | 62% | 36% | 94 |
| 0.6 | 69% | 25% | 59 |
| 0.75 | 84% | 17% | 32 |
| 0.9 | 83% | 3% | 6 |

**¿Cuál?** según la confianza de Jev (lo que se resolvería solo, y cuánto acierta):

| confianza ≥ | se resuelve solo | acierta |
|---|---|---|
| 0.3 | 6 de 6 | 5 de 6 |
| 0.5 | 6 de 6 | 5 de 6 |
| 0.7 | 4 de 6 | 3 de 4 |

## Casos

| caso | pedido | Jev: ¿cuál? (confianza) | Gemini | ¿está? Jev / Gemini / caso | ruido de Jev ≥0,75 | Jev |
|---|---|---|---|---|---|---|
| en-weather-com-b | Transfer fifty dollars from my checking to my savings account. | ✓ NINGUNO (1.00) | NINGUNO | 0.01 / no / no | 10: Terms of Use, Cookie Notice, External L, AdChoices, Facebook, Instagram | 2.1 s |
| pt-g1-globo-com-b | Vê quanto de limite eu ainda tenho no meu cartão de crédito. | ✓ NINGUNO (0.68) | NINGUNO | 0.16 / no / no | 2: Assine Coquetel, Mercado Pago | 18.1 s |
| ja-www3-nhk-or-jp-a | 最新のニュースの見出しを読んで。 | ✗ 新着・注目 (0.86) | 日米首脳会談 | 0.74 / sí / sí | 1: インストール | 5.5 s |
| en-chase-com-b | Can I see my personal transaction history for last month? | ✓ Sign in Opens overlay (0.81) | Sign in Opens overlay | 0.45 / sí / no | 13: Zelle®, Facebook, Instagram, X, formerly Twitter, YouTube | 4.9 s |
| en-amazon-com-b | Can you tell me if this item is currently in stock at my local physical store? | ✓ NINGUNO (0.59) | NINGUNO | 0.10 / no / no | 3: Leave feedback on Sponsor, Leave feedback on Sponsor, Sponsored Ad | 2.5 s |
| pt-correios-com-br-a | Quero rastrear o meu objeto. | ✓ NINGUNO (1.00) | NINGUNO | 0.15 / no / sí | 3: Clique aqui e conheça o P, Clique e acesse o Correio, Acesse agora! | 0.5 s |

## Para revisar a mano

Donde Jev y Gemini no coinciden. Cualquiera de los dos puede estar mal: decidí vos.

  - en-weather-com-b ruido sólo para Jev: ['golf, Golf, Good, Chevron Righ']
  - en-weather-com-b ruido sólo para Gemini: ['Dismiss', 'Improve location precision', 'Map Attribution', 'More', 'lightning Upgrade', 'Trust Center, External Link', 'Privacy Policy', 'Data Rights']
- **ja-www3-nhk-or-jp-a** «最新のニュースの見出しを読んで。» — ¿cuál?: Jev «新着・注目», Gemini ['日米首脳会談']
  - ja-www3-nhk-or-jp-a ruido sólo para Gemini: ['閉じる', 'エヌエイチケー', 'NHKについて', 'ご意見・お問い合わせ', 'プライバシーセンター', 'NHK ONE プライバシーノーティス', 'NHK ONE アカウント プライバシーノーティス', '放送番組と著作権']
  - en-chase-com-b ruido sólo para Jev: ['Zelle®', 'J.P. Morgan', 'JPMorganChase']
  - en-chase-com-b ruido sólo para Gemini: ['Site Map', 'Privacy', 'Accessibility', 'Give feedback']
  - en-amazon-com-b ruido sólo para Gemini: ['Play', 'Play', 'Play', 'Play', 'Play', 'Play', 'Play', 'Play']
  - pt-correios-com-br-a ruido sólo para Jev: ['Clique aqui e conheça o Progra']
