//
//  RegisterViewController.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 25/10/23.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    private let spinner=JGProgressHUD(style: .dark)
    
    private var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds=true
        return imageView
    }()
    
    private var emailField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private var firstNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private var lastNameField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private var passwordField : UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        return field
    }()
    
    private var registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title="Register"
        view.backgroundColor = .white
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        emailField.delegate=self
        passwordField.delegate=self
        
        //Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        //To make is user interactive so that we can select photo when user taps on imageView
        scrollView.isUserInteractionEnabled=true
        imageView.isUserInteractionEnabled=true
        
        //We can use this tap gesture to dismiss keyboard when tapped anywhere on screen in seperate func by using didEndEditing
        let gesture=UITapGestureRecognizer(target: self, action: #selector(didTapProfilePic))
        imageView.addGestureRecognizer(gesture)
        
    }
    
    @objc private func didTapProfilePic(){
        presentPhotoActionSheet()
    }
    
    //called when view controller's view and its subviews have had their layout constraint updated.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size=scrollView.width/3 //used shorthand by extension of uiview
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius=imageView.width/2
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                 height: 52)
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom+20,
                                  width: scrollView.width-60,
                                 height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+20,
                                  width: scrollView.width-60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+20,
                                  width: scrollView.width-60,
                                 height: 52)
        registerButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom+40,
                                  width: scrollView.width-60,
                                 height: 52)
        
    }
    @objc private func registerButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,let lastName = lastNameField.text,let email = emailField.text,let password = passwordField.text,!email.isEmpty,!firstName.isEmpty,!lastName.isEmpty,password.count>=6
        else{
            showLoginAlertError()
            return
        }
        
        spinner.show(in: view)
        //Firebase register
        DatabaseManager.shared.userExists(with: email) {[weak self] exists in
            guard !exists else{
                //User already exists
                self?.showLoginAlertError(message: "This email already exists.")
                return
            }
            
            DispatchQueue.main.async {
                self?.spinner.dismiss()
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) {[weak self] authDataResult, error in
                guard authDataResult != nil,error==nil else{
                    print("Error creating user")
                    return
                }
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                self?.navigationController?.dismiss(animated: true)
            }
        }
        
        
    }
    
    private func showLoginAlertError(message:String = "Please enter correct details"){
        let alert = UIAlertController(title: "Woops..", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc=RegisterViewController()
        vc.title="Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    

}


extension RegisterViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField==emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField==passwordField{
            registerButtonTapped()
        }
        return true
    }
}

extension RegisterViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: {[weak self] _ in
                self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: {[weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate=self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate=self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
