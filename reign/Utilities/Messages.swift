//
//  Messages.swift
//  reign
//
//  Created by Gerardo Villarroel on 31-05-22.
//

import UIKit

class Messages {

    //MARK: Mensajes
    static func showMessage(title: String, messageText: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    
    static func errorUrl() -> UIAlertController {
        return showMessage(title: "Ups", messageText: "This news doesn't have an url link to see more details.")
    }
    
    static func errorConnection() -> UIAlertController {
        return showMessage(title: "Ups", messageText: "Check your internet connection and retry!")
    }
}
