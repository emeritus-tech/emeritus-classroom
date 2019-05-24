//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core
import XCTest

class GetModulesTests: CoreTestCase {
    let useCase = GetModules(courseID: "1")

    func testScopePredicate() {
        let yes = Module.make(from: .make(id: "1"), forCourse: "1")
        let no = Module.make(from: .make(id: "2"), forCourse: "2")
        XCTAssert(useCase.scope.predicate.evaluate(with: yes))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: no))
    }

    func testScopeOrder() {
        let one = Module.make(from: .make(id: "1", position: 1))
        let two = Module.make(from: .make(id: "2", position: 2))
        let three = Module.make(from: .make(id: "3", position: 3))
        let order = useCase.scope.order[0]
        XCTAssertEqual(order.compare(one, to: two), .orderedAscending)
        XCTAssertEqual(order.compare(two, to: three), .orderedAscending)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-modules-1")
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.path, "courses/1/modules")
    }

    func testWrite() {
        let item = APIModule.make(items: [.make()])
        try! useCase.write(response: [item], urlResponse: nil, to: databaseClient)

        let module: Module = databaseClient.fetch().first!
        XCTAssertEqual(module.id, item.id.value)
        XCTAssertEqual(module.courseID, "1")
        let moduleItem: ModuleItem = databaseClient.fetch().first!
        XCTAssertEqual(moduleItem.moduleID, module.id)
        XCTAssertEqual(moduleItem.courseID, "1")
    }
}
