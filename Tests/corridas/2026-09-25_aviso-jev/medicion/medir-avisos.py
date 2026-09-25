#!/usr/bin/env python3
"""El tipo de aviso: la lista de palabras del extractor contra Jev (la pregunta «aviso» de la app)."""
import json, pathlib, sys, urllib.request, urllib.error
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import urlparse

RAIZ = pathlib.Path("/Users/daniel/Developer/JEF- BROWSER")
C = json.loads((RAIZ / "Sources/Intelligence/criterios.json").read_text())
KEY = next(l.split("=", 1)[1].strip() for l in (RAIZ / ".env").read_text().splitlines() if l.startswith("AI_GATEWAY_API_KEY="))
S = pathlib.Path(sys.argv[1])
ESPERADO = json.loads((S / "esperado.json").read_text())

def pregunta(k):
    q = C["jev"][k]
    return {"type": "choice", "instructions": q["instructions"], "criteria": q["criteria"]}

def estado(p):
    dom = urlparse(p["url"]).hostname or ""
    dom = dom[4:] if dom.startswith("www.") else dom
    heads = [b.get("text", "") for b in p.get("blocks", []) if b.get("type") == "heading" and b.get("text")][:12]
    text = " ".join(b.get("text", "") for b in p.get("blocks", []) if b.get("type") == "paragraph")[:1200]
    o = p["overlay"]
    items = [{"text": c["label"][:80], "kind": "button", "region": "overlay"} for c in o.get("choices", [])]
    items += [{"text": a["label"][:80], "kind": a["kind"], "region": a.get("region") or "main"} for a in p.get("actions", []) if a.get("label")]
    return {"domain": dom, "title": p.get("title", "")[:120], "headings": [h[:100] for h in heads], "text": text,
            "items": items[:30],
            "notice": {"text": o.get("text", "")[:600], "choices": [c["label"] for c in o.get("choices", [])],
                       "links": [l["label"] for l in (o.get("links") or [])]}}

def uno(f):
    p = json.loads((S / "paginas.json").read_text())[f]
    cuerpo = json.dumps({"model": "typesafe-ai/jev", "state": estado(p),
                         "questions": {"sitio": pregunta("sitio"), "pagina": pregunta("pagina"), "aviso": pregunta("aviso")}}).encode()
    r = urllib.request.Request("https://ai-gateway.vercel.sh/v1/evaluate", data=cuerpo,
        headers={"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"})
    import time
    for intento in range(4):
        try:
            with urllib.request.urlopen(r, timeout=40) as resp:
                a = json.load(resp)["answers"]["aviso"]
            break
        except urllib.error.HTTPError as e:
            if e.code not in (429, 503) or intento == 3: raise
            time.sleep(1.5 * (intento + 1))
    probs = a.get("probabilities", {})
    choice = a.get("choice") or max(probs, key=probs.get)
    return f, p["url"], p["overlay"].get("kind"), choice, a.get("confidence") or probs.get(choice, 0)

with ThreadPoolExecutor(4) as ex:
    res = list(ex.map(uno, ESPERADO.keys()))
umbral = C["umbrales"]["tipo"]
bien = {"lista": 0, "jev": 0, "jev_seguro": 0}
equiv = {"app": "other", "promo": "other"}  # lo que la app trata igual: se cierra
for f, url, lista, jev, p in res:
    esp = ESPERADO[f] if isinstance(ESPERADO[f], list) else [ESPERADO[f]]
    ok_l = equiv.get(lista, lista) in [equiv.get(e, e) for e in esp]
    ok_j = equiv.get(jev, jev) in [equiv.get(e, e) for e in esp]
    esp = "/".join(esp)
    bien["lista"] += ok_l; bien["jev"] += ok_j; bien["jev_seguro"] += ok_j and p >= umbral
    print(f"{url[:42]:42} esperado {esp:10} | lista {lista:10} {'✓' if ok_l else '✗'} | Jev {jev:10} {p:.2f} {'✓' if ok_j else '✗'}")
print(len(res), "avisos · aciertos", bien, "· umbral", umbral)
