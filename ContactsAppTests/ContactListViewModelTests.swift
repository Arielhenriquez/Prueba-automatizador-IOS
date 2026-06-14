import XCTest
@testable import ContactsApp

final class ContactListViewModelTests: XCTestCase {

    private let juan  = Contact(firstName: "Juan",  lastName: "Perez",  phone: "8095551234")
    private let maria = Contact(firstName: "Maria", lastName: "Garcia", phone: "8295555678")

    @MainActor
    private func makeSUT(initial: [Contact] = []) -> (ContactListViewModel, InMemoryContactStore) {
        let store = InMemoryContactStore(initial: initial)
        let sut = ContactListViewModel(store: store)
        return (sut, store)
    }

    @MainActor
    func test_init_cargaContactosDelStore() {
        let (sut, _) = makeSUT(initial: [juan, maria])
        XCTAssertEqual(sut.contacts.count, 2)
    }

    @MainActor
    func test_add_agregaYPersiste() {
        let (sut, store) = makeSUT()

        sut.add(juan)

        XCTAssertEqual(sut.contacts, [juan])
        XCTAssertEqual(store.load(), [juan]) // verifica persistencia
    }

    @MainActor
    func test_delete_eliminaYPersiste() {
        let (sut, store) = makeSUT(initial: [juan, maria])

        sut.delete(juan)

        XCTAssertEqual(sut.contacts, [maria])
        XCTAssertEqual(store.load(), [maria])
    }

    // MARK: - Búsqueda por cualquier campo

    @MainActor
    func test_filtrado_porNombre() {
        let (sut, _) = makeSUT(initial: [juan, maria])
        sut.searchText = "juan"
        XCTAssertEqual(sut.filteredContacts, [juan])
    }

    @MainActor
    func test_filtrado_porApellido() {
        let (sut, _) = makeSUT(initial: [juan, maria])
        sut.searchText = "Garcia"
        XCTAssertEqual(sut.filteredContacts, [maria])
    }

    @MainActor
    func test_filtrado_porTelefono() {
        let (sut, _) = makeSUT(initial: [juan, maria])
        sut.searchText = "8295555678"
        XCTAssertEqual(sut.filteredContacts, [maria])
    }

    @MainActor
    func test_filtrado_sinResultados_devuelveVacio() {
        let (sut, _) = makeSUT(initial: [juan, maria])
        sut.searchText = "zzz"
        XCTAssertTrue(sut.filteredContacts.isEmpty)
    }

    @MainActor
    func test_filtrado_textoVacio_devuelveTodos() {
        let (sut, _) = makeSUT(initial: [juan, maria])
        sut.searchText = "   "
        XCTAssertEqual(sut.filteredContacts.count, 2)
    }

    // MARK: - Borrado con filtro activo

    @MainActor
    func test_deleteAtOffsets_conFiltroActivo_borraContactoCorrecto() {
        let (sut, store) = makeSUT(initial: [juan, maria])
        sut.searchText = "juan"
        // filteredContacts = [juan] → offset 0 corresponde a juan, no a maria

        sut.delete(at: IndexSet([0]))

        XCTAssertEqual(sut.contacts, [maria],        "Solo debe quedar Maria en la lista completa")
        XCTAssertEqual(store.load(), [maria],         "La persistencia debe reflejar el borrado")
        XCTAssertTrue(sut.filteredContacts.isEmpty,   "Con filtro 'juan' activo, el resultado debe quedar vacío")
    }

    @MainActor
    func test_deleteAtOffsets_conFiltroActivo_noAfectaContactosNoVisibles() {
        let pedro = Contact(firstName: "Pedro", lastName: "Martinez", phone: "8495559012")
        let (sut, _) = makeSUT(initial: [juan, maria, pedro])
        sut.searchText = "pedro"
        // filteredContacts = [pedro] → borramos al único visible

        sut.delete(at: IndexSet([0]))

        XCTAssertEqual(sut.contacts.count, 2,         "juan y maria no deben verse afectados")
        XCTAssertTrue(sut.contacts.contains(juan))
        XCTAssertTrue(sut.contacts.contains(maria))
    }
}
