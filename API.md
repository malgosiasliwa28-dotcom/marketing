# Marketing Hub API

Aplikacja ma endpoint do dodawania elementów z zewnętrznych systemów:

```txt
POST https://marketingspace.netlify.app/.netlify/functions/create-item
```

## Wymagane zmienne w Netlify

W Netlify -> Site configuration -> Environment variables dodaj:

```txt
SUPABASE_URL=https://iztypjpbyxkswbrerbpl.supabase.co
SUPABASE_SERVICE_ROLE_KEY=TU_WKLEJ_SERVICE_ROLE_KEY_Z_SUPABASE
MARKETING_API_TOKEN=TU_WPISZ_WLASNY_DLUGI_TOKEN_API
```

Opcjonalnie:

```txt
MARKETING_DEFAULT_OWNER_ID=UUID_UZYTKOWNIKA_Z_SUPABASE
```

Nie dodawaj `SUPABASE_SERVICE_ROLE_KEY` do GitHuba. To ma być tylko w Netlify Environment Variables.

## Przykład dodania wydarzenia

```bash
curl -X POST "https://marketingspace.netlify.app/.netlify/functions/create-item" \
  -H "Authorization: Bearer TU_WPISZ_MARKETING_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "event",
    "visibility": "team",
    "data": {
      "name": "Targi branżowe",
      "kind": "Targi",
      "calendar_bucket": "Targi",
      "date": "2026-09-10",
      "end_date": "2026-09-12",
      "status": "Plan",
      "place": "Warszawa",
      "description": "Wydarzenie dodane przez API."
    }
  }'
```

## Przykład dodania faktury / kosztu

```bash
curl -X POST "https://marketingspace.netlify.app/.netlify/functions/create-item" \
  -H "Authorization: Bearer TU_WPISZ_MARKETING_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "finance",
    "visibility": "team",
    "data": {
      "name": "Canva Pro",
      "marketing_for": "Narzędzie do grafik social media",
      "kind": "Subskrypcja",
      "amount": "55",
      "currency": "PLN",
      "status": "Automatycznie pobierane",
      "auto_charge": "Tak",
      "payment_method": "Automatycznie z karty"
    }
  }'
```

## Dozwolone typy

```txt
task, project, event, social, creative, partner, file, warehouse, finance, template, note, share
```
