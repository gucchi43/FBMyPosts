//
//  PostsViewController.swift
//  photoMyMemory
//
//  Created by Hiroki Taniguchi on 2018/01/28.
//  Copyright © 2018年 Hiroki Taniguchi. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostsViewController: UIViewController {
    
    @IBOutlet weak var postsTabelView: UITableView!
    var postJson : JSON?

    override func viewDidLoad() {
        super.viewDidLoad()
        postsTabelView.delegate = self
        postsTabelView.dataSource = self
        
        postsTabelView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを作る
        let cell = tableView.dequeueReusableCell(withIdentifier: "postsTableViewCell") as! PostsTableViewCell
        if let postJson = postJson {
            let singlePostJson = postJson[indexPath.row]
            
            print("singlePostJson", singlePostJson)
//            print("singlePostJson", singlePostJson)
            if let created_time = singlePostJson["created_time"].string {
                cell.dateLabel.text = created_time
            }
            if let message = singlePostJson["message"].string {
                cell.contentLabel.text = message
            }
            
            if let full_picture = singlePostJson["full_picture"].url {
                if let data = try? Data(contentsOf: full_picture)
                {
                    cell.postImageView.image = UIImage(data: data)!
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数を設定
        var count = 10
        if let postJson = postJson {
            count = postJson.count
        }
        return count
    }
    
}
