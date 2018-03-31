//
//  TimeSeparatorModel.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 3/30/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit
import Chatto

class TimeSeparatorModel: ChatItemProtocol {

    let uid: String
    let type: String = TimeSeparatorModel.chatItemType
    let date: String
    
    static var chatItemType: ChatItemType {
        return "TimeSeparatorModel"
    }
    
    init(uid: String, date: String) {
        self.date = date
        self.uid = uid
    }

}
extension Date {
    // Have a time stamp formatter to avoid keep creating new ones. This improves performance
    private static let weekdayAndDateStampDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "EEEE, MMM dd yyyy" // "Monday, Mar 7 2016"
        return dateFormatter
    }()
    
    func toWeekDayAndDateString() -> String {
        return Date.weekdayAndDateStampDateFormatter.string(from: self)
    }
}
