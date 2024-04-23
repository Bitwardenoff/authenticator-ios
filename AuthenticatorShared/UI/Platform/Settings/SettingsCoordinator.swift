import SwiftUI

// MARK: - SettingsCoordinator

/// A coordinator that manages navigation in the settings tab.
///
final class SettingsCoordinator: NSObject, Coordinator, HasStackNavigator {
    // MARK: Types

    /// The module types required by this coordinator for creating child coordinators.
    typealias Module = TutorialModule

    typealias Services = HasAuthenticatorItemRepository
        & HasBiometricsRepository
        & HasErrorReporter
        & HasExportItemsService
        & HasImportItemsService
        & HasPasteboardService
        & HasStateService
        & HasTimeProvider

    // MARK: Private Properties

    /// The module used to create child coordinators.
    private let module: Module

    /// The services used by this coordinator.
    private let services: Services

    // MARK: Properties

    /// The stack navigator that is managed by this coordinator.
    private(set) weak var stackNavigator: StackNavigator?

    // MARK: Initialization

    /// Creates a new `SettingsCoordinator`.
    ///
    /// - Parameters:
    ///   - delegate: The delegate for this coordinator, used to notify when the user logs out.
    ///   - module: The module used to create child coordinators.
    ///   - services: The services used by this coordinator.
    ///   - stackNavigator: The stack navigator that is managed by this coordinator.
    ///
    init(
        module: Module,
        services: Services,
        stackNavigator: StackNavigator
    ) {
        self.module = module
        self.services = services
        self.stackNavigator = stackNavigator
    }

    // MARK: Methods

    func handleEvent(_ event: SettingsEvent, context: AnyObject?) async {}

    func navigate(to route: SettingsRoute, context: AnyObject?) {
        switch route {
        case .dismiss:
            stackNavigator?.dismiss()
        case .exportItems:
            showExportItems()
        case .importItems:
            showImportItems()
        case let .selectLanguage(currentLanguage: currentLanguage):
            showSelectLanguage(currentLanguage: currentLanguage, delegate: context as? SelectLanguageDelegate)
        case .settings:
            showSettings()
        case let .shareExportedItems(fileUrl):
            showExportedItemsUrl(fileUrl)
        case .tutorial:
            showTutorial()
        }
    }

    func start() {
        navigate(to: .settings)
    }

    // MARK: Private Methods

    /// Presents an activity controller for an exported items file URL.
    ///
    private func showExportedItemsUrl(_ fileUrl: URL) {
        let activityVC = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            // TODO: Toast!
        }
        stackNavigator?.present(activityVC)
    }

    /// Shows the export vault screen.
    ///
    private func showExportItems() {
        let processor = ExportItemsProcessor(
            coordinator: asAnyCoordinator(),
            services: services
        )
        let view = ExportItemsView(store: Store(processor: processor))
        let navController = UINavigationController(rootViewController: UIHostingController(rootView: view))
        stackNavigator?.present(navController)
    }

    /// Presents an activity controller for importing items.
    ///
    private func showImportItems() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        stackNavigator?.present(documentPicker)
    }

    /// Shows the select language screen.
    ///
    private func showSelectLanguage(currentLanguage: LanguageOption, delegate: SelectLanguageDelegate?) {
        let processor = SelectLanguageProcessor(
            coordinator: asAnyCoordinator(),
            delegate: delegate,
            services: services,
            state: SelectLanguageState(currentLanguage: currentLanguage)
        )
        let view = SelectLanguageView(store: Store(processor: processor))
        let navController = UINavigationController(rootViewController: UIHostingController(rootView: view))
        stackNavigator?.present(navController)
    }

    /// Shows the settings screen.
    ///
    private func showSettings() {
        let processor = SettingsProcessor(
            coordinator: asAnyCoordinator(),
            services: services,
            state: SettingsState()
        )
        let view = SettingsView(store: Store(processor: processor))
        stackNavigator?.push(view)
    }

    /// Shows the welcome tutorial.
    ///
    private func showTutorial() {
        let navigationController = UINavigationController()
        let coordinator = module.makeTutorialCoordinator(
            stackNavigator: navigationController
        )
        coordinator.start()
        stackNavigator?.present(navigationController, overFullscreen: true)
    }
}

extension SettingsCoordinator: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        Task {
            do {
                try await services.importItemsService.importItems(url: url, format: .json)
            } catch {
                services.errorReporter.log(error: error)
            }
        }
    }
}
