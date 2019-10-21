//
//  ReviewPhotoViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/7.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit

class ReviewPhotoViewController: UIViewController {
    var photo:UIImage!;
    var index:Int?;
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = photo
        let rightSwift = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        let leftSwift = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        leftSwift.direction = .left;
        view.addGestureRecognizer(rightSwift);
        view.addGestureRecognizer(leftSwift);
    }
    @objc func handleSwipe(sender:UISwipeGestureRecognizer){
        if sender.state == .ended{
            switch sender.direction{
            case .right:
                if self.index!-1 >= 0{
//                    callReviewVC(index: self.index!-1);
                    self.index! -= 1;
                    photo = Helper.imageArr[self.index!];
                    self.imageView.image = self.photo
//                    UIImageView.animate(withDuration: 10, delay: 0, options: .transitionCurlDown, animations: {
//                        self.imageView.image = self.photo
//                    }, completion: nil)
                }else {
                    break;
                }
                
            default:
                if self.index!+1 < Helper.imageArr.count{
//                     callReviewVC(index: self.index!+1)
                    self.index! += 1;
                    photo = Helper.imageArr[self.index!];
                    self.imageView.image = self.photo
//                    UIImageView.animate(withDuration: 10, delay: 0, options: .transitionCurlUp, animations: {
//
//                    }, completion: nil)
                }else {
                    break;
                }
               
            }

        }
    }
    @IBAction func deleteTapped(_ sender: Any) {
        Helper.imageArr.remove(at: index!);
        dismiss(animated: true, completion: nil);
    }
    @IBAction func donetapped(_ sender: Any) {
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoEditViewController") as? PhotoEditViewController
        if let vc = editVC{
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        }
    }


}
