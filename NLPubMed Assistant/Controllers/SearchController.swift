//
//  SearchController.swift
//  NLPubMed Assistant
//
//  Created by Octa Marina on 18.04.2024.
//

import UIKit
import FirebaseAuth

class SearchController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var mainView: UIStackView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var textFieldStack: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView!
        var articlesManager = ArticlesManager()
        var articles: [ArticleModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MediCortex"
        navigationItem.hidesBackButton = true
        articlesManager.delegate = self
        setupTableView()
        configureTextView()
        configureSendButton()
        setupActivityIndicator()
        registerForKeyboardNotifications()
        activateScrollEdgeNavbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let window = view.window { // Ensure the window is available
            window.addSubview(activityIndicator)
            setupActivityIndicatorConstraints(to: window)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
            Utils.Alerts.showAlertDialog(on: self, title: "Authentication Error", message: "No authenticated user found.")
            return
        }
        
        user.getIDToken { token, error in
            if let error = error {
                print("Error fetching Firebase token: \(error)")
                Utils.Alerts.showAlertDialog(on: self, title: "Token Error", message: "Unable to fetch authentication token.")
                return
            }

            guard let authToken = token else {
                print("Token is nil")
                Utils.Alerts.showAlertDialog(on: self, title: "Token Error", message: "Authentication token is nil.")
                return
            }

            if let text = self.textField.text, !text.isEmpty {
                self.textField.isEditable = false
                self.sendButton.isEnabled = false
                self.articlesManager.fetchArticles(text: text, email: user.email ?? "", authToken: authToken)
                self.toggleButtonAndIndicator(showIndicator: true)
            } else {
                Utils.Alerts.showAlertDialog(on: self, title: "Empty text", message: "The text you want to send is empty!")
            }
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let article = self.articles[indexPath.row]
            self.performSegue(withIdentifier: Constants.Sagues.openWebviewIdentifier, sender: article.url)
            tableView.deselectRow(at: indexPath, animated: true)  // Deselectează rândul după ce face segue
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Sagues.openWebviewIdentifier {
            if let webVC = segue.destination as? WebViewController, let url = sender as? String {
                webVC.urlToLoad = url
            }
        }
    }
    
// MARK: - SETUP UI
    func activateScrollEdgeNavbar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemPink]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    
    func hideBarBorder() {
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = nil
    }
    
    func setupActivityIndicatorConstraints(to window: UIWindow) {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        ])
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        // Do not add it here anymore
    }
    
    func configureSendButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)  // Ajustează dimensiunea conform necesității
        let image = UIImage(systemName: "square.and.arrow.up.fill", withConfiguration: largeConfig)
        
        var config = UIButton.Configuration.plain()
        config.image = image
        config.baseForegroundColor = UIColor.systemPink  // setează culoarea iconului
        
        sendButton.configuration = config
    }
    
    func configureTextView() {

        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textField.backgroundColor = UIColor.white
        textField.clipsToBounds = true
    }

    func toggleButtonAndIndicator(showIndicator: Bool) {
        if showIndicator {
            activityIndicator.startAnimating()
            sendButton.isEnabled = false
        } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.sendButton.isEnabled = true
            }
        }
    }

    // MARK: - Keyboard Handling
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardHeight = keyboardFrame.size.height

        let bottomOfStackView = textFieldStack.frame.origin.y + textFieldStack.frame.size.height
        let rootViewBottom = view.frame.size.height - bottomOfStackView
        let yOffset = keyboardHeight - rootViewBottom + 35

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

    @IBAction func logoutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            hideBarBorder()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}


// MARK: - ArticlesManager delegate
extension SearchController: ArticlesManagerDelegate {
    func didUpdateArticles(_ articles: ArticlesModel) {
        self.articles = articles.articles  // Update the articles array
        DispatchQueue.main.async {  // Ensure UI updates on the main thread
            self.tableView.reloadData()  // Reload table data
            self.toggleButtonAndIndicator(showIndicator: false)
            // Reactivate the input and button
            self.textField.text = ""
            self.textField.isEditable = true
            self.sendButton.isEnabled = true
        }
    }
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.toggleButtonAndIndicator(showIndicator: false)
            Utils.Alerts.showAlertDialog(on: self, title: "Connection Error", message: "We encountered a problem connecting to the server. Please try again later.")
        }
    }
}


// MARK: - Table view
extension SearchController: UITableViewDataSource{
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: "ArticleCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // Ajustează în funcție de conținut
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = articles[indexPath.row].title  // Corectat aici, eliminând punctul dublu și accesând corect proprietatea 'title'
        return cell
    }

}

