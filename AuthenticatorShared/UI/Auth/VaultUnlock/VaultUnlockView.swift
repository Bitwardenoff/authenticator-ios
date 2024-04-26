import SwiftUI

// MARK: - VaultUnlockView

/// A view that allows a user to use biometrics before viewing their items
///
struct VaultUnlockView: View {
    // MARK: Properties

    /// The `Store` for this view.
    @ObservedObject var store: Store<VaultUnlockState, VaultUnlockAction, VaultUnlockEffect>

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .task {
                await store.perform(.appeared)
            }
            .toast(store.binding(
                get: \.toast,
                send: VaultUnlockAction.toastShown
            ))
    }

    private var content: some View {
        ZStack {
            if colorScheme == .light {
                Asset.Colors.primaryBitwarden.swiftUIColor
                    .ignoresSafeArea()
            }

            VStack(spacing: 48) {
                Image(decorative: Asset.Images.authenticatorLogo)
                    .resizable()
                    .frame(width: 232, height: 63)

                biometricAuthButton
            }
            .padding(16)
        }
    }

    /// A button to trigger a biometric auth unlock.
    @ViewBuilder private var biometricAuthButton: some View {
        if case let .available(biometryType, true, true) = store.state.biometricUnlockStatus {
            AsyncButton {
                Task { await store.perform(.unlockWithBiometrics) }
            } label: {
                biometricUnlockText(biometryType)
            }
            .if(colorScheme == .light) { view in
                view.buttonStyle(.secondary(shouldFillWidth: true))
                    .background(Asset.Colors.backgroundPrimary.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .if(colorScheme == .dark) { view in
                view.buttonStyle(.primary(shouldFillWidth: true))
            }
        }
    }

    private func biometricUnlockText(_ biometryType: BiometricAuthenticationType) -> some View {
        switch biometryType {
        case .faceID:
            Text(Localizations.useFaceIDToUnlock)
        case .touchID:
            Text(Localizations.useFingerprintToUnlock)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Unlock") {
    NavigationView {
        VaultUnlockView(
            store: Store(
                processor: StateProcessor(
                    state: VaultUnlockState(
                        biometricUnlockStatus: .available(
                            .faceID,
                            enabled: true,
                            hasValidIntegrity: true
                        )
                    )
                )
            )
        )
    }
}
#endif
