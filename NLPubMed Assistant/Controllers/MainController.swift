//
//  ViewController.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 17.04.2024.
//

import UIKit
import FirebaseAuth
class MainController: UIViewController {
    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = ""
        logoIcon.alpha = 0

        
        logoIcon.layer.shadowColor = UIColor.black.cgColor
        logoIcon.layer.shadowOpacity = 0.15
        logoIcon.layer.shadowOffset = CGSize(width: 5, height: 5) // Offset-ul umbrei
        logoIcon.layer.shadowRadius = 3

        self.typeText("MediCortex", characterDelay: 0.1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }
    
    func checkAuthentication(){
        if Auth.auth().currentUser != nil {
            print("loged in")
            performSegue(withIdentifier: Constants.Sagues.autoLoginIdentifier, sender: self)
        }
    }

    func typeText(_ text: String, characterDelay: TimeInterval) {
        var characterIndex = 0
        let titleText = text
        Timer.scheduledTimer(withTimeInterval: characterDelay, repeats: true) { [weak self] timer in
            guard let strongSelf = self else { return }
            if characterIndex < titleText.count {
                let charIndex = titleText.index(titleText.startIndex, offsetBy: characterIndex)
                strongSelf.titleLabel.text?.append(titleText[charIndex])
                   characterIndex += 1
            } else {
                timer.invalidate()
                strongSelf.showLogo() // Apelează pentru a arăta logo-ul după terminarea efectului de typing
            }
        }
    }

    func showLogo() {
        UIView.animate(withDuration: 1.0, animations: {
            self.logoIcon.alpha = 1 // Efect de fade-in pentru logo
        })
    }
}

