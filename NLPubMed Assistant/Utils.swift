//
//  Utils.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 18.04.2024.
//

import Foundation
import UIKit

struct Utils {
    struct Alerts{
        static func showAlertDialog(on viewController: UIViewController, title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                viewController.present(alert, animated: true, completion: nil)
            }
        }
    }
    struct Validation{
        static func isValidEmail(_ email: String) -> Bool {
            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailPattern)
            return emailPred.evaluate(with: email)
        }
        
        // Function to validate email
        static func validateEmail(_ email: String) -> Bool {
            if !isValidEmail(email) {
                return false
            }
            return true
        }

        // Function to validate password matching
        static func validatePasswordMatch(_ password: String, _ confirmPassword: String?) -> Bool {
            if password != confirmPassword {
                return false
            }
            return true
        }

        // Function to validate password strength
        static func validatePasswordStrength(_ password: String) -> Bool {
            if password.count < 6 {
                return false
            }
            return true
        }
    }
}

