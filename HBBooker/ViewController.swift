//
//  ViewController.swift
//  HBBooker
//
//  Created by jianghongbao on 2018/3/6.
//  Copyright © 2018年 HonBoom. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var operatorTableView : UITableView = UITableView()
    fileprivate var titles : [String] = ["翻页消失","翻页可回","全新翻页可回"]
    fileprivate var controllers : [UIViewController] = [UIViewController]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        var naviHeight : CGFloat = 0
        if let _naviHeight = self.navigationController?.navigationBar.bounds.height {
            naviHeight = _naviHeight
        }
        
        controllers = [HBCurveDisappearController(),HBCurveBackController()]
        
        operatorTableView.frame = CGRect.init(x: 0, y: naviHeight, width: view.bounds.width, height: view.bounds.height - naviHeight)
        operatorTableView.delegate = self
        operatorTableView.dataSource = self
        operatorTableView.backgroundColor = RGB(0xf7f7f8)
        view.addSubview(operatorTableView)
        
        var cat = "Benz"
        let cloure = { [cat] in
            print("drive = \(cat)")
        }
        cat = "Tesla"
        cloure()
        
        let s = "afbgtd"
        let ss = s.sorted()
        for i in 0 ..< s.count {
            print(":\(String.init(ss[i]))")
        }
        //let a = s.components(separatedBy: "")
        //print("\(a)")
        
        var testArray = [1,8,5,2,9,556,4,2]
        testArray = testArray.sorted(by: { (fisrt, second) -> Bool in
            if fisrt <= second {
                return true
            }else {
                return false
            }
        })
        
        print("testArray ;;;;;; \(testArray)")
        /// out of range
        //testArray.remove(at: 8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = titles[indexPath.row]
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let controller = controllers[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }else if indexPath.row == 1 {
            let c = HBCurveBackController()
            self.navigationController?.pushViewController(c, animated: true)
        }else if indexPath.row == 2 {
            let c = HBNewCurveBackController()
            self.navigationController?.pushViewController(c, animated: true)
        }
    }
    
}
