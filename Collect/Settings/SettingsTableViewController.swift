//
//  SettingsTableViewController.swift
//  Collect
//
//  Created by Adam Amran on 17/08/2018.
//  Copyright © 2018 Adam Amran. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBAction func closeScreenshot(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let email = MFMailComposeViewController()
            email.mailComposeDelegate = self
            email.setToRecipients(["collect.app@gmail.com"])
            email.setSubject("Collect app: Feedback")
            present(email, animated: true)
        } else {
            print ("Couldn't open e-mail")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendFeedback()
    }
    
}
