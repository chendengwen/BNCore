//
//  ViewController.swift
//  Example02
//
//  Created by gary on 2020/4/29.
//  Copyright © 2020 gary. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonClicked(_ sender: Any) {
        /** Get
            https://douban.uieee.com/v2/movie/in_theaters
            http://127.0.0.1/api/comments.json
         */
        let url1 = "http://127.0.0.1/api/comments.json"
//        BNRequestManager.shared.request(url: "http://127.0.0.1/api/comments.json") { (result, error) in
//            if error != nil {
//                print(error!)
//            } else {
//                print(result!)
//            }
//        }
        
        // Download
        let url2 = "http://static.tvmaze.com/uploads/images/medium_portrait/1/3603.jpg"
//        BNRequestManager.shared.request(type: .Download, url: url, data: nil, progress: { (total, now) in
//            print("total = \(total) - now = \(now)")
//        }) { (dict, error) in
//            if error != nil {
//                print(error!)
//            } else {
//                let image = BNImageCache.shared.getImageCache(for: url)
//                DispatchQueue.main.async {
//                    self.imageView.image = image
//                }
//            }
//        }
        
        // Cache
//        let image = BNImageCache.shared.getImageCache(for: url)
//        imageView.image = image
        
        // UIImageExtension
        imageView.setImage(for: url2, placeHolder: .default_small)
        
        // FileCache -- 下载-保存-读取
//        BNRequestManager.shared.request(url: url1) { (result, error) in
//            let dic = result as! Dictionary<String,Any>
//            if error != nil {
//                print(error!)
//            } else {
//                print(dic["code"] ?? "去你的")
//
//                let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
//                BNCache.shared.storeCache(data: data, for: url1, inMemary: false, toDisk: true)
//
//                DispatchQueue.default.after(5) {
//                    let cacheData = BNCache.shared.getCache(for: url1)
//                    guard let _ = cacheData else {
//                        return
//                    }
//                    let jsonDic = try! JSONSerialization.jsonObject(with: cacheData!, options: [])
//                    print(jsonDic)
//                }
//            }
//        }
        
        // FileCache -- 读取
//        let cacheData = BNCache.shared.getCache(for: url1)
//        guard let _ = cacheData else {
//            return
//        }
//        let jsonDic = try! JSONSerialization.jsonObject(with: cacheData!, options: [])
//        print(jsonDic)
        
    }
    
}

