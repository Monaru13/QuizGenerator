# Konfiguracja kluczy API za pomocą User Secrets (.NET)

## 📋 Wprowadzenie

User Secrets to **bezpieczny mechanizm przechowywania wrażliwych danych** (kluczy API, haseł bazodanowych) **poza kodem źródłowym**. Dane są zapisywane w `%APPDATA%\Microsoft\UserSecrets` i **nigdy nie trafiają do Git**.

**User Secrets są unikalne dla każdego projektu** (GUID w `.csproj`).

## 🛠️ Wymagania wstępne

```
.NET 8.0+ (SDK)
dotnet-ef tool (opcjonalnie)
```


## 🔧 Konfiguracja krok po kroku

### 1. **Inicjalizacja User Secrets** (raz na projekt)

**W folderze projektu** (tam gdzie `.csproj`):

```bash
dotnet user-secrets init
```

**Wynik:**

```
info: Created new secret store called: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
```

**Plik `.csproj` zostanie zaktualizowany:**

```xml
<PropertyGroup>
  <UserSecretsId>a1b2c3d4-e5f6-7890-abcd-ef1234567890</UserSecretsId>
</PropertyGroup>
```


### 2. **Dodanie klucza OpenAI API**

```bash
dotnet user-secrets set "QuizGenerator:ApiKey" "sk-proj-twoj-klucz-openai-tutaj"
```

**Wynik:**

```
info: Secret value has been set using secret identifier 'QuizGenerator:ApiKey'.
```


### 3. **Sprawdzenie listy sekretów**

```bash
dotnet user-secrets list
```

**Wynik:**

```
QuizGenerator:ApiKey = ***sk-proj-xxx... (ukryte)
```

**Pokaż konkretny klucz:**

```bash
dotnet user-secrets get "QuizGenerator:ApiKey"
```

```
sk-proj-twoj-klucz-openai-tutaj
```


### 4. **Edycja / Nadpisywanie klucza**

**Nadpisanie istniejącego:**

```bash
dotnet user-secrets set "QuizGenerator:ApiKey" "sk-proj-nowy-klucz-xyz123"
```

**Usunięcie konkretnego:**

```bash
dotnet user-secrets remove "QuizGenerator:ApiKey"
```

**Wyczyść wszystkie:**

```bash
dotnet user-secrets clear
```


## 📁 Struktura plików konfiguracyjnych

### appsettings.Development.json (publiczne ustawienia)

```json
{
  "QuizGenerator": {
    "DefaultModel": "gpt-4o-mini",
    "MaxOutputTokenCountPerQuestion": 200,
    "QuizDbConnectionString": "Data Source=quizzes.db"
  }
}
```


### User Secrets (tylko wrażliwe dane)

```
QuizGenerator:ApiKey = sk-proj-twoj-klucz-openai-tutaj
```


### Rezultat po `GetSection("QuizGenerator").Get<>()`

```
ApiKey = "sk-proj-twoj-klucz..."  ← UserSecrets (priorytet 1)
DefaultModel = "gpt-4o-mini"      ← appsettings (priorytet 2)
QuizDbConnectionString = "..."    ← appsettings (priorytet 3)
```


## 🔍 Debug konfiguracji

### Sprawdź źródło każdej wartości

```csharp
// Program.cs
foreach (var kvp in builder.Configuration.AsEnumerable())
{
    if (kvp.Key.Contains("QuizGenerator"))
        Console.WriteLine($"{kvp.Key,-30} = {kvp.Value}");
}
```


### Walidacja przy starcie

```csharp
var quizOptions = builder.Configuration.GetSection("QuizGenerator")
    .Get<QuizGeneratorOptions>() 
    ?? throw new InvalidOperationException("Brak konfiguracji QuizGenerator!");

if (string.IsNullOrEmpty(quizOptions.ApiKey))
    throw new InvalidOperationException("QuizGenerator:ApiKey wymagany!");
```


## 🌍 Środowiska produkcyjne

### Environment Variables (najwyższy priorytet)

```
# Windows
setx QuizGenerator__ApiKey "sk-prod-klucz"

# Docker
ENV QuizGenerator__ApiKey=sk-prod-klucz

# Azure App Service
QuizGenerator__ApiKey = sk-prod-klucz
```

**Kolejność priorytetów:**

```
1. Environment Variables (OpenAI__ApiKey)
2. User Secrets (QuizGenerator:ApiKey)
3. appsettings.Production.json
4. appsettings.json
```


## 🚨 Częste problemy

| Problem | Rozwiązanie |
| :-- | :-- |
| `dotnet user-secrets: command not found` | `dotnet tool install --global dotnet-ef` |
| `No secrets.json found` | `dotnet user-secrets init` (w folderze `.csproj`) |
| `ApiKey is empty` | `dotnet user-secrets set "QuizGenerator:ApiKey" "sk-..."` |
| `Secrets nie ładowane` | `builder.Configuration.AddUserSecrets<Program>();` |

## 💡 Przykład pełnego Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

// Włączenie UserSecrets
builder.Configuration.AddUserSecrets<Program>();

var quizOptions = builder.Configuration.GetSection("QuizGenerator")
    .Get<QuizGeneratorOptions>() 
    ?? throw new InvalidOperationException("QuizGenerator config missing!");

builder.Services.AddQuizGeneratorService(quizOptions);

var app = builder.Build();
app.Run();
```


## 📝 Szybka sesja testowa

```bash
# 1. Inicjalizacja
dotnet user-secrets init

# 2. Ustawienie klucza
dotnet user-secrets set "QuizGenerator:ApiKey" "sk-proj-test123"

# 3. Weryfikacja
dotnet user-secrets list
dotnet run
```

**Gotowe!** Klucz API bezpiecznie załadowany 🚀

***

**User Secrets = Git-safe klucze API dla developera**
**Environment Variables = Git-safe klucze dla produkcji**