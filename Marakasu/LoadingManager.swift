//
//  LoadingManager.swift
//  Marakasu
//
//  Created by 原田 礼朗 on 2018/04/29.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

class LoadingManager {
    static let shared = LoadingManager()
    
    var win: UIWindow?
    
    func showLoading() {
        win = UIWindow(frame: UIScreen.main.bounds)
        win?.backgroundColor = UIColor.clear
        let vc = UIViewController(nibName: nil, bundle: nil)
        vc.view.backgroundColor = UIColor.clear
        let grayView = UIView(frame: UIScreen.main.bounds)
        grayView.backgroundColor = UIColor.gray
        grayView.alpha = 0.3
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.red
        activityIndicator.startAnimating()
        activityIndicator.frame.origin = CGPoint(x: vc.view.frame.size.width/2, y: vc.view.frame.size.height/2)
        vc.view.addSubview(grayView)
        vc.view.addSubview(activityIndicator)
        win?.rootViewController = vc
        win?.makeKeyAndVisible()
    }
    
    func hideLoading() {
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
        win = nil
    }
}
