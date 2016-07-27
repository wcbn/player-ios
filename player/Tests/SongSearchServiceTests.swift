//
//  SongSearchServiceTests.swift
//  player
//
//  Created by Cameron Bothner on 7/17/16.
//  Copyright © 2016 Cameron Bothner. All rights reserved.
//

import XCTest

class SongSearchServiceTests: XCTestCase {
  let service = SpotifyService.sharedInstance

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testLookup() {
    let expectation = expectationWithDescription("fetches album art url")

    let song = Song(artist: "The Decemberists", name: "Sons and Daughters", album: "The Crane Wife", label: "Capitol", year: 2006, request: false, timestamp: NSDate())

    service.lookup(song) {
      print(self.service.albumArtURL())
      XCTAssertNotNil(self.service.albumArtURL())
      expectation.fulfill()
    }

    waitForExpectationsWithTimeout(10) { error in
      if error != nil {
        print("Timeout Error: \(error)")
      }
    }
  }

}
