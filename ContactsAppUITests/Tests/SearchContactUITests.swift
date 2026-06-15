import XCTest

/// Flujo: búsqueda por cualquier campo + estado sin resultados.
final class SearchContactUITests: BaseUITest {

    func test_buscarPorNombre_filtraLaLista() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.search("Juan")

        XCTAssertTrue(list.isShowingContact("Juan Perez"))
        XCTAssertFalse(list.isShowingContact("Maria Garcia", timeout: 2),
                       "Los contactos que no coinciden deben ocultarse")
    }

    func test_buscarPorApellido_filtraLaLista() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.search("Garcia")

        XCTAssertTrue(list.isShowingContact("Maria Garcia"))
        XCTAssertFalse(list.isShowingContact("Juan Perez", timeout: 2))
    }

    func test_buscarPorTelefono_filtraLaLista() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.search("8495559012")

        XCTAssertTrue(list.isShowingContact("Pedro Martinez"))
        XCTAssertFalse(list.isShowingContact("Juan Perez", timeout: 2))
    }

    func test_busquedaSinResultados_muestraEstadoVacio() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.search("zzzz")

        XCTAssertTrue(list.isShowingEmptyState(),
                      "Una búsqueda sin coincidencias debe mostrar 'Sin resultados'")
    }
}
