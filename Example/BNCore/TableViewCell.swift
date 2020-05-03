//
//  TableViewCell.swift
//  BNCore_Example
//
//  Created by 陈登文 on 2020/4/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    lazy var _imageView: UIImageView = {
        
        let imageV = UIImageView.init()
        imageV.frame = CGRect.init(x: 12, y: 10, width: 140, height: 130)
//        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        imageV.backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        
        return imageV
    }()
    
    override func awakeFromNib() {
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(_imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
