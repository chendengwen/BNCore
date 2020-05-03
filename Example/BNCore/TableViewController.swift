//
//  ViewController.swift
//  BNCore
//
//  Created by chendengwen on 12/04/2019.
//  Copyright (c) 2019 chendengwen. All rights reserved.
//

import UIKit
import BNCore

class TableViewController: UITableViewController {

    let cellID = "cellID"
    var dataSource = [Dictionary<String,Any>]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.rowHeight = 150
        
        let cacheFileName = "filmArr"
        BNFileCache.shared.getObject(fileName: cacheFileName, type: .Json, dataType: Array<Dictionary<String,Any>>.self) { (arrayFile) in
            guard let array = arrayFile else {
                return
            }
            DispatchQueue.main.sync {
                self.dataSource = array
                self.tableView.reloadData()
            }
        }
        
        
//        let url = "https://douban.uieee.com/v2/movie/in_theaters"
//        BNRequestManager.shared.request(url: url) { (result, error) in
//            if let dic:Dictionary<String,Any> = result as? Dictionary<String, Any> {
//                let tmpArr = dic["subjects"] as! Array<Dictionary<String,Any>>
//                let temDic = tmpArr.first
//                let dataArr = temDic?["casts"] as? Array<Dictionary<String,Any>>
//
//                guard let _ = dataArr else {
//                    return
//                }
//                BNFileCache.shared.storeObject(object: dataArr!, fileName: cacheFileName, type: .Json) { (result) in
//                    if result {
//                        print("保存成功")
//                    }
//                }
//
//                self.dataSource = dataArr ?? []
//                DispatchQueue.main.sync {
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //:Mark -- DataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell:TableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? TableViewCell
        if cell == nil {
            cell = TableViewCell.init(style: .default, reuseIdentifier: cellID)
        }
        
        let dic = dataSource[indexPath.row]
        let picturesDic = dic["avatars"] as! Dictionary<String,Any>
        cell!._imageView.setImageNoCache(for: picturesDic["small"] as! String, placeHolder: .default_small)
        
        return cell!
    }
    
}


