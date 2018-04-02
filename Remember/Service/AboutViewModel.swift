//
//  AboutViewModel.swift
//  Remember
//
//  Created by Songbai Yan on 10/01/2017.
//  Copyright © 2017 Songbai Yan. All rights reserved.
//

import Foundation

class AboutViewModel {
    func getAppName() -> String {
        return NSLocalizedString("appName", comment: "丁丁记事")
    }
    
    func getSlogan() -> String {
        return NSLocalizedString("rememberEveryThing", comment: "")
    }
    
    func getVersionInfo() -> String {
        return "\(NSLocalizedString("version", comment: "版本号"))V\(getCurrentVersion())"
    }
    
    func getCurrentVersion(_ bundleVersion: Bool = false) -> String {
        guard let infoDic = Bundle.main.infoDictionary else {return ""}
        guard let currentVersion = infoDic["CFBundleShortVersionString"] as? String else {return ""}
        if let buildVersion = infoDic["CFBundleVersion"] as? String, bundleVersion == true {
            return currentVersion + buildVersion
        } else {
            return currentVersion
        }
    }
}
