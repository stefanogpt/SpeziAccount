//
// This source file is part of the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct AccountRequiredModifier<SetupSheet: View>: ViewModifier {
    private let required: Bool
    private let setupSheet: SetupSheet

    @EnvironmentObject private var account: Account

    @State private var presentingSheet = false


    init(required: Bool, @ViewBuilder setupSheet: () -> SetupSheet) {
        self.required = required
        self.setupSheet = setupSheet()
    }


    func body(content: Content) -> some View {
        if required {
            content
                .onChange(of: [account.signedIn, presentingSheet]) { _ in
                    if !account.signedIn && !presentingSheet {
                        presentingSheet = true
                    }
                }
                .task {
                    try? await Task.sleep(for: .milliseconds(500))
                    if !account.signedIn {
                        presentingSheet = true
                    }
                }
                .sheet(isPresented: $presentingSheet) {
                    setupSheet
                        .interactiveDismissDisabled(true)
                }
                .environment(\.accountRequired, true)
        } else {
            content
        }
    }
}


extension View {
    /// Use this modifier to ensure that there is always an associated account in your app.
    ///
    /// If account requirement is set, this modifier will automatically pop open an account setup sheet if
    /// it is detected that the associated user account was removed.
    ///
    /// - Note: This modifier injects the ``SwiftUI/EnvironmentValues
    ///
    /// - Parameters:
    ///   - required: The flag indicating if an account is required at all times.
    ///   - setupSheet: The view that is presented if no account was detected. You may present the ``AccountSetup`` view here.
    ///     This view is directly used with the standard SwiftUI sheet modifier.
    /// - Returns: The modified view.
    public func accountRequired<SetupSheet: View>(_ required: Bool, @ViewBuilder setupSheet: () -> SetupSheet) -> some View {
        modifier(AccountRequiredModifier(required: required, setupSheet: setupSheet))
    }
}
