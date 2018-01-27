//
//  ViewController.swift
//  photoMyMemory
//
//  Created by Hiroki Taniguchi on 2018/01/27.
//  Copyright © 2018年 Hiroki Taniguchi. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var fbLoginButon: UIButton!
    @IBOutlet weak var fbUserName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fbLogin(_ sender: Any) {
        let loginManeger = LoginManager()
        
        loginManeger.logIn(readPermissions: [.email, .publicProfile, .userFriends, .userPosts], viewController: self) { (result) in
            switch result {
            case let .success( permission, declinePemisson, token):
                print("token:\(token),\(permission),\(declinePemisson)")
                self.getUserInfo()
            case let .failed(error):
                print("error:\(error)")
            case .cancelled:
                print("cancelled")
            }
        }
    }
    
    func isLoggedInWithFacebook() -> Bool {
        let loggedIn = AccessToken.current != nil
        return loggedIn
    }
    
    func getUserInfo (){
        let parms = ["fields": "name, email, picture.width(480).height(480)"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: parms, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.GET, apiVersion: GraphAPIVersion.defaultVersion)
        graphRequest.start { (response, result) in
            switch result {
            case .failed(let error):
                // Handle the result's error
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    let json = JSON(responseDictionary)
                    print("json", json)
                    let userName = json["name"].string
                    print("userName", userName)
                    self.fbUserName.text = userName
                    let userProfileUrl = json["picture"]["data"]["url"].url
                    print("userProfileUrl", userProfileUrl)
                    if let data = try? Data(contentsOf: userProfileUrl!)
                    {
                        self.profileImageView.image = UIImage(data: data)!
                    }
                }
                break
            }
        }
    }
    
    
    @IBAction func getPosts(_ sender: Any) {
        self.getUserMemory()
    }
    
    func getUserMemory() {
        let parms = ["fields" : "message,full_picture,created_time,id,with_tags,place", "limit" : "3000"]
        let graphRequest = GraphRequest(graphPath: "me/posts", parameters: parms, accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod.GET, apiVersion: GraphAPIVersion.defaultVersion)
        graphRequest.start { (response, result) in
            switch result {
            case .failed(let error):
                // Handle the result's error
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    let postsJson = JSON(responseDictionary)["data"]
                    print("postsJson", postsJson)
                    let count = postsJson.count
                    print("count", count)
                    self.performSegue(withIdentifier: "toPostsView", sender: postsJson)
                }
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostsView" {
            let postsViewController = segue.destination as! PostsViewController
            postsViewController.postJson = sender as! JSON
        }
    }
}

