//
//  MLSearchController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/27.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

class MLSearchController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [String]()
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 40)
        self.navigationController?.navigationBar.addSubview(self.searchView)
        
        self.searchBar.delegate = self
        self.searchBar.returnKeyType = .search
        
        self.navigationItem.hidesBackButton = true
        
        self.loadData()
    }
    
    //MARK: - 数据请求
    func loadData(){
        let array = UserDefaults.standard.value(forKey: "SearchKeywords") as? [String];
        if array != nil {
            self.dataSource.append(contentsOf: array!)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLSearchCell")!
        cell.textLabel?.text = self.dataSource[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "SearchToSubject", sender: self.dataSource[(indexPath as NSIndexPath).row])
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil && textField.text!.length > 0 {
            self.dataSource.append(textField.text!)
            UserDefaults.standard.set(self.dataSource, forKey: "SearchKeywords")
            UserDefaults.standard.synchronize()
            
            self.performSegue(withIdentifier: "SearchToSubject", sender: textField.text!)
            return true
        }
        return false
    }
    
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        self.searchView.removeFromSuperview()
        
        if segue.identifier == "SearchToSubject" {
            let vc = segue.destination as! MLHomeSubjectController
            vc.tag_id = sender as! String
            vc.subjectType = .search
        } else if segue.destination.isKind(of: MLDiscoverController.classForCoder()) {
            // 点击取消了
            print("点击取消了")
        }
        
    }

}
