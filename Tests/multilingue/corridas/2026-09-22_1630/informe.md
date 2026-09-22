# Jev en páginas reales — 2026-09-22_1630

6 casos · idiomas en, es · semilla 5 · Jev contra gemini-3.1-flash-lite · 85 s en total

## Resumen

- **¿Cuál lleva a lo pedido?** Jev y Gemini coinciden en 5 de 6.
- **¿Está en la página?** 5 de 6.
- **Jev:** mediana 2.78 s por página, US$0.00543 en total, 0 pedidos fallidos.
- **Gemini haciendo lo mismo:** mediana 2.0 s por página, US$0.00846 en total.

**Ruido** (lo que marca Jev, medido contra lo que marca Gemini, según el umbral de Jev):

| umbral | precisión | cobertura | marcados |
|---|---|---|---|
| 0.5 | 85% | 41% | 92 |
| 0.6 | 88% | 30% | 64 |
| 0.75 | 94% | 18% | 36 |
| 0.9 | 100% | 1% | 1 |

**¿Cuál?** según la confianza de Jev (lo que se resolvería solo, y cuánto acierta):

| confianza ≥ | se resuelve solo | acierta |
|---|---|---|
| 0.3 | 5 de 6 | 5 de 5 |
| 0.5 | 4 de 6 | 4 de 4 |
| 0.7 | 4 de 6 | 4 de 4 |

## Casos

| caso | pedido | Jev: ¿cuál? (confianza) | Gemini | ¿está? Jev / Gemini / caso | ruido de Jev ≥0,75 | Jev |
|---|---|---|---|---|---|---|
| en-usa-gov-a | How do I renew my passport? | ✓ Get or renew a passport (1.00) | Get or renew a passport | 0.91 / sí / sí | 0:  | 2.5 s |
| en-mayoclinic-org-a | Give me information about the symptoms of high blood pressure. | ✗ NINGUNO (0.07) | Search | 0.25 / sí / sí | 11: X, YouTube, Facebook, LinkedIn, Instagram | 5.0 s |
| es-elpais-com-b | Quiero comprar unos zapatos de talla cuarenta. | ✓ NINGUNO (1.00) | NINGUNO | 0.02 / no / no | 2: CAF, OEI | 17.6 s |
| en-pge-com-a | Report a power outage in my area. | ✓ Outages (0.90) | Outages | 0.63 / sí / sí | 2: Twitter, LinkedIn | 1.2 s |
| en-chase-com-a | What are the current interest rates for a savings account? | ✓ see interest rates (0.45) | see interest rates | 0.78 / sí / sí | 11: Zelle®, Facebook, Instagram, X, formerly Twitter, YouTube | 2.5 s |
| en-khanacademy-org-a | I want to start a course on computer programming. | ✓ Computing (0.82) | Computing | 0.65 / sí / sí | 10: Select gift frequency [Se, Give now, Download the Khan Academy, Get the Khan Academy app , Follow us on LinkedIn | 2.8 s |

## Para revisar a mano

Donde Jev y Gemini no coinciden. Cualquiera de los dos puede estar mal: decidí vos.

  - en-usa-gov-a ruido sólo para Gemini: ["Here's how you know", 'Español', 'Menu', 'Government information', 'About us', 'For federal agencies', 'vote.gov', 'USAGov Logo']
- **en-mayoclinic-org-a** «Give me information about the symptoms of high blood pressure.» — ¿cuál?: Jev «NINGUNO», Gemini ['Search', 'H. Find a disease or condition that starts with the letter H']
  - en-mayoclinic-org-a ruido sólo para Gemini: ['Feedback', 'Give Today', 'Sign up for free e-newsletters', 'Privacy Policy', 'Advertising and Sponsorship Po', 'Site Map', 'Manage Cookies']
  - es-elpais-com-b ruido sólo para Jev: ['CAF', 'OEI']
  - es-elpais-com-b ruido sólo para Gemini: ['Desplegar menú', 'SUSCRÍBETE', 'Iniciar sesión', 'Suscríbase al boletín de Améri', 'Americanas: historias con enfo', 'Siga la actualidad de Chile en', 'Las grandes noticias y reporta', 'LOS40 USA']
  - en-pge-com-a ruido sólo para Gemini: ['Do not sell my personal inform', 'Explore our Sustainability Rep', 'Check out Currents Magazine', 'Giving Locally', 'Educational Resources', 'First Responder Resources', 'Careers', 'In Your Community']
  - en-chase-com-a ruido sólo para Gemini: ['Open side menu', 'Open an account', 'Chase logo, links to Chase hom', 'Sign in Opens overlay', 'credit cards', 'offer rewards', 'cash back', 'free credit score']
  - en-khanacademy-org-a ruido sólo para Gemini: ['Dismiss banner.', 'close', 'Change language', 'Cookie Preferences', 'Khan Academy Districts (opens ', 'Khan Kids for Schools (opens i', 'Khan Academy for Teachers (ope', 'Writing Coach (opens in a new ']
