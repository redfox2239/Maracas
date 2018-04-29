//
//  YouTubeListViewController.swift
//  Marakasu
//
//  Created by 原田 礼朗 on 2018/04/29.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class YouTubeListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    
    let keyVal = "AIzaSyC7F0wdqQlrJWKqOi5wQ2wyw2r1nyVhbAg"
    let orderVal = "viewCount"
    let maxResultsVal = "50"
    let partVal = "snippet"
    let apiURL = "https://www.googleapis.com/youtube/v3/search"
    let imgURLPrefix = "https://i.ytimg.com/vi/"
    let imgURLSuffix = "/hqdefault.jpg"
    
    var query = ""
    
    var videoTitle = [String]()
    var videoIds = [String]()
    var imgCache = [String:Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func getYoutubeImgURL(_ videoId: String) -> String {
        return "\(imgURLPrefix)\(videoId)\(imgURLSuffix)"
    }
    
    func requestAPI() {
        if self.query == "" {
            return
        }
        if var urlCom = URLComponents(string: apiURL) {
            let query = [
                URLQueryItem(name: "key", value: keyVal),
                URLQueryItem(name: "order", value: orderVal),
                URLQueryItem(name: "maxResults", value: maxResultsVal),
                URLQueryItem(name: "part", value: partVal),
                URLQueryItem(name: "q", value: self.query),
            ]
            urlCom.queryItems = query
            if let url = urlCom.url {
                let request = URLRequest(url: url)
                LoadingManager.shared.showLoading()
                let task = URLSession.shared.dataTask(with: request) { (data, res, error) in
                    LoadingManager.shared.hideLoading()
                    if error == nil {
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                                    if let array = json["items"] as? [[String:Any]] {
                                        array.forEach({ (value) in
                                            if let videoId = (value["id"] as? [String:String])?["videoId"], let title = (value["snippet"] as? [String:Any])?["title"] as? String {
                                                self.videoIds.append(videoId)
                                                self.videoTitle.append(title)
                                                DispatchQueue.main.async {
                                                    self.listTableView.reloadData()
                                                }
                                            }
                                        })
                                        print(self.videoIds)
                                    }
                                }
                            }
                            catch {
                                print("error")
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoIds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! YoutubeListTableViewCell
        cell.currentIndexPath = indexPath
        cell.videoTitleLabel.text = videoTitle[indexPath.row]
        if let cache = self.imgCache[videoIds[indexPath.row]] {
            cell.videoImageView.image = UIImage(data: cache)
        }
        else {
            if let url = URL(string: getYoutubeImgURL(videoIds[indexPath.row])) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            if cell.currentIndexPath == indexPath {
                                cell.videoImageView.image = UIImage(data: data)
                                self.imgCache[self.videoIds[indexPath.row]] = data
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.size.height / 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoId = videoIds[indexPath.row]
        print(videoId)
        navigationController?.childViewControllers.forEach({ (vc) in
            if vc is ViewController {
                (vc as? ViewController)?.videoId = videoId
            }
        })
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if let text = textField.text {
            query = text
        }
        videoTitle = [String]()
        videoIds = [String]()
        requestAPI()
        return true
    }
    
}

class YoutubeListTableViewCell: UITableViewCell {
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    var currentIndexPath: IndexPath!
}
