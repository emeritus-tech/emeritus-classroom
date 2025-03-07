//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import XCTest
@testable import Core

open class E2ETestCase: CoreUITestCase {

    open override var user: UITestUser {.dataSeedAdmin}
    private let isRetry = ProcessInfo.processInfo.environment["CANVAS_TEST_IS_RETRY"] == "YES"
    public let seeder = DataSeeder()
    open override var useMocks: Bool {false}

    open override func setUp() {
        doLoginAfterSetup = false
        super.setUp()
    }

    open func logInDSUser(_ dsUser: DSUser) {
        // Test retries can work with last logged in instance
        if LoginStart.lastLoginButton.exists() {
            LoginStart.lastLoginButton.tap()
        } else {
            LoginStart.findSchoolButton.tap()
            LoginFindSchool.searchField.pasteText("\(user.host)")
            LoginFindSchool.searchField.typeText("\r")
        }

        LoginWeb.emailField.waitToExist(60)
        LoginWeb.emailField.pasteText(dsUser.login_id)
        LoginWeb.passwordField.tap().pasteText("password")
        LoginWeb.logInButton.tap()

        homeScreen.waitToExist()
        user.session = currentSession()
        setAppThemeToSystem()
    }

    // Workaround to handle app theme prompt
    open func setAppThemeToSystem() {
        let canvasThemePromptTitle = app.find(label: "Canvas is now available in dark theme")
        let systemSettingsButton = app.find(label: "System settings", type: .button)
        if canvasThemePromptTitle.waitToExist(5, shouldFail: false).exists() {
            systemSettingsButton.tapUntil {
                !canvasThemePromptTitle.exists()
            }
        }
    }
}
