# Marketing Hub

Wewnętrzna aplikacja webowa dla marketingu, podłączona do Supabase.

## Aktualna wersja

Główna aplikacja jest w pliku `index.html` i działa jako samodzielna aplikacja front-endowa z Supabase jako backendem.

Zawiera:

- logowanie hasłem,
- tworzenie konta z potwierdzeniem maila,
- reset hasła,
- zmianę hasła w Ustawieniach po zalogowaniu,
- Dashboard,
- Kalendarz marketingu,
- Zadania,
- Projekty i kampanie,
- Wydarzenia,
- Social Media,
- Kreacje,
- Partnerów,
- Pliki,
- Magazyn z podziałem Biuro/Garaż,
- Finanse,
- Checklisty,
- Notatki,
- własne zakładki,
- dodawanie, edycję, szczegóły i usuwanie elementów,
- dane startowe,
- zapis danych w Supabase.

## Supabase

Uruchom `supabase/schema.sql` w SQL Editor, jeżeli tabela `marketing_items`, `marketing_profiles` albo bucket `marketing-files` nie istnieją.

## Netlify

Build command:

```txt
npm run build
```

Publish directory:

```txt
dist
```

Po deployu otwórz aplikację i wklej:

- Supabase Project URL,
- Supabase publishable/anon key,
- domenę `felg.app` bez `@`.
