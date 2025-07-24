//
//  RegisterController.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 17.04.2024.
//

import UIKit
import FirebaseAuth
class RegisterController: UIViewController {

    @IBOutlet weak var registerForm: UIStackView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true) // Închide tastatura
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - Keyboard Handling
extension RegisterController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.size.height

        let bottomOfStackView = registerForm.frame.origin.y + registerForm.frame.size.height
        let rootViewBottom = view.frame.size.height - bottomOfStackView
        let yOffset = keyboardHeight - rootViewBottom

        if yOffset > 0 {
            UIView.animate(withDuration: Constants.Animations.animationDuration) {
                self.view.frame.origin.y = -yOffset
            }
        }
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        UIView.animate(withDuration: Constants.Animations.animationDuration) {
            self.view.frame.origin.y = 0
        }
    }
}
// MARK: - Register
extension RegisterController{
    @IBAction func signUpPressed(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            Utils.Alerts.showAlertDialog(on: self, title: "Password Mismatch", message: "Please fill in all fields!")
            return
        }
        
        if !validateForm(email: email, password: password, confirmPassword: confirmPassword){
            return;
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e)
                Utils.Alerts.showAlertDialog(on: self, title: "Register Failed", message: "Unable to complete registration!")
            } else {
                // Registered successfully
                self.performSegue(withIdentifier: Constants.Sagues.registerIdentifier, sender: self)
            }
        }
    }
}
// MARK: - Validate
extension RegisterController{
    func validateForm(email: String, password: String, confirmPassword: String) ->Bool{
        if !Utils.Validation.validateEmail(email){
            Utils.Alerts.showAlertDialog(on: self, title: "Invalid Email", message: "Please enter a valid email address.")
            return false;
        }
        
        if !Utils.Validation.validatePasswordStrength(password){
            Utils.Alerts.showAlertDialog(on: self, title: "Weak Password", message: "Password must be at least 6 characters long.")
            return false
        }
        
        if !Utils.Validation.validatePasswordMatch(password, confirmPassword){
            Utils.Alerts.showAlertDialog(on: self, title: "Password Mismatch", message: "The passwords entered do not match.")
            return false;
        }
        return true
    }
}
