# Marketing Hub

Aplikacja webowa do organizacji pracy marketingu: projekty, kampanie, kalendarz, zadania, social media, kreacje, partnerzy, materiały, magazyn, finanse, checklisty i prywatne notatki.

## Status

Wersja jest podłączona pod Supabase:

- logowanie magic linkiem,
- dostęp tylko dla domeny `@felg.app`,
- wspólne dane dla zespołu marketingu,
- prywatne notatki widoczne tylko dla właściciela,
- upload i download plików przez Supabase Storage,
- dane zapisują się w Supabase, a nie lokalnie w przeglądarce.

## Pliki

- `index.html` — aplikacja front-endowa
- `supabase/schema.sql` — tabele, RLS i bucket Storage
- `package.json` — konfiguracja do lokalnego uruchomienia/deploy

## Krok 1: utwórz projekt Supabase

1. Wejdź na Supabase.
2. Utwórz nowy projekt.
3. Przejdź do **SQL Editor**.
4. Wklej całą zawartość pliku `supabase/schema.sql`.
5. Kliknij **Run**.

To utworzy:

- tabelę `marketing_profiles`,
- tabelę `marketing_items`,
- bucket `marketing-files`,
- polityki RLS dla prywatnych notatek i wspólnych danych.

## Krok 2: ustaw Auth

W Supabase przejdź do:

**Authentication → Providers → Email**

Upewnij się, że Email provider jest włączony.

Potem przejdź do:

**Authentication → URL Configuration**

Dodaj swój adres Netlify jako redirect URL, np.:

```txt
https://twoja-aplikacja.netlify.app
```

## Krok 3: odpal aplikację

Po wejściu w aplikację pierwszy ekran poprosi o:

```txt
SUPABASE_URL
SUPABASE_ANON_KEY
Domena: felg.app
```

Te dane znajdziesz w Supabase:

**Project Settings → API**

Wklejasz:

- Project URL jako `SUPABASE_URL`,
- anon/public key jako `SUPABASE_ANON_KEY`.

Klucz anon jest publiczny, ale bezpieczeństwo danych zapewnia RLS w Supabase.

## Krok 4: logowanie

Wpisz e-mail firmowy, np.:

```txt
gosia@felg.app
```

Aplikacja wyśle magic link. Po kliknięciu linku wrócisz do aplikacji.

## Jak działają dane

- Wspólne moduły: widzi cały marketing po zalogowaniu.
- Prywatne notatki: widzi tylko właściciel notatki.
- Pliki: zapisują się w Supabase Storage w buckecie `marketing-files`.
- Usuwanie: usuwa rekord z Supabase, a przy plikach także obiekt ze Storage.

## Deploy Netlify

Najprościej:

1. Wejdź w Netlify.
2. Kliknij **Add new site → Import an existing project**.
3. Wybierz repo `marketing`.
4. Build command zostaw pusty albo użyj:

```txt
npm run build
```

5. Publish directory:

```txt
.
```

Dla prostego deploy można też wrzucić sam `index.html`.

## Ważne

To jest lekka aplikacja front-endowa z Supabase jako backendem. Dla pełnego systemu enterprise można później przenieść ją do Next.js i dodać osobny backend/API, ale obecna wersja pozwala już mieć wspólne dane zespołu w Supabase.
