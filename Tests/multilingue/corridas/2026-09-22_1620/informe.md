# Jev en páginas reales — 2026-09-22_1620

6 casos · idiomas ar, de, es, hi, pt · semilla 1 · referencia gemini-3.1-pro-preview · 49 s en total

## Resumen

- **¿Cuál lleva a lo pedido?** Jev coincide con la referencia en 2 de 6.
- **¿Está en la página?** 2 de 2.
- **Jev:** mediana 5.61 s por página, US$0.00343 en total, 33 pedidos fallidos.

**Ruido** (qué marca Jev contra la referencia, según el umbral):

| umbral | precisión | cobertura | marcados |
|---|---|---|---|
| 0.5 | 67% | 4% | 3 |
| 0.6 | 100% | 2% | 1 |
| 0.75 | 100% | 2% | 1 |
| 0.9 | 100% | 0% | 0 |

**¿Cuál?** según la confianza de Jev (lo que se resolvería solo, y cuánto acierta):

| confianza ≥ | se resuelve solo | acierta |
|---|---|---|
| 0.3 | 2 de 6 | 2 de 2 |
| 0.5 | 0 | — |
| 0.7 | 0 | — |

## Casos

| caso | pedido | Jev: ¿cuál? | referencia | ¿está? Jev / ref / caso | ruido ≥0,75 | Jev |
|---|---|---|---|---|---|---|
| pt-g1-globo-com-a | Lê as manchetes principais de hoje para mim. | ✗ NINGUNO (0.00) | Cantor Rick e mais 4 morrem após queda de helicóptero em SC; | — | 0:  | 5.6 s |
| de-spiegel-de-b | Bestell mir ein neues Paar Laufschuhe in Größe zweiundvierzig. | ✓ NINGUNO (0.33) | NINGUNO | 0.11 / no / no | 0:  | 6.4 s |
| ar-almasryalyoum-com-b | عايز أحجز تذكرة طيران لباريس. | ✓ NINGUNO (0.48) | NINGUNO | 0.11 / no / no | 1: بريدك الالكتروني [بريدك ا | 6.0 s |
| ar-almasryalyoum-com-a | اقرأ لي أهم العناوين والأخبار في الصفحة الرئيسية. | ✗ NINGUNO (0.00) | بيان مشترك بين «التمريض» وجامعة المنوفية بشأن واقعة الاعتداء | — | 0:  | 5.6 s |
| es-elpais-com-b | Quiero comprar unos zapatos de talla cuarenta. | ✗ NINGUNO (0.00) | NINGUNO | — | 0:  | 5.4 s |
| hi-aajtak-in-b | नई दिल्ली से मुंबई के लिए ट्रेन की टिकट बुक कर दो। | ✗ NINGUNO (0.00) | NINGUNO | — | 0:  | 5.5 s |

## Para revisar a mano

Donde Jev y la referencia no coinciden. La referencia también se equivoca: decidí vos.

- **pt-g1-globo-com-a** «Lê as manchetes principais de hoje para mim.» — ¿cuál?: Jev «NINGUNO», referencia ['Cantor Rick e mais 4 morrem após queda de helicóptero em SC;', "Na ONU, Lula defende soberania e diz que Brasil 'não cabe no", "'Tá aqui': câmera flagra momento em que PM acha menino perdi"]
  - pt-g1-globo-com-a ruido sólo para la referencia: ['App g1', 'Termos de uso do g1', 'Política de privacidade']
  - de-spiegel-de-b ruido sólo para la referencia: ['Werbung', 'Branded Partnerships', 'Impressum', 'Datenschutz', 'Barrierefreiheit', 'Nutzungsbedingungen', 'Teilnahmebedingungen', 'Vertrag kündigen']
  - ar-almasryalyoum-com-b ruido sólo para la referencia: ['حقوق النشر', 'سياسة النشر', 'Enlace sin nombre', 'Enlace sin nombre', 'Enlace sin nombre']
- **ar-almasryalyoum-com-a** «اقرأ لي أهم العناوين والأخبار في الصفحة الرئيسية.» — ¿cuál?: Jev «NINGUNO», referencia ['بيان مشترك بين «التمريض» وجامعة المنوفية بشأن واقعة الاعتداء', 'بعد اجتماع 3 ساعات.. ماذا وراء التحرك الجديد بين أمريكا وإير', 'تحركات حكومية لحل أزمة المعلمين المصريين المستغنى عنهم بالكو']
  - ar-almasryalyoum-com-a ruido sólo para la referencia: ['بريدك الالكتروني [بريدك الالكت', 'حقوق النشر', 'سياسة النشر', 'Enlace sin nombre', 'Enlace sin nombre', 'Enlace sin nombre']
- **es-elpais-com-b** «Quiero comprar unos zapatos de talla cuarenta.» — ¿cuál?: Jev «NINGUNO», referencia NINGUNO
  - es-elpais-com-b ruido sólo para la referencia: ['SUSCRÍBETE', 'Suscríbase al boletín de Améri', 'Siga la actualidad de Chile en', 'nuestros socios', 'Ver nuestros 1032 socios', 'Configuración: Configura tus c', 'Aceptar: Aceptar nuestro proce']
- **hi-aajtak-in-b** «नई दिल्ली से मुंबई के लिए ट्रेन की टिकट बुक कर दो।» — ¿cuál?: Jev «NINGUNO», referencia NINGUNO
  - hi-aajtak-in-b ruido sólo para la referencia: ['Later', 'Allow', 'Advertise with us', 'Privacy Policy', 'Terms and Conditions', 'T&Cs for AajTak HD Contest', 'AajTak Hindi News as prefer us', 'Follow us on']
