//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NameOverview: View {
    private let accountDetails: AccountDetails

    @EnvironmentObject private var account: Account

    @ObservedObject private var model: AccountOverviewFormViewModel

    var body: some View {
        Form {
            let forEachWrappers = model.namesOverviewKeys(details: accountDetails)
                .map { ForEachAccountKeyWrapper($0) }

            ForEach(forEachWrappers, id: \.id) { wrapper in
                Section {
                    NavigationLink {
                        wrapper.accountKey.singleEditView(model: model, details: accountDetails)
                    } label: {
                        if let view = wrapper.accountKey.dataDisplayViewWithCurrentStoredValue(from: accountDetails) {
                            view
                        } else {
                            HStack {
                                Text(wrapper.accountKey.name)
                                    .accessibilityHidden(true)
                                Spacer()
                                Text("VALUE_ADD \(wrapper.accountKey.name)", bundle: .module)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                } header: {
                    if wrapper.accountKey == PersonNameKey.self,
                       let title = PersonNameKey.category.categoryTitle {
                        Text(title)
                    }
                }
            }
        }
            .navigationTitle(model.accountIdentifierLabel(configuration: account.configuration, userIdType: accountDetails.userIdType))
            .navigationBarTitleDisplayMode(.inline)
            .injectEnvironmentObjects(service: accountDetails.accountService, model: model)
            .environment(\.accountViewType, .overview(mode: .display))
    }


    init(model: AccountOverviewFormViewModel, details accountDetails: AccountDetails) {
        self.model = model
        self.accountDetails = accountDetails
    }
}


#if DEBUG
struct NameOverview_Previews: PreviewProvider {
    static let details = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")
        .set(\.name, value: PersonNameComponents(givenName: "Andreas", familyName: "Bauer"))

    static let detailsWithoutName = AccountDetails.Builder()
        .set(\.userId, value: "andi.bauer@tum.de")

    static let account = Account(building: details, active: MockUserIdPasswordAccountService())
    static let accountWithoutName = Account(building: detailsWithoutName, active: MockUserIdPasswordAccountService())

    // be aware, modifications won't be displayed due to declaration in PreviewProvider that do not trigger an UI update
    @StateObject static var model = AccountOverviewFormViewModel(account: account)

    static var previews: some View {
        NavigationStack {
            if let details = account.details {
                NameOverview(model: model, details: details)
            }
        }
            .environmentObject(account)

        NavigationStack {
            if let details = accountWithoutName.details {
                NameOverview(model: model, details: details)
            }
        }
        .environmentObject(accountWithoutName)
    }
}
#endif
