//
//  SignUpViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/3.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var phoneText: FPNTextField!
    @IBOutlet weak var varifcationCodeText: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.groupTableViewBackground
        phoneText.parentViewController = self
        self.phoneText.delegate = self;
        self.varifcationCodeText.delegate = self;

        phoneText.hasPhoneNumberExample = false // true by default
        phoneText.placeholder = "Phone Number"
        phoneText.setCountries(including:[.US,.CN,.FR, .ES, .IT, .BE, .LU, .DE])
        
        varifcationCodeText.returnKeyType = .next;
        varifcationCodeText.tag = 1;

    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let user = Helper.loadCurrentUser();
            if user?.userID != nil {
                print("YES")
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                if let homeVC = homeVC{
                    self.view.window?.rootViewController = homeVC;
                    self.view.window?.makeKeyAndVisible();
                }
            }
        }
    }
    
    @IBAction func getCodeTapped(_ sender: Any) {
        phoneText.resignFirstResponder();
        
        // Check if textfields are empty
        if phoneText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            present(Helper.showError("Phone number is required!"), animated: true, completion: nil);
        }
        
        phoneText.text = phoneText.text?.trimmingCharacters(in: .whitespacesAndNewlines);
        let num = phoneText.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
        print(num)
        PhoneAuthProvider.provider().verifyPhoneNumber(num, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.present(Helper.showError(error.localizedDescription), animated: true, completion: nil)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        
        phoneText.resignFirstResponder();
        varifcationCodeText.resignFirstResponder()
//        passwordText.resignFirstResponder()
//        usernameTextField.resignFirstResponder();
        
        // Check if textfields are empty
        if varifcationCodeText.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            present(Helper.showError("All of the fields are required!"), animated: true, completion: nil);
        }
        
//        if Helper.isPasswordValid(passwordText.text!) == false{
//            present(Helper.showError("Passwords are not valid! Password must contain lower case letters and number, and length more than 7 characters."), animated: true) {
//                self.passwordText.text = "";
//                return;
//            }
//        }
        
//        let password = passwordText.text?.trimmingCharacters(in: .whitespacesAndNewlines);
//        let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines);
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: self.varifcationCodeText.text!)
            Auth.auth().signIn(with: credential, completion: { (result, error) in
            if error == nil{
                print("Signed in");
                if result!.additionalUserInfo!.isNewUser {
                    let basicSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "BasicSettingViewController") as? BasicSettingViewController
                        if let basicSettingVC = basicSettingVC{
                            basicSettingVC.user = User(username: "", phoneNum: self.phoneText.text, userID: result?.user.uid)
                            self.present(basicSettingVC, animated: true, completion: nil);
                        }
                }else{
                    let db = Firestore.firestore()
                    let docRef = db.collection("users").document(result!.user.uid);
                    
                    docRef.getDocument(completion: { (document, error) in
                        if error == nil{
                            if let document = document, document.exists {
                                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                let user = User(username: document.get("username") as? String, phoneNum: document.get("phoneNum") as? String, userID: result?.user.uid)
                                Helper.saveCurrentUser(user: user);
                                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                                if let homeVC = homeVC{
                                    self.present(homeVC, animated: true, completion: nil);
                                }
                                print("Document data: \(dataDescription)")
                            } else {
                                print("Document does not exist")
                            }
                        }
                    });
                }
                

                
            }else{
                self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil)
                return
            }
        })
    }

}
extension SignUpViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}


extension SignUpViewController: FPNTextFieldDelegate {
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        //        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
        //
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
}
