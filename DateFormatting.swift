//
//  DateFormatting.swift
//  Live-Tracking_App
//
//  Created by Donghan Hu on 10/26/23.
//

import Foundation

class DateFormatting {
    
    func getTodayDateFormatString() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
//        let year = components.year
//        let month = components.month
//        let day = components.day
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromatString = dateFormatter.string(from: date)
        //print(dateFromatString)
        return dateFromatString
    }
    
    func transferToDateFormatString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromatString = dateFormatter.string(from: date)
        //print(dateFromatString)
        return dateFromatString
    }
    
    
}
