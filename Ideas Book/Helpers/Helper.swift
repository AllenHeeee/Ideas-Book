//
//  Helper.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/3.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Helper{
    static var imageArr = [UIImage]();
    static var textShowMore = [Bool]();

    static func showError(_ message:String?) -> UIAlertController{
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil);
        alert.addAction(cancelAction);
        return alert
    }
    static func showMessage(_ messageTitle:String?,_ messageContent:String?) -> UIAlertController{
        let alert = UIAlertController(title: messageTitle, message: messageContent, preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil);
        alert.addAction(cancelAction);
        return alert
    }
    
    
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    static func saveCurrentUser(user:User){
        
        // Get standard user defaults
        let defaults = UserDefaults.standard;
        defaults.set(user.username, forKey: "username");
        defaults.set(user.phoneNum, forKey: "phoneNum");
        defaults.set(user.userID, forKey: "userID");
    }
    static func loadCurrentUser()->User?{
        
        // Get standard user defaults
        let defaults = UserDefaults.standard;
        
        let username=defaults.value(forKey: "username") as? String;
        let phoneNum=defaults.value(forKey: "phoneNum") as? String;
        let uid=defaults.value(forKey: "userID") as? String;
        
        return User(username: username, phoneNum: phoneNum, userID:uid);
    }
    static func clearCurrentUser(){
        
        // Get standard user defaults
        let defaults = UserDefaults.standard;
        defaults.set(nil, forKey: "username");
        defaults.set(nil, forKey: "phoneNum");
        defaults.set(nil, forKey: "userID");

    }
    
    static func isNewUser(uid:String) ->Bool{
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(uid);
        var ru = true;
        docRef.getDocument(completion: { (document, error) in
            if error == nil{
                ru = false;
            }
        });
        return ru;
    }
    
}
