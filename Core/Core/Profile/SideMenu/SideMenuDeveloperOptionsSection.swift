//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Combine
import Foundation
import SwiftUI

struct SideMenuDeveloperOptionsSection: View {
    @ObservedObject private var viewModel = SideDeveloperOptionsViewModel()
    @State var onDeveloperMenuTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SideMenuSubHeaderView(title: Text("DEVELOPER", bundle: .core))
            switch viewModel.nwAvailabilityStatus {
            case let .connected(connectionType):
                SideMenuItem(
                    id: "nwAvailabilityStatus",
                    image: .attendance,
                    title: Text("Connected via \(connectionType.rawValue.capitalized)")
                )
            case .disconnected:
                SideMenuItem(
                    id: "nwAvailabilityStatus",
                    image: .attendance,
                    title: Text("Disconnected")
                )
                .foregroundColor(.red)
            }
            Button {
                onDeveloperMenuTap()
            } label: {
                SideMenuItem(id: "developerMenu", image: .settingsLine, title: Text("Developer menu", bundle: .core))
            }
            .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
        }
    }
}

extension SideMenuDeveloperOptionsSection {
    final class SideDeveloperOptionsViewModel: ObservableObject {
        @Published var nwAvailabilityStatus: NWAvailabilityStatus = .disconnected

        private let nwAvailabilityService = NWAvailabilityServiceLive()
        private var subscriptions = Set<AnyCancellable>()

        init() {
            unowned let unownedSelf = self

            nwAvailabilityService.startMonitoring()

            nwAvailabilityService
                .startObservingStatus()
                .receive(on: DispatchQueue.main)
                .sink { unownedSelf.nwAvailabilityStatus = $0 }
                .store(in: &subscriptions)
        }
    }
}

#if DEBUG

struct SideMenuDeveloperOptionsSection_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuDeveloperOptionsSection(onDeveloperMenuTap: {})
    }
}

#endif
