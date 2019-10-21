//
//  PhotoTableViewCell.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/10.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import SDWebImage
protocol photoReview: class { // the name of the protocol you can put any
    func pushSeg(image:UIImage)
}
class PhotoTableViewCell: UITableViewCell {
    weak var delegate: photoReview?
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func push (image:UIImage) {
        delegate?.pushSeg(image: image)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func editTapped(_ sender: Any) {
        print(1)
    }
    @IBAction func button1Tapped(_ sender: Any) {
        if imageView1.image != nil{
            push(image: imageView1.image!)
        }
    }
    @IBAction func button2Tapped(_ sender: Any) {
        if imageView2.image != nil{
            push(image: imageView2.image!)
        }
        
    }
    @IBAction func button3Tapped(_ sender: Any) {
        if imageView3.image != nil{
            push(image: imageView3.image!)
        }
        
    }
    
    func show(_ photo:Photos) {
        imageView1.layer.cornerRadius = imageView1.frame.width/2;
        imageView1.clipsToBounds = true;
        imageView2.layer.cornerRadius = imageView2.frame.width/2;
        imageView2.clipsToBounds = true;
        imageView3.layer.cornerRadius = imageView3.frame.width/2;
        imageView3.clipsToBounds = true;
        self.timeLabel.text = photo.time;
        self.contentLabel.text = photo.content;
        if let urlString = photo.image1url {
            let url = URL(string: urlString);
            guard url != nil else{
                return;
            }
            imageView1.sd_setImage(with: url) { (image, error, cacheType, url) in
                self.imageView1.image = image;
            }
        }else{
            imageView1.image = nil;
        }
        if let urlString = photo.image2url {
            let url = URL(string: urlString);
            guard url != nil else{
                return;
            }
            imageView2.sd_setImage(with: url) { (image, error, cacheType, url) in
                self.imageView2.image = image;
            }
        }else{
            imageView2.image = nil;
        }
        
        if let urlString = photo.image3url {
            let url = URL(string: urlString);
            guard url != nil else{
                return;
            }
            imageView3.sd_setImage(with: url) { (image, error, cacheType, url) in
                self.imageView3.image = image;
            }
        }else{
            imageView3.image = nil;
        }
    }

}
