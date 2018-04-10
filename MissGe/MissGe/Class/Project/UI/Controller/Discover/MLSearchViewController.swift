//
//  MLSearchViewController.swift
//  MissGe
//
//  Created by 程祥贺 on 2018/4/2.
//  Copyright © 2018年 cn. All rights reserved.
//

import UIKit

class MLSearchViewController: BaseViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    var dataSource = [String]()
    var searchBar: UISearchBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        searchBar = UISearchBar.init(frame: CGRect.init(x: 10, y: 10, width: kScreenWidth - 20, height: 30))
        searchBar.tintColor = UIColor.white
        searchBar.placeholder = "搜索"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar;
  
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        }
        
        let table = UITableView.init(frame: self.view.bounds, style: .plain)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "MLSearchTextCell")
        table.tableFooterView = UIView.init()
        table.delegate = self
        table.dataSource = self
        self.view.addSubview(table)
        
        var arr: [String]! = UserDefaults.standard.value(forKey: "MLSearchTextArr") as? [String]
        if arr == nil {
            arr = [String]()
        }
        dataSource = arr
        
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    func searchToResult(searchText: String) {
        let vc = kLoadVCFromSB(nil, stroyBoard: "Subject") as! MLHomeSubjectController
        vc.tag_id = searchText
        vc.subjectType = .search
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil {
            return
        }
        var arr: [String]! = UserDefaults.standard.value(forKey: "MLSearchTextArr") as? [String]
        if arr == nil {
            arr = [String]()
        }
        if arr.count > 9 {
            arr = Array(arr[0..<9])
        }
        arr.insert(searchBar.text!, at: 0)
        UserDefaults.standard.setValue(arr, forKey: "MLSearchTextArr")
        searchToResult(searchText: searchBar.text!)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLSearchTextCell") as! UITableViewCell
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchToResult(searchText: dataSource[indexPath.row])
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
