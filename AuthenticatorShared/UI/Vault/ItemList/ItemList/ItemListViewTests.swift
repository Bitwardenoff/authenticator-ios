import SnapshotTesting
import SwiftUI
import ViewInspector
import XCTest

@testable import AuthenticatorShared

// MARK: - ItemListViewTests

class ItemListViewTests: AuthenticatorTestCase {
    // MARK: Properties

    var processor: MockProcessor<ItemListState, ItemListAction, ItemListEffect>!
    var subject: ItemListView!
    var timeProvider: MockTimeProvider!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        let state = ItemListState()
        processor = MockProcessor(state: state)
        timeProvider = MockTimeProvider(.mockTime(Date(year: 2023, month: 12, day: 31)))
        subject = ItemListView(
            store: Store(processor: processor),
            timeProvider: timeProvider
        )
    }

    override func tearDown() {
        super.tearDown()

        processor = nil
        subject = nil
        timeProvider = nil
    }

    // MARK: Tests

    /// Test a snapshot of the ItemListView previews.
    func test_snapshot_ItemListView_previews() {
        for preview in ItemListView_Previews._allPreviews {
            let name = preview.displayName ?? "Unknown"
            assertSnapshots(
                of: preview.content,
                as: [
                    "\(name)-portrait": .defaultPortrait,
                    "\(name)-portraitDark": .defaultPortraitDark,
                    "\(name)-portraitAX5": .defaultPortraitAX5,
                ]
            )
        }
    }

    func test_snapshot_ItemListView_card_download_empty() {
        let state = ItemListState(
            loadingState: .data([]),
            showPasswordManagerDownloadCard: true
        )
        processor = MockProcessor(state: state)
        subject = ItemListView(
            store: Store(processor: processor),
            timeProvider: timeProvider
        )

        assertSnapshot(matching: NavigationView { subject }, as: .defaultPortrait)
    }

    func test_snapshot_ItemListView_card_download_with_items() {
        let state = ItemListState(
            loadingState: .data([ItemListSection.fixture()]),
            showPasswordManagerDownloadCard: true
        )
        processor = MockProcessor(state: state)
        subject = ItemListView(
            store: Store(processor: processor),
            timeProvider: timeProvider
        )

        assertSnapshot(matching: NavigationView { subject }, as: .defaultPortrait)
    }

    func test_snapshot_ItemListView_card_sync_empty() {
        let state = ItemListState(
            loadingState: .data([]),
            showPasswordManagerSyncCard: true
        )
        processor = MockProcessor(state: state)
        subject = ItemListView(
            store: Store(processor: processor),
            timeProvider: timeProvider
        )

        assertSnapshot(matching: NavigationView { subject }, as: .defaultPortrait)
    }

    func test_snapshot_ItemListView_card_sync_with_items() {
        let state = ItemListState(
            loadingState: .data([ItemListSection.fixture()]),
            showPasswordManagerSyncCard: true
        )
        processor = MockProcessor(state: state)
        subject = ItemListView(
            store: Store(processor: processor),
            timeProvider: timeProvider
        )

        assertSnapshot(matching: NavigationView { subject }, as: .defaultPortrait)
    }
}
