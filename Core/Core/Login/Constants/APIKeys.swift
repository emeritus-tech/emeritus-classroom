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

import Foundation

class EnvironmentConstants {
  static let baseUrl: String = {
    return getBundleValue(for: "Base URL")
  }()
  static let clientId: String = {
    return getBundleValue(for: "Client ID")
  }()
  static let clientSecret: String = {
    return getBundleValue(for: "Client Secret")
  }()
  static let redirectUri: String = {
    return getBundleValue(for: "Redirect URI")
  }()
  static func getBundleValue(for key: String) -> String {
    let value = Bundle.main.object(forInfoDictionaryKey: key) as? String
    return value ?? ""
  }
}
