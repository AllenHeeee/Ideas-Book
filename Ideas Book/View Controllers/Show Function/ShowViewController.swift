//
//  ShowViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/9.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import Firebase

class ShowViewController: UIViewController {
    var photoArr = [Photos]();
    var allArr = [All]();
    var readMore = false;
    var user:User?;
    var currentIndex = 0;
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var textArr = [Text]();
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Helper.loadCurrentUser();
        // Configure the tableview
        tableView.delegate = self;
        tableView.dataSource = self
        
        // Set dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150;
        
        if currentIndex == 0{
            tableView.estimatedRowHeight = 150;
            getAll();
        }
        
    }
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            Helper.clearCurrentUser()
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
            if let homeVC = homeVC{
                self.view.window?.rootViewController = homeVC;
                self.view.window?.makeKeyAndVisible();
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func getText(){
        let db = Firestore.firestore()
        db.collection("users").document(user!.userID!).collection("text").order(by: "time",descending: true).getDocuments { (snapshot, error) in
            if error == nil{
                self.textArr.removeAll()
                Helper.textShowMore.removeAll();
                for document in snapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let timestampp = document.data()["time"] as! Timestamp
                    let date = timestampp.dateValue()
                    let dateFormatte = DateFormatter();
                    dateFormatte.dateFormat = "yyyy-MM-dd HH:mm"
                   // note.date = ;
                    let one = Text(time: dateFormatte.string(from: date), content: document.data()["text"] as? String);
                    print(one.content!);
                    print(one.time!)
                    self.textArr.append(one);
                    Helper.textShowMore.append(false)
                }
                self.tableView.reloadData()
            }else{
                self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil);
            }
        }
    }
    
    func getPhoto(){
        let db = Firestore.firestore()
        db.collection("users").document(user!.userID!).collection("photo").order(by: "time",descending: true).getDocuments { (snapshot, error) in
            if error == nil{
                self.photoArr.removeAll()
                for document in snapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let timestampp = document.data()["time"] as! Timestamp
                    let date = timestampp.dateValue()
                    let dateFormatte = DateFormatter();
                    dateFormatte.dateFormat = "yyyy-MM-dd HH:mm"
                    

                    let image1url = document.data()["image1URL"] as? String;
                    

                    let image2url = document.data()["image2URL"] as? String;

                    let image3url = document.data()["image3URL"] as? String;
                    
                    let two = Photos(time: dateFormatte.string(from: date), content: document.data()["text"] as? String, image1url: image1url, image2url: image2url, image3url: image3url)
                    self.photoArr.append(two);
                }
                self.tableView.reloadData()
            }else{
                self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil);
            }
        }
    }
    func showImage(image:UIImage){
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoReviewViewController") as? PhotoReviewViewController;
        if let vc = VC{
            vc.image = image;
        }
        present(VC!, animated: true, completion: nil);
    }
    func getAll(){
        let db = Firestore.firestore()
        db.collection("users").document(user!.userID!).collection("all").order(by: "time",descending: true).getDocuments { (snapshot, error) in
            if error == nil{
                Helper.textShowMore.removeAll();
                self.allArr.removeAll()
                for document in snapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let timestampp = document.data()["time"] as! Timestamp
                    let date = timestampp.dateValue()
                    let dateFormatte = DateFormatter();
                    dateFormatte.dateFormat = "yyyy-MM-dd HH:mm"
                    
                    
                    let image1url = document.data()["image1URL"] as? String;
                    
                    
                    let image2url = document.data()["image2URL"] as? String;
                    
                    let image3url = document.data()["image3URL"] as? String;
                    
                    let zero = All(time: dateFormatte.string(from: date), content: document.data()["text"] as? String, image1url: image1url, image2url: image2url, image3url: image3url)
                    self.allArr.append(zero);
                    Helper.textShowMore.append(false)
                }
                self.tableView.reloadData()
            }else{
                self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil);
            }
        }
    }
    
    @IBAction func segChooseTapped(_ sender: Any) {
        print(segControl.selectedSegmentIndex)
        currentIndex = segControl.selectedSegmentIndex;
        if currentIndex == 0{
            tableView.estimatedRowHeight = 150;
            getAll();
        }
        else if currentIndex == 1{
            tableView.estimatedRowHeight = 150;
            getText();
        }else if currentIndex == 2{
            getPhoto()
            tableView.estimatedRowHeight = 300;
        }
        else{
            tableView.reloadData()
        }
        
        
    }
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
}
extension ShowViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if currentIndex == 0{
            return allArr.count;
        }
        if currentIndex == 1{
            return textArr.count;
        }
        if currentIndex == 2{
            return photoArr.count;
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentIndex == 0{
            let textCell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell;
            let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell;
            if indexPath.row >= allArr.count{
                textCell.label.text = "";
                textCell.TimeLabel.text = "";
                return textCell;
            }
            if allArr[indexPath.row].image1url == nil{
                // This is a text cell
                textCell.delegate = self;
                print(tableView.contentOffset.y)
                textCell.label.text = allArr[indexPath.row].content;
                textCell.TimeLabel.text = allArr[indexPath.row].time;
                textCell.indexpathRow = indexPath.row;
                
                if Helper.textShowMore[indexPath.row] == false{
                    textCell.showLess();
                }
                
                if allArr[indexPath.row].content!.count < 240 {
                    textCell.readMoreButton.alpha = 0;
                    textCell.readMoreButton.isEnabled = false;
                }
                if Helper.textShowMore[indexPath.row] == true && textCell.alreadyReadMore == false{
                    textCell.showMore()
                    print(tableView.contentOffset.y)
                    
                }
                return textCell;
            }else{
                photoCell.delegate = self;
                var photo = Photos();
                photo.content = allArr[indexPath.row].content;
                photo.time = allArr[indexPath.row].time;
                photo.image1url = allArr[indexPath.row].image1url;
                photo.image2url = allArr[indexPath.row].image2url;
                photo.image3url = allArr[indexPath.row].image3url;
                 photoCell.show(photo)
                return photoCell;
            }
        }
        else if currentIndex == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell;
            if indexPath.row >= textArr.count{
                cell.label.text = "";
                cell.TimeLabel.text = "";
            }else{
                cell.delegate = self;
                print(tableView.contentOffset.y)
                cell.label.text = textArr[indexPath.row].content;
                cell.TimeLabel.text = textArr[indexPath.row].time;
                cell.indexpathRow = indexPath.row;
                
                if Helper.textShowMore[indexPath.row] == false{
                    cell.showLess();
                }
                
                if textArr[indexPath.row].content!.count < 240 {
                    cell.readMoreButton.alpha = 0;
                    cell.readMoreButton.isEnabled = false;
                }
                if Helper.textShowMore[indexPath.row] == true && cell.alreadyReadMore == false{
                    
//                    let offset = tableView.contentOffset
                    cell.showMore()
                    print(tableView.contentOffset.y)
                    
                }
                
            }
            return cell;
        }else if currentIndex == 2{
           let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell;
            cell.delegate = self;
            if indexPath.row >= photoArr.count{
                cell.contentLabel.text = "";
                cell.timeLabel.text = "";
            }else{
                cell.show(photoArr[indexPath.row])
            }
            return cell;
            
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextTableViewCell", for: indexPath) as! TextTableViewCell;
        return cell;

    }
}
extension ShowViewController:CustomCellUpdater{
    func updateTableView() {
         tableView.reloadData()
    }
}
extension ShowViewController:photoReview{
    func pushSeg(image: UIImage) {
        showImage(image: image);
    }
}
