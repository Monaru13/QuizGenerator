# Quiz Generator - Aplikacja Flutter

Kompletna aplikacja kliencka Flutter do obsługi API generatora quizów.

## Funkcjonalności

- **Lista quizów** - Przeglądanie wszystkich dostępnych quizów
- **Kreator quizów** - Tworzenie nowych quizów na podstawie tematu z konfigurowalnymi parametrami
- **Rozwiązywanie quizów** - Interaktywny tryb rozwiązywania z wyświetlaniem wyników
- **Edycja quizów** - Możliwość modyfikacji pytań i odpowiedzi istniejących quizów
- **Szczegóły quizu** - Podgląd pytań i informacji o quizie

## Struktura projektu

```
lib/
├── main.dart                    # Punkt wejścia aplikacji
├── models/
│   └── quiz_models.dart         # Modele danych (QuizSet, Quiz, QuizQuestion, etc.)
├── services/
│   └── quiz_api.dart           # Klient REST API
└── screens/
    ├── quiz_list_screen.dart    # Lista quizów
    ├── quiz_creator_screen.dart # Kreator nowych quizów
    ├── quiz_details_screen.dart # Szczegóły quizu
    ├── quiz_play_screen.dart    # Rozwiązywanie quizu
    └── quiz_edit_screen.dart    # Edycja quizu
```

## Instalacja i uruchomienie

### Wymagania
- Flutter SDK (>=3.0.0)
- Dart SDK
- Uruchomiony serwer API na localhost

### Kroki instalacji

1. **Klonowanie/skopiowanie projektu**
   ```bash
   flutter create quiz_app
   cd quiz_app
   ```

2. **Skopiowanie plików**
   - Zastąp zawartość `pubspec.yaml`
   - Skopiuj wszystkie pliki z `lib/` do odpowiednich folderów

3. **Instalacja zależności**
   ```bash
   flutter pub get
   ```

4. **Konfiguracja API**
   - Upewnij się, że serwer API działa na `http://localhost`
   - W razie potrzeby zmień URL w `services/quiz_api.dart`

5. **Uruchomienie aplikacji**
   ```bash
   flutter run
   ```

## Konfiguracja API

Domyślnie aplikacja łączy się z `http://localhost`. Aby zmienić adres serwera, edytuj plik `services/quiz_api.dart`:

```dart
static const String baseUrl = 'http://twoj-serwer.com';
```

## Wykorzystywane endpointy API

- `GET /api/quiz` - Pobieranie listy quizów
- `POST /api/quiz` - Tworzenie nowego quizu
- `GET /api/quiz/{id}` - Pobieranie szczegółów quizu
- `PUT /api/quiz/{id}` - Edycja quizu
- `DELETE /api/quiz/{id}` - Usuwanie quizu

## Zależności

- `http: ^1.1.0` - Obsługa zapytań HTTP
- `cupertino_icons: ^1.0.6` - Ikony dla iOS

## Struktura danych

Aplikacja obsługuje następujące modele danych:

- **QuizSet** - Kompletny zestaw quizu
- **Quiz** - Pojedynczy wariant quizu
- **QuizQuestion** - Pytanie z odpowiedziami
- **QuizAnswer** - Pojedyncza odpowiedź
- **QuizGeneratorOptions** - Opcje generowania quizu

## Obsługa błędów

Aplikacja zawiera podstawową obsługę błędów sieciowych i wyświetla odpowiednie komunikaty użytkownikowi. W przypadku problemów z API, sprawdź:

1. Czy serwer API jest uruchomiony
2. Czy adres URL jest prawidłowy
3. Czy endpointy API odpowiadają zgodnie z dokumentacją

## Rozwój aplikacji

Aplikacja jest gotowa do rozszerzenia o dodatkowe funkcjonalności, takie jak:

- Logowanie użytkowników
- Zapisywanie wyników
- Udostępnianie quizów
- Tryb offline
- Synchronizacja danych

## Troubleshooting

**Problem z połączeniem API:**
- Sprawdź czy serwer działa na właściwym porcie
- Upewnij się, że CORS jest włączony na serwerze
- Sprawdź logi w konsoli Flutter

**Błędy kompilacji:**
- Uruchom `flutter clean` i `flutter pub get`
- Sprawdź wersję Flutter SDK

**Użyteczne linki**
- https://stackoverflow.com/questions/74140281/flutter-re-run-cmake-with-a-different-source-directory
