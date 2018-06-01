//
//  CharacterGeneratorUITests.swift
//  CharacterGeneratorUITests
//
//  Created by Brian Arnold on 7/4/17.
//  Copyright © 2017 Brian Arnold. All rights reserved.
//

import XCTest

class CharacterGeneratorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
 
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // TODO: reset state once we have more state
        
        super.tearDown()
    }
    
    func testAddingAndShowingDetail() {
        let app = XCUIApplication()
        let playersNavigationBar = app.navigationBars["Players"]
        let addButton = playersNavigationBar.buttons["Add"]
        addButton.tap()
        addButton.tap()
        addButton.tap()
        
        let tablesQuery = app.tables
        XCTAssertEqual(tablesQuery.cells.count, 3, "Expected 3 items")
        tablesQuery.cells.element(boundBy: 1).tap()
        app.navigationBars["Character Sheet"].buttons["Players"].tap()
        
        // TODO: more checks
    }
    
}
