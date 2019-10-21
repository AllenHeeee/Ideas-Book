//
//  SavedPhotos.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/13.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import Foundation
import RealmSwift
class SavedPhotos: Object{
    @objc dynamic var text:String?
    @objc dynamic var image1:Data?
    @objc dynamic var image2:Data?
    @objc dynamic var image3:Data?
}
