import XCTest

/// Flujo: creación de contacto (caso feliz, negativos y de borde).
final class CreateContactUITests: BaseUITest {

    func test_crearContacto_exitoso_apareceEnLista() {
        launchClean()
        let list = ContactListScreen(app: app)

        let form = list.tapNew()
        form.fill(firstName: "Ana", lastName: "Lopez", phone: "8095550001")
        form.tapSave()

        XCTAssertTrue(list.isShowingContact("Ana Lopez"),
                      "El contacto creado debería aparecer en la lista")
    }

    func test_crearContacto_camposVacios_muestraError() {
        launchClean()
        let form = ContactListScreen(app: app).tapNew()

        form.tapSave()

        XCTAssertEqual(form.errorText(), "El nombre es obligatorio.",
                       "Guardar con campos vacíos debe mostrar el error de nombre")
    }

    func test_crearContacto_telefonoInvalido_muestraError() {
        launchClean()
        let form = ContactListScreen(app: app).tapNew()

        form.fill(firstName: "Ana", lastName: "Lopez", phone: "123")
        form.tapSave()

        XCTAssertEqual(form.errorText(), "El teléfono no es válido.",
                       "Un teléfono demasiado corto debe ser rechazado")
    }

    func test_crearContacto_soloNombre_muestraErrorDeApellido() {
        launchClean()
        let form = ContactListScreen(app: app).tapNew()

        form.type(firstName: "Ana")
        form.tapSave()

        XCTAssertEqual(form.errorText(), "El apellido es obligatorio.")
    }

    func test_cancelar_noGuardaElContacto() {
        launchClean()
        let list = ContactListScreen(app: app)

        let form = list.tapNew()
        form.type(firstName: "Temporal")
        form.tapCancel()

        XCTAssertFalse(list.isShowingContact("Temporal", timeout: 2),
                       "Cancelar no debe persistir el contacto")
    }

    func test_botonImagenAleatoria_mantieneImagenVisible() {
        launchClean()
        let form = ContactListScreen(app: app).tapNew()

        form.tapRandomImage()

        XCTAssertTrue(form.image.waitForExistence(timeout: form.defaultTimeout),
                      "La imagen debe seguir presente tras pedir una aleatoria")
    }

    func test_contactoPersiste_trasCierreYReapertura() {
        launchClean()
        let list = ContactListScreen(app: app)

        let form = list.tapNew()
        form.fill(firstName: "Ana", lastName: "Lopez", phone: "8095550001")
        form.tapSave()
        XCTAssertTrue(list.isShowingContact("Ana Lopez"),
                      "Precondición: el contacto debe aparecer tras crearlo")

        app.terminate()
        launchRetaining()   // misma suite aislada, sin reset

        XCTAssertTrue(list.isShowingContact("Ana Lopez"),
                      "El contacto debe persistir en UserDefaults tras cerrar y reabrir la app")
    }
}
