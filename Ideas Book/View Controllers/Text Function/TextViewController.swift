//
//  TextViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/6.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import Firebase
class TextViewController: UIViewController {
    
    var user:User?;
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Helper.loadCurrentUser();
        // Do any additional setup after loading the view.
        textView.becomeFirstResponder();
        postButton.isEnabled = true;

    }
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard;
        let savedText = defaults.value(forKey: "savedTextForText") as? String;
        if savedText != nil{
            present(showSaveAlert(), animated: true, completion: nil);
        }
    }
    func showSaveAlert() -> UIAlertController{
        let alert = UIAlertController(title: "Would you like to recover your draft?", message: "If not recover, the draft will be deleted forever.", preferredStyle: .alert);
        let recoverAction = UIAlertAction(title: "Recover", style: .destructive) { (action) in
            let defaults = UserDefaults.standard;
            self.textView.text = defaults.value(forKey: "savedTextForText") as? String;
            defaults.set(nil, forKey: "savedTextForText");
        }
        alert.addAction(recoverAction);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            let defaults = UserDefaults.standard;
            defaults.set(nil, forKey: "savedTextForText");
        }
        alert.addAction(cancelAction);
        return alert;
    }
    func showSaveMessage() -> UIAlertController{
        let alert = UIAlertController(title: "Would you like to save the draft?", message: "If saved, the draft can be recovered in the future.", preferredStyle: .actionSheet);
        let saveAction = UIAlertAction(title: "Save", style: .destructive) { (action) in
            let defaults = UserDefaults.standard;
            defaults.set(self.textView.text, forKey: "savedTextForText");
            self.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        alert.addAction(saveAction);
        let unSaveAction = UIAlertAction(title: "Discard", style: .default) { (action) in
            let defaults = UserDefaults.standard;
            defaults.set(nil, forKey: "savedTextForText");
            self.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        alert.addAction(unSaveAction);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        alert.addAction(cancelAction);
        return alert;
    }
    @IBAction func cancelTapped(_ sender: Any) {
        textView.resignFirstResponder();
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            present(showSaveMessage(), animated: true, completion: nil);
            return;
        }
        let defaults = UserDefaults.standard;
        defaults.set(nil, forKey: "savedTextForText");
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postTapped(_ sender: Any) {
        postButton.isEnabled = false;
         textView.resignFirstResponder();
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            present(Helper.showError("Cannot post empty text!"), animated: true, completion: nil);
            return;
        }
        let textContent = textView.text;
        let db = Firestore.firestore()
        let filename = UUID().uuidString;
        let time = Timestamp(date: Date());
        db.collection("users").document(user!.userID!).collection("text").document(filename).setData(["text":textContent!, "time":time]) { (error) in
            if error == nil{
                print("success!!!!")
                db.collection("users").document(self.user!.userID!).collection("all").document(filename).setData(["text":textContent!, "time":time]) { (error) in
                    if error == nil{
                        print("success!!!!")
                        self.dismiss(animated: true, completion: nil);
                    }
                    else{
                         self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil);
                    }
                }
            }else{
                self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil);
            }

        }

    }

}
