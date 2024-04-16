import BitwardenSdk
import SwiftUI

// MARK: - ItemListItemRowView

/// A view that displays information about an `ItemListItem` as a row in a list.
struct ItemListItemRowView: View {
    // MARK: Properties

    /// The `Store` for this view.
    var store: Store<
        ItemListItemRowState,
        ItemListItemRowAction,
        ItemListItemRowEffect
    >

    /// The `TimeProvider` used to calculate TOTP expiration.
    var timeProvider: any TimeProvider

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                decorativeImage(
                    store.state.item,
                    iconBaseURL: store.state.iconBaseURL,
                    showWebIcons: store.state.showWebIcons
                )
                .frame(width: 22, height: 22)
                .foregroundColor(Asset.Colors.textSecondary.swiftUIColor)
                .padding(.vertical, 19)
                .accessibilityHidden(true)

                HStack {
                    switch store.state.item.itemType {
                    case let .totp(model):
                        totpCodeRow(store.state.item.name, model.totpCode)
                    }
                }
                .padding(.vertical, 9)
            }
            .padding(.horizontal, 16)

            if store.state.hasDivider {
                Divider()
                    .padding(.leading, 22 + 16 + 16)
            }
        }
    }

    // MARK: - Private Views

    /// The decorative image for the row.
    ///
    /// - Parameters:
    ///   - item: The item in the row.
    ///   - iconBaseURL: The base url used to download decorative images.
    ///   - showWebIcons: Whether to download the web icons.
    ///
    @ViewBuilder
    private func decorativeImage(_ item: ItemListItem, iconBaseURL: URL?, showWebIcons: Bool) -> some View {
        placeholderDecorativeImage(Asset.Images.clock)
    }

    /// The placeholder image for the decorative image.
    private func placeholderDecorativeImage(_ icon: ImageAsset) -> some View {
        Image(decorative: icon)
            .resizable()
            .scaledToFit()
    }

    /// The row showing the totp code.
    @ViewBuilder
    private func totpCodeRow(_ name: String, _ model: TOTPCodeModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(name)
                .styleGuide(.headline)
                .lineLimit(1)
                .foregroundColor(Asset.Colors.textPrimary.swiftUIColor)
        }
        Spacer()
        TOTPCountdownTimerView(
            timeProvider: timeProvider,
            totpCode: model,
            onExpiration: nil
        )
        Text(model.displayCode)
            .styleGuide(.bodyMonospaced, weight: .regular, monoSpacedDigit: true)
            .foregroundColor(Asset.Colors.textPrimary.swiftUIColor)

        Image(decorative: Asset.Images.copy)
            .foregroundColor(Asset.Colors.primaryBitwarden.swiftUIColor)
    }
}

#if DEBUG
#Preview {
    ItemListItemRowView(
        store: Store(
            processor: StateProcessor(
                state: ItemListItemRowState(
                    item: ItemListItem(
                        id: UUID().uuidString,
                        name: "Example",
                        itemType: .totp(
                            model: ItemListTotpItem(
                                itemView: AuthenticatorItemView.fixture(),
                                totpCode: TOTPCodeModel(
                                    code: "123456",
                                    codeGenerationDate: Date(),
                                    period: 30
                                )
                            )
                        )
                    ),
                    hasDivider: true,
                    showWebIcons: true
                )
            )
        ),
        timeProvider: PreviewTimeProvider()
    )
}
#endif
