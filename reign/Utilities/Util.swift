//
//  Util.swift
//  reign
//
//  Created by Gerardo Villarroel on 31-05-22.
//

import UIKit
import SystemConfiguration

class Util {
    
    //MARK: Getter and Setter news deleted
    static func getNewsDeleted() -> [Int64] {
        return UserDefaults.standard.array(forKey: "NewsDeleted") as? [Int64] ?? [Int64]()
    }
    
    static func setNewsDeleted(storyId: Int64) {
        var array = getNewsDeleted()
        array.append(storyId)
        UserDefaults.standard.set(array, forKey: "NewsDeleted")
    }

    //----------------------------------------------------------------------------------------------
    //MARK: Check internet connection
    static func checkInternetAccess() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        //Working for 4G and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        return ret
    }
    
    //MARK: Merge url + parameters
    static func cloudConnect(api_url: String, parms: String) -> URLRequest {
        let url = URL(string: api_url + "?" + parms)!
        return URLRequest(url: url)
    }
    
    //MARK: Date formatter
    static func isoDateToDate(isoDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        return dateFormatter.date(from: isoDate)!
    }
    
    //MARK: Get diference between NewsDate and Now
    static func dateToTimeInterval(newsDate: Date) -> String {
        let diffSeconds = Date.now.timeIntervalSinceReferenceDate - newsDate.timeIntervalSinceReferenceDate

        let minutes = Int(diffSeconds / 60.0)
        let hours = diffSeconds / (60.0 * 60.0)
        let days = Int(diffSeconds / (60.0 * 60.0 * 24.0))
        
        if days > 1 {
            return "\(days)d"
        } else if days == 1 {
            return "Yesterday"
        } else if hours <= 23 && hours > 1 {
            return "\(Int(hours))h"
        } else if minutes > 59 {
            return "\(Double(10 * hours / 10))h"
        } else {
            return "\(minutes)m"
        }
    }
}
