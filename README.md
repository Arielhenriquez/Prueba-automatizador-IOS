# Contactos — Prueba Técnica iOS (SwiftUI + XCUITest)

Aplicación de gestión de contactos construida 100% en **SwiftUI** con arquitectura **MVVM**, y una suite de pruebas automatizadas de UI con **XCUITest** usando el patrón **Screen Object (Page Object)**.

## Requisitos

- macOS con **Xcode 15+** (iOS 16.0 como deployment target)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) para generar el proyecto

## Cómo ejecutar

### Paso 1 — Generar el proyecto Xcode

```bash
brew install xcodegen
cd /ruta/al/proyecto
xcodegen generate
open ContactsApp.xcodeproj
```

### Paso 2 — Correr la app

1. Selecciona el scheme **ContactsApp** y un simulador (ej. iPhone 16).
2. `Cmd + R` — lanza la app.

### Paso 3 — Correr los tests

```bash
# Desde Xcode
Cmd + U   # corre unit tests + UI tests + genera reporte de cobertura

# Desde terminal
xcodebuild test \
  -project ContactsApp.xcodeproj \
  -scheme ContactsApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Paso 4 — Ver el reporte de cobertura

1. `Cmd + 9` (panel de Reports) → selecciona la última ejecución de tests.
2. Pestaña **Coverage** → muestra cobertura por archivo, clase y función.

> Code coverage está habilitado en `project.yml` (`gatherCoverageData: true`) sobre el target `ContactsApp`.

## Arquitectura

```
ContactsApp/
├── App/            → Entry point + composición de dependencias (DI)
├── Models/         → Contact (dominio puro, sin UI)
├── Services/       → ContactStore (persistencia) + ImageService (API pública)
├── Support/        → AccessibilityIdentifiers (compartido con UI tests)
├── ViewModels/     → Lógica de presentación (testeable sin UI)
└── Views/          → SwiftUI puro, sin lógica de negocio
```

- **MVVM:** las vistas solo renderizan estado publicado por los ViewModels. Toda la validación y filtrado vive en los ViewModels, lo que permite unit-testearlos sin UI.
- **Inyección de dependencias:** `ContactStoreProtocol` e `ImageServiceProtocol` se inyectan por inicializador. La app usa implementaciones reales; los tests usan mocks.
- **API pública de imágenes:** [Lorem Picsum](https://picsum.photos) — sin API key.
- **Persistencia local:** UserDefaults + JSON.

## Principios SOLID aplicados

| Principio | Dónde se aplica |
|-----------|----------------|
| **S** — Single Responsibility | `ContactListViewModel` solo gestiona lista; `ContactFormViewModel` solo gestiona el formulario. Las vistas no contienen lógica. |
| **O** — Open/Closed | Agregar un nuevo store (ej. CoreData) solo requiere implementar `ContactStoreProtocol`, sin modificar ViewModels ni vistas. |
| **L** — Liskov Substitution | `InMemoryContactStore` es un sustituto válido de `UserDefaultsContactStore` en tests; el ViewModel no nota la diferencia. |
| **I** — Interface Segregation | `ContactStoreProtocol` se compone de `ContactReader` (solo lectura) y `ContactWriter` (solo escritura) via `typealias`. Una vista de solo consulta puede depender únicamente de `ContactReader`. |
| **D** — Dependency Inversion | ViewModels dependen de protocolos (`ContactStoreProtocol`, `ImageServiceProtocol`), nunca de implementaciones concretas. Las implementaciones reales se inyectan en `ContactsAppApp.init()`. |

## Estrategia de testing

### Pirámide aplicada

| Capa | Framework | Qué cubre | Archivos |
|------|-----------|-----------|---------|
| **Unit** | XCTest | Validación de formulario, filtrado de búsqueda, persistencia, borrado con filtro activo | `ContactListViewModelTests`, `ContactFormViewModelTests` |
| **UI** | XCUITest | Flujos completos de usuario: crear, buscar, borrar, persistencia | `CreateContactUITests`, `SearchContactUITests`, `DeleteContactUITests` |

### Cobertura por módulo (objetivo)

| Módulo | Cobertura objetivo |
|--------|--------------------|
| `ViewModels/` | > 90% (unit tests exhaustivos) |
| `Models/` | > 90% (`matches(query:)`, `a11ySlug`) |
| `Services/` | > 80% (InMemoryContactStore ejercitado por unit tests) |
| `Views/` | ~60% (ejercitadas vía UI tests) |

### Diseño de los UI tests

- **Screen Object pattern:** `BaseScreen`, `ContactListScreen`, `ContactFormScreen`. Los tests no contienen selectores — solo intención (`form.fill(...)`, `list.deleteContact(...)`).
- **Identificadores de accesibilidad centralizados:** el enum `A11y` se comparte entre el target de la app y el de UI tests (single source of truth, cero strings mágicos duplicados).
- **Estado determinista:** la app acepta launch arguments procesados en `ContactsAppApp.init()`:
  - `--uitesting-reset` → suite aislada vacía (tests de creación)
  - `--uitesting-seed` → suite aislada con 3 contactos conocidos (tests de búsqueda y borrado)
  - `--uitesting` → suite aislada sin reset (tests de persistencia — relaunch sin perder datos)
- **Esperas robustas:** `waitForExistence` encapsulado en `BaseScreen.waitFor(...)` — sin `sleep`.
- **Aislamiento de datos:** los flags de testing usan `UserDefaults(suiteName: "app.uitesting")` — los datos reales del usuario en `UserDefaults.standard` nunca se ven afectados.

### Casos cubiertos

**Crear (6 casos):** caso feliz · campos vacíos · solo nombre · teléfono inválido · cancelar no persiste · imagen aleatoria · **persistencia tras cierre y reapertura**.

**Buscar (4 casos):** por nombre · por apellido · por teléfono · sin resultados (estado vacío).

**Borrar (4 casos):** borrado individual · borrado total (estado vacío) · **borrado con búsqueda activa** · **modo "Listo" desactiva botones de borrado**.

**Unit tests (10 casos):** init carga store · add persiste · delete persiste · filtrado por nombre/apellido/teléfono · sin resultados · texto vacío · **delete(at:) con filtro activo** · **delete(at:) no afecta contactos no visibles** · validaciones de formulario · imagen aleatoria cambia URL.
