import XCTest
@testable import Overheadlog

@MainActor
final class OverheadlogTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(OverheadlogEntry(billName: "Test", amount: 10, note: "n", date: Date()))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        let store = Store()
        store.entries = []
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtFreeLimit() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            OverheadlogEntry(billName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = false
        XCTAssertFalse(store.canAddMore)
        let result = store.add(OverheadlogEntry(billName: "Over", amount: 1, note: "", date: Date()))
        XCTAssertFalse(result)
    }

    func testProUserCanAlwaysAdd() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            OverheadlogEntry(billName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteEntry() {
        let store = Store()
        let entry = OverheadlogEntry(billName: "ToDelete", amount: 5, note: "", date: Date())
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntry() {
        let store = Store()
        var entry = OverheadlogEntry(billName: "Original", amount: 5, note: "", date: Date())
        store.add(entry)
        entry.billName = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.billName, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        store.entries = []
        store.add(OverheadlogEntry(billName: "A", amount: 1, note: "", date: Date()))
        store.add(OverheadlogEntry(billName: "B", amount: 1, note: "", date: Date()))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
    }
}
