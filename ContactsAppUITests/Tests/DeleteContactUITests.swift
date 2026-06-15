import XCTest

/// Flujo: borrado de contactos.
final class DeleteContactUITests: BaseUITest {

    func test_borrarContacto_desapareceDeLaLista() {
        launchSeeded()
        let list = ContactListScreen(app: app)
        XCTAssertTrue(list.isShowingContact("Juan Perez"),
                      "Precondición: el contacto seed debe existir")

        list.deleteContact(named: "Juan Perez")

        XCTAssertFalse(list.isShowingContact("Juan Perez", timeout: 2),
                       "El contacto borrado no debe seguir en la lista")
        XCTAssertTrue(list.isShowingContact("Maria Garcia"),
                      "Los demás contactos deben permanecer")
    }

    func test_borrarTodos_muestraEstadoVacio() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.enterDeleteMode()
        list.waitFor(list.deleteButton(for: "Juan Perez")).tap()
        list.waitFor(list.deleteButton(for: "Maria Garcia")).tap()
        list.waitFor(list.deleteButton(for: "Pedro Martinez")).tap()

        XCTAssertTrue(list.isShowingEmptyState(),
                      "Sin contactos, la lista debe mostrar el estado vacío")
    }

    func test_borrarContacto_conBusquedaActiva() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.search("Juan")
        XCTAssertTrue(list.isShowingContact("Juan Perez"),
                      "Precondición: el contacto debe ser visible con el filtro activo")

        list.deleteContact(named: "Juan Perez")

        XCTAssertFalse(list.isShowingContact("Juan Perez", timeout: 2),
                       "El contacto debe desaparecer tras el borrado con filtro activo")

        list.clearSearch()
        XCTAssertTrue(list.isShowingContact("Maria Garcia"),
                      "Los contactos no filtrados deben seguir intactos")
        XCTAssertTrue(list.isShowingContact("Pedro Martinez"),
                      "Los contactos no filtrados deben seguir intactos")
    }

    func test_modoListo_ocultaBotonesDeBorrado() {
        launchSeeded()
        let list = ContactListScreen(app: app)

        list.enterDeleteMode()
        XCTAssertTrue(list.deleteButton(for: "Juan Perez").waitForExistence(timeout: 3),
                      "En modo borrado los botones de eliminar deben aparecer")

        list.exitDeleteMode()
        XCTAssertFalse(list.deleteButton(for: "Juan Perez").exists,
                       "Tras salir del modo borrado los botones deben desaparecer")
    }
}
