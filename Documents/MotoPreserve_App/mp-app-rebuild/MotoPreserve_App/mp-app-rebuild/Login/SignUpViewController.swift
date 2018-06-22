//
//  SignUpViewController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/9/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import CoreData

class SignUpViewController: UIViewController {
    
    //logoButton
    let logoButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "logo_sign_in_").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.placeholder = "Email"
         tf.backgroundColor = UIColor(white: 0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.keyboardAppearance = .dark
        return tf
    }()
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            createAccountButton.backgroundColor = .mainRed()
            createAccountButton.isEnabled = true
        } else {
            createAccountButton.backgroundColor = .darkGray
            createAccountButton.isEnabled = false
        }
    }
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha:0.03)
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 12)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        tf.keyboardAppearance = .dark
        return tf
    }()
    
    //createAccountButton
    let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .mainRed()
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(didTapSignUp(_:)), for: .touchUpInside)
        button.isEnabled = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    let alreadyRegisteredButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor:UIColor.black])
        
        attributedTitle.append(NSAttributedString(string:"Sign In", attributes:[NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.mainRed()]))

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.isEnabled = true
        //button.tintColor = UIColor(r: 164, g: 8, b: 0)
        button.addTarget(self, action: #selector(handleGoToSignIn), for: .touchUpInside)
        return button
    }()
    
    @objc func handleGoToSignIn() {
        
        //let loginController = LoginViewController()
        navigationController?.popViewController(animated: true)
        // present(signupController, animated: true, completion: nil)
        //performSegue(withIdentifier: "GoToRegister", sender: nil)
    }

    
    
    var r:AnyObject!
    
    //var managedObjectContext:NSManagedObjectContext?
    
    @objc func didTapSignUp(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
    Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showAlert("Enter a valid email.")
                    case .emailAlreadyInUse:
                        self.showAlert("Email already in use.")
                    default:
                        self.showAlert("Error: \(error.localizedDescription)")
                    }
                }
                return
            }
            
              let values = ["email":self.emailTextField.text, "password":password]
            
            guard let uid = user?.uid else {
                return
            }
          
            self.signIn(uid: uid, values: values as [String : AnyObject])
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(logoButton)
        
        logoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 70, paddingBottom: 0, paddingRight: 70, width: 200, height: 200)

        logoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setupInputFields()
        
        //createAccountButton.layer.cornerRadius = 5
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, createAccountButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10  
        
        view.addSubview(stackView)
        view.addSubview(alreadyRegisteredButton)
        
        
        stackView.anchor(top: logoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 70, paddingBottom: 120, paddingRight: 70, width: 0, height: 120)
        view.addSubview(stackView)
        
        alreadyRegisteredButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
 func didTapBackToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "MotoPreserve", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.view.tintColor = UIColor.mainRed()
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func signIn(uid:String, values:[String: AnyObject]) {
        
        let ref = Database.database().reference(fromURL: "https://motopreserve-ebd6b.firebaseio.com/")
        let usersReference = ref.child("users").child((uid))
        self.r = ref
      
        usersReference.updateChildValues(values) { (err, ref) in
            if err != nil {
                print(err as Any)
                return
            }
           // print("Saved the user successfully")
        }
        let allBikesViewController = AllBikesViewController()
        let navController = UINavigationController(rootViewController: allBikesViewController)
        self.present(navController, animated: true, completion: nil)

    }
    
}

