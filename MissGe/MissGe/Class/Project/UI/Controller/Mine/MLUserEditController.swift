//
//  MLUserEditController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/27.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLUserEditCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

}

class MLUserEditController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    fileprivate var dataSource = ["登录名", "昵称", "性别", "所在地", "生日"]
    fileprivate var valueSource = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        let user: MLUserModel! = MLNetConfig.shareInstance.user
        self.valueSource.append(user.username!)
        self.valueSource.append(user.nickname!)

        if user.gender == 1 {
            self.valueSource.append("男")
        } else if user.gender == 2 {
            self.valueSource.append("女")
        } else {
            self.valueSource.append("保密")
        }
        self.valueSource.append(user.location!)
        self.valueSource.append(user.birthday!)

        self.valueSource.append(user.autograph!)

        // Do any additional setup after loading the view.
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section

        let cell = tableView.dequeueReusableCell(withIdentifier: "MLUserEditCell") as! MLUserEditCell
        if section == 0 {
            cell.nameLabel.text = self.dataSource[(indexPath as NSIndexPath).row]
            cell.valueLabel.text = self.valueSource[(indexPath as NSIndexPath).row]
        } else {
            cell.nameLabel.text = "简介"
            cell.valueLabel.text = self.valueSource.last
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 44
        }
        return max(44, ceil(self.valueSource.last!.height(UIFont.systemFont(ofSize: 16), maxWidth: kScreenWidth - 100)))
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataSource.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
