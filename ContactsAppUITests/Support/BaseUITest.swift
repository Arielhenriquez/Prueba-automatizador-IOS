import XCTest

/// Clase base de todos los UI tests.
/// Centraliza el lanzamiento de la app con estado determinista.
class BaseUITest: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    /// Lanza la app sin datos (estado limpio).
    func launchClean() {
        app.launchArguments = ["--uitesting-reset"]
        app.launch()
    }

    /// Lanza la app con contactos de prueba precargados:
    /// Juan Perez / Maria Garcia / Pedro Martinez.
    func launchSeeded() {
        app.launchArguments = ["--uitesting-seed"]
        app.launch()
    }

    /// Relanza la app usando el mismo suite de datos aislado sin resetear.
    /// Útil para tests de persistencia: verifica que los datos sobreviven un cierre.
    func launchRetaining() {
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
}
