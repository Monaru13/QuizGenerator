# QuizGenerator 🚀

**Inteligentny generator testów jednokrotnego wyboru oparty na AI** – tworzy gotowe **PDF** z losowymi wariantami odpowiedzi w kilka sekund!

## 🎯 **Co robi aplikacja?**

**QuizGenerator** automatycznie generuje **spersonalizowane testy edukacyjne** na dowolny temat używając **GPT-4o**. Wpisujesz temat lekcji, wybierasz poziom trudności i **pobierasz PDF** z wieloma wariantami odpowiedzi – idealne dla nauczycieli, korepetytorów i tworzenia materiałów dydaktycznych.

```
Temat: "Równanie kwadratowe"
↓ AI GPT-4o
📄 5 pytań + 4 warianty → PDF gotowy!
```


## ✨ **Kluczowe funkcje**

### **Backend (.NET 9)**:

- ✅ **AI Generowanie** (GPT-4o, GPT-4o-mini)
- ✅ **Randomizacja** pytań/odpowiedzi (1-4 warianty)
- ✅ **PDF Export** (QuestPDF): Standard/Kompakt/Podwójny/Ekonomiczny
- ✅ **Edycja ręczna** quizów
- ✅ **Logi + koszty** (PLN/USD)
- ✅ **Swagger API** docs


### **Frontend (Flutter Web)**:

- ✅ **Responsywny** Material 3 UI
- ✅ **Generator AI** z podglądem kosztów
- ✅ **Eksport z opcjami** (warianty, layout, klucz odpowiedzi)
- ✅ **Pobieranie** do Downloads z progresem
- ✅ **Cross-platform** (Windown, Andrioid, Chrome/Edge/Safari)


## 🏗 **Architektura**

```
┌─────────────────────┐     HTTP/REST     ┌─────────────────────┐
│  Flutter Web PWA    │◄─────────────────►│   ASP.NET 9 API     │
│                     │                    │                     │
│ • Dio HTTP Client   │                    │ • Minimal APIs      │
│ • Material 3        │                    │ • QuestPDF          │
│ • Downloads API     │                    │ • OpenAI SDK        │
└─────────────────────┘                    │ • SQLite EF Core    │
                                           │ • Swashbuckle       │
                                           └─────────────────────┘
```


## 🚀 **Szybki start**

### **1. Backend (.NET 8)**

```bash
git clone https://github.com/Monaru13/QuizGenerator
cd QuizGeneratorService
dotnet restore

# OpenAI API Key (secrets)
dotnet user-secrets set "OpenAI:ApiKey" "sk-proj-..."

dotnet run
```

**Swagger**: `http://localhost:5000/swagger`

### **2. Frontend (Flutter Web)**

```bash
cd quiz_generator_client
flutter pub get
flutter run -d chrome --web-port=8080
```


### **3. Docker (opcjonalnie)**

```bash
docker-compose up  # backend + frontend
```


## 📋 **API** (Swagger: `/swagger`)

### **Quizy** (`/api/quiz`)

| Metoda | Endpoint | Opis |
| :-- | :-- | :-- |
| `GET` | `/api/quiz` | Lista quizów |
| `GET` | `/api/quiz/{id}` | Szczegóły quizu + logi |
| `POST` | `/api/quiz` | **Generuj AI** |
| `PUT` | `/api/quiz/{id}` | Edytuj quiz |
| `DELETE` | `/api/quiz/{id}` | Usuń |

### **Eksport PDF** (`/api/export/pdf/{id}`)

```
?variantsCount=2&layout=compact&includeAnswerKey=true
```

**Plik**: `Matematyka_2var_compact_20260113_2235.pdf`

### **Logi** (`/api/logs`) + **Modele GPT** (`/api/gpt/models`)

## 🛠 **Stack technologiczny**

| Kategoria | Technologia | Wersja |
| :-- | :-- | :-- |
| **Backend** | ASP.NET Core | 8.0 |
| **PDF** | QuestPDF | Community |
| **AI** | OpenAI GPT-4o | Streaming |
| **DB** | SQLite + EF Core | 8.0 |
| **API Docs** | Swashbuckle | 6.5 |
| **Frontend** | Flutter Web | 3.19 |
| **HTTP** | Dio | 5.4 |
| **UI** | Material 3 | Adaptive |
| **State** | Provider | - |

## 💰 **Koszty AI** (GPT-4o-mini)

| Quiz | Koszt |
| :-- | :-- |
| 5 pytań | **0.01 PLN** |
| 10 pytań | **0.02 PLN** |
| 20 pytań | **0.04 PLN** |

## 📱 **Flutter Frontend**

### **Ekrany**:

1. **Lista Quizów** – sortowanie, wyszukiwanie
2. **Generator AI** – temat, model, trudność, podgląd ceny
3. **Szczegóły Quizu** – edycja pytań, historia
4. **Eksport PDF** – **SegmentedButton** (1-4 warianty), 4 layouty, progres

### **Zaawansowane**:

- **Cross-platform Downloads** (Android/Windows/macOS)
- **LaTeX/MathJax** w PDF (QuestPDF)
- **MemoryStream** backend (zero Temp plików)


## 🧪 **Lokalne uruchomienie**

```bash
# Backend
OPENAI_API_KEY=sk-... dotnet run

# Frontend  
flutter run -d chrome

# Swagger API
http://localhost:5000/swagger
```


## 📂 **Struktura projektu**

```
QuizGenerator/
├── QuizGeneratorService/     (.NET 8 API)
│   ├── Endpoints/           (QuizEndpoints.cs, ExportEndpoints.cs)
│   ├── Services/            (QuizGeneratorService.cs)
│   ├── Models/              (QuizDto, ExportParameters)
│   └── Program.cs
├── quiz_generator_client/   (Flutter Web)
│   ├── lib/screens/         (ExportOptionsScreen.dart)
│   ├── lib/services/        (FileDownloadService.dart)
│   └── pubspec.yaml
└── docker-compose.yml
```


## 🔧 **Rozwój**

### **Backend**:

```bash
dotnet ef migrations add AddQuizzes
dotnet ef database update
dotnet watch run
```


### **Frontend**:

```bash
flutter analyze
flutter format .
flutter pub run build_runner build
```


## 📄 **Licencja**

MIT License © 2026 [Monaru13](https://github.com/Monaru13)

## 🙌 **Wsparcie**

⭐ **Zostaw Star** jeśli pomogło!
💬 **[Issues](https://github.com/Monaru13/QuizGenerator/issues)**

***

**QuizGenerator** = **AI testy w 30 sekund** dla każdego nauczyciela! 🎓✨
<span style="display:none">[^1][^2][^3][^4][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://github.com/Monaru13/QuizGenerator

[^2]: image.jpg

[^3]: export_options_screen.dart

[^4]: image.jpg

[^5]: image.jpg

[^6]: export_options_screen.dart

[^7]: ExportEndpoints.cs

[^8]: file_download_service.dart

[^9]: REST-API.json

