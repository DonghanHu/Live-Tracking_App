//
//  singleApplication.swift
//  Live-Tracking_App
//
//  Created by Donghan Hu on 10/26/23.
//

import Foundation

class singleApplication{
    var applicationName: String!
    var trackingTime : Int!
    var applicationCategory: String!
    var videoID: String!
    
    // constructor method
    init(applicationName: String!, trackingTime: Int!, applicationCategory: String!, videoID: String!) {
        self.applicationName = applicationName
        self.trackingTime = trackingTime
        self.applicationCategory = applicationCategory
        self.videoID = videoID
    }
    
    // set new category for this application/video
    func setApplicationCategory(newCategory: String!){
        self.applicationCategory = newCategory
    }
    
    func getApplicationCategory() -> String{
        return self.applicationCategory
    }
    
    func getTrackingTime() -> Int{
        return self.trackingTime
    }
    
    
}
