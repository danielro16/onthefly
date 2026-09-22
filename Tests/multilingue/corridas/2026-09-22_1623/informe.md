# Jev en páginas reales — 2026-09-22_1623

6 casos · idiomas en, ja, pt · semilla 2 · Jev contra gemini-3.1-flash-lite · 235 s en total

## Resumen

- **¿Cuál lleva a lo pedido?** Jev y Gemini coinciden en 5 de 6.
- **¿Está en la página?** 6 de 6.
- **Jev:** mediana 34.57 s por página, US$0.01169 en total, 2 pedidos fallidos.

**Ruido** (lo que marca Jev, medido contra lo que marca Gemini, según el umbral de Jev):

| umbral | precisión | cobertura | marcados |
|---|---|---|---|
| 0.5 | 44% | 11% | 95 |
| 0.6 | 53% | 5% | 38 |
| 0.75 | 43% | 1% | 7 |
| 0.9 | 100% | 0% | 0 |

**¿Cuál?** según la confianza de Jev (lo que se resolvería solo, y cuánto acierta):

| confianza ≥ | se resuelve solo | acierta |
|---|---|---|
| 0.3 | 6 de 6 | 5 de 6 |
| 0.5 | 6 de 6 | 5 de 6 |
| 0.7 | 3 de 6 | 2 de 3 |

## Casos

| caso | pedido | Jev: ¿cuál? (confianza) | Gemini | ¿está? Jev / Gemini / caso | ruido de Jev ≥0,75 | Jev |
|---|---|---|---|---|---|---|
| en-weather-com-b | Transfer fifty dollars from my checking to my savings account. | ✓ NINGUNO (0.97) | NINGUNO | 0.01 / no / no | 3: camping, Camping, Poor, C, golf, Golf, Good, Chevron, The Weather Company | 73.1 s |
| pt-g1-globo-com-b | Vê quanto de limite eu ainda tenho no meu cartão de crédito. | ✓ NINGUNO (0.66) | NINGUNO | 0.03 / no / no | 0:  | 37.1 s |
| pt-correios-com-br-a | Quero rastrear o meu objeto. | ✓ NINGUNO (0.85) | NINGUNO | 0.15 / no / sí | 3: Clique aqui e conheça o P, Clique e acesse o Correio, Acesse agora! | 0.6 s |
| en-amazon-com-b | Can you tell me if this item is currently in stock at my local physical store? | ✓ NINGUNO (0.68) | NINGUNO | 0.11 / no / no | 0:  | 34.6 s |
| ja-www3-nhk-or-jp-a | 最新のニュースの見出しを読んで。 | ✗ 新着・注目 (0.78) | 日米首脳会談 | 0.80 / sí / sí | 1: インストール | 0.7 s |
| en-chase-com-b | Can I see my personal transaction history for last month? | ✓ Sign in Opens overlay (0.59) | Sign in Opens overlay | 0.54 / sí / no | 0:  | 17.6 s |

## Para revisar a mano

Donde Jev y Gemini no coinciden. Cualquiera de los dos puede estar mal: decidí vos.

  - en-weather-com-b ruido sólo para Jev: ['camping, Camping, Poor, Chevro', 'golf, Golf, Good, Chevron Righ', 'The Weather Company']
  - en-weather-com-b ruido sólo para Gemini: ['Dismiss', 'Improve location precision', 'Map Attribution', 'Learn More', 'Weather Underground', 'Trust Center, External Link', 'Cookie Notice, External Link', 'Community Guidelines, External']
  - pt-g1-globo-com-b ruido sólo para Gemini: ['Menu', 'Botão de login Conta Globo', 'Mostrar mais conteúdos', 'Pular para o conteúdo', 'atalho página home', 'Últimas Notícias', 'destaques', 'região']
  - pt-correios-com-br-a ruido sólo para Jev: ['Clique aqui e conheça o Progra']
  - pt-correios-com-br-a ruido sólo para Gemini: ['Boletim aos Clientes', 'Conheça!']
  - en-amazon-com-b ruido sólo para Gemini: ['Join Prime', 'Play', 'Play', 'Play', 'Play', 'Play', 'Play', 'Play']
- **ja-www3-nhk-or-jp-a** «最新のニュースの見出しを読んで。» — ¿cuál?: Jev «新着・注目», Gemini ['日米首脳会談']
  - ja-www3-nhk-or-jp-a ruido sólo para Gemini: ['閉じる', 'エヌエイチケー', 'NHKについて', 'ご意見・お問い合わせ', 'プライバシーセンター', 'NHK ONE プライバシーノーティス', 'NHK ONE アカウント プライバシーノーティス', '放送番組と著作権']
  - en-chase-com-b ruido sólo para Gemini: ['US Open', 'Madison Square Garden', 'Facebook', 'Instagram', 'X, formerly Twitter', 'YouTube', 'LinkedIn', 'Pinterest']
