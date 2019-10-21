//
//  BasicSettingViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/4.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import Firebase
class BasicSettingViewController: UIViewController {
    var user:User?;
    @IBOutlet weak var usernameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self;
        
        usernameTextField.returnKeyType = .done;
        usernameTextField.tag = 3;
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        usernameTextField.resignFirstResponder();
        let userName = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines);
        if userName == ""{
            usernameTextField.text = "";
            present( Helper.showError("Username cannot be empty!"), animated: true, completion: nil);
        }else{
            user?.username = userName;
            Helper.saveCurrentUser(user: user!);
            let db = Firestore.firestore();
            db.collection("users").document(user!.userID!).setData(["username":userName!, "phoneNum":user!.phoneNum!], completion: { (error) in
                if error == nil {
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController;
                    if let homeVC = homeVC{
                        self.present(homeVC, animated: true, completion: nil);
                    }
                }else{
                    self.present(Helper.showError(error?.localizedDescription), animated: true, completion:nil) ;
                    return;
                }
            })
        }
    }

}
extension BasicSettingViewController: UITextFieldDelegate{
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
