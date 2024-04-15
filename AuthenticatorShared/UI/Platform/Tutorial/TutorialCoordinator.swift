import SwiftUI

// MARK: - TutorialCoordinator

/// A coordinator that manages navigation in the tutorial.
///
final class TutorialCoordinator: Coordinator, HasStackNavigator {
    // MARK: Types

    /// The module types required for creating child coordinators.
    typealias Module = DefaultAppModule

    typealias Services = HasErrorReporter

    // MARK: Private Properties

    /// The module used to create child coordinators.
    private let module: Module

    /// The services used
    private let services: Services

    // MARK: Properties

    /// The stack navigator
    private(set) weak var stackNavigator: StackNavigator?

    // Initialization

    /// Creates a new `TutorialCoordinator`
    ///
    /// - Parameters:
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

    func handleEvent(_ event: TutorialEvent, context: AnyObject?) async {}

    func navigate(to route: TutorialRoute, context: AnyObject?) {}

    func start() {}
}
