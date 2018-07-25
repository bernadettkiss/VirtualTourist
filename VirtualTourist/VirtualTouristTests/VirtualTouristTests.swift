//
//  VirtualTouristTests.swift
//  VirtualTouristTests
//
//  Created by Bernadett Kiss on 7/23/18.
//  Copyright © 2018 Bernadett Kiss. All rights reserved.
//

import XCTest

class VirtualTouristTests: XCTestCase {
    
    var latitude = String()
    var longitude = String()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCoordinateVerificationWithEmptyStrings() {
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithEmptyLatitude() {
        longitude = "90.0"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithEmptyLongitude() {
        latitude = "90.0"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithNotConvertibleStrings() {
        latitude = "test"
        longitude = "test.test"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithLatitudeLessThanMin() {
        latitude = "-100.0"
        longitude = "90.0"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithLatitudeGreaterThanMax() {
        latitude = "100.0"
        longitude = "90.0"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithLongitudeLessThanMin() {
        latitude = "0.0"
        longitude = "-185.0"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithLongitudeGreaterThanMax() {
        latitude = "50.0"
        longitude = "190.0"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        XCTAssert(result == false)
    }
    
    func testCoordinateVerificationWithSanFranciscoCoordinate() {
        latitude = "37.774"
        longitude = "122.4194"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        print(result)
        XCTAssert(result == true)
    }
    
    func testCoordinateVerificationWithSydneyCoordinate() {
        latitude = "33.8688"
        longitude = "151.2093"
        let result = FlickrClient.shared.verifyCoordinate(latitudeString: latitude, longitudeString: longitude)
        print(result)
        XCTAssert(result == true)
    }
}
