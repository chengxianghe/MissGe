//
//  MLMineViewController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/19.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLMineViewController: UITableViewController {

    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bestAnswerNumLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userEditButton: UIButton!
    @IBOutlet weak var loginButtonXConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView?.setHeight(kScreenWidth/320*120)

        iconImageView.layer.cornerRadius = (kScreenWidth/320*120 - 24 * 2 - 18) / 2.0

        if MLNetConfig.isUserLogin() {
            self.loginSuccessed()
        } else {
            self.logoutSuccessed()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.loginSuccessed), name: NSNotification.Name(rawValue: kUserLoginSuccessed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logoutSuccessed), name: NSNotification.Name(rawValue: kUserLogoutSuccessed), object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        if kisIPad() {
            loginButtonXConstraint.constant = -50
        }
    }

    @objc func loginSuccessed() {
        self.tableView.tableFooterView?.setHeight(50 + 20)

        self.userEditButton.isHidden = false
        self.loginButton.isHidden = true
        self.logoutBtn.isHidden = false
        self.nameLabel.isHidden = false
        self.bestAnswerNumLabel.isHidden = false
        self.nameLabel.text = MLNetConfig.shareInstance.user.nickname
        self.nameLabel.text = "最佳答案\(MLNetConfig.shareInstance.user.p_bests)个"
        self.iconImageView.yy_setImage(with: MLNetConfig.shareInstance.user.avatar, placeholder: UIImage(named: "portrait_bg_77x77_"))

    }

    @objc func logoutSuccessed() {
        self.tableView.tableFooterView?.setHeight(0)

        self.userEditButton.isHidden = true
        self.loginButton.isHidden = false
        self.logoutBtn.isHidden = true
        self.nameLabel.isHidden = true
        self.bestAnswerNumLabel.isHidden = true
        self.iconImageView.image = UIImage(named: "portrait_bg_77x77_")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogoutBtnClick(_ sender: UIButton) {
        MLNetConfig.updateUser(nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kUserLogoutSuccessed), object: nil)
    }

    @IBAction func onIconBtnClick(_ sender: UIButton) {

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        }
        return 10
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return CGFloat.leastNormalMagnitude
        }
        return 5
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath)

        let sec = indexPath.section
        let row = indexPath.row

        switch sec {
        case 1:
            if !MLNetConfig.isUserLogin() {
                let goLogin = UIAlertAction.init(title: "去登录", style: UIAlertActionStyle.default, handler: {[weak self] (action) in
                    let loginVCNav = kLoadVCFromSB(nil, stroyBoard: "Account")!
                    self?.present(loginVCNav, animated: true, completion: nil)
                })

                let cancel = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
                self.showAlert("您还未登录", message: nil, actions: [cancel, goLogin])

                return
            }
            if row == 0 { // 收藏
                self.performSegue(withIdentifier: "MineToFavorite", sender: nil)
            } else if row == 1 { // 评论
                self.performSegue(withIdentifier: "MineToComment", sender: nil)
            }

        case 3:
            if row == 0 { // 设置
                print("设置")
            } else if row == 1 { // 评分
                _ = kJumpToAppStoreComment(appid: kAppId)
//                kJumpToAppSetting()
            }
        default:
            break
        }

    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "MineToUserEdit" {
            let vc = segue.destination as! MLUserController
            vc.uid = MLNetConfig.shareInstance.userId
        }
    }

}
