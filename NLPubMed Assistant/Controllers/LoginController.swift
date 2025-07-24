//
//  LoginController.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 17.04.2024.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    @IBOutlet weak var loginForm: UIStackView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerForKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true) // Închide tastatura
    }

    private func setupUI() {
        // Adăugarea oricăror setări UI necesare
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Keyboard Handling
extension LoginController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.size.height

        let bottomOfLoginForm = loginForm.frame.origin.y + loginForm.frame.size.height
        let rootViewBottom = view.frame.size.height - bottomOfLoginForm
        let yOffset = keyboardHeight - rootViewBottom

        if yOffset > 0 { // Verifică dacă tastatura suprapune loginForm
            UIView.animate(withDuration: Constants.Animations.animationDuration) {
                self.view.frame.origin.y = -yOffset // Ridică view-ul doar cu cât este necesar
            }
        }
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        UIView.animate(withDuration: Constants.Animations.animationDuration) {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - LoginHandle

extension LoginController{
    @IBAction func loginHandle(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            if !validateForm(email: email, password: password){
                return;
            }
            
            Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
                if let e = error{
                    print(e)
                    Utils.Alerts.showAlertDialog(on: self, title: "Authentication Error!", message: "Email or Password Mismatch: Please Verify Your Credentials.")
                } else{
                    self.performSegue(withIdentifier: Constants.Sagues.loginIdentifier, sender: self)
                }
            }
        }else{
            Utils.Alerts.showAlertDialog(on: self, title: "Authentication Error!", message: "Please make sure you've entered both your email and password.")
        }
    }
}

//MARK: - Validation
extension LoginController{
    func validateForm(email: String, password: String) -> Bool{
        if !Utils.Validation.validateEmail(email){
            Utils.Alerts.showAlertDialog(on: self, title: "Invalid Email", message: "Please enter a valid email address.")
            return false;
        }
        return true;
    }
}
