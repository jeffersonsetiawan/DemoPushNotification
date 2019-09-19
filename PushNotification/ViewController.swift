//
//  ViewController.swift
//  PushNotification
//
//  Created by Jefferson Setiawan on 13/09/19.
//  Copyright © 2019 Jefferson Setiawan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        label.text = "HOME"
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 300, width: 100, height: 30)
        button.setTitle("Go to push", for: .normal)
        button.addTarget(self, action: #selector(goto), for: .touchUpInside)
        view.addSubview(label)
        view.addSubview(button)
    }
    
    @objc private func goto() {
        self.navigationController?.pushViewController(PushVC(), animated: true)
    }
}


class PushVC: UIViewController {
    init(title: String = "Default Push") {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        label.text = "Push"
        view.addSubview(label)
    }
}
