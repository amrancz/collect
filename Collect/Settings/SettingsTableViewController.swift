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
            email.setSubject("Collect App: Feedback")
            present(email, animated: true)
        } else {
            let errorAlert = UIAlertController(title: "Couldn't open e-mail", message: "", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            }
            errorAlert.addAction(dismissAction)
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Send feedback" {
            sendFeedback()
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
