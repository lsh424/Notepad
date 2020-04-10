//
//  MemoListViewController.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

import UIKit

class MemoListViewController: UITableViewController {
    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dao = MemoDAO()
    lazy var memoList = [MemoData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        memoList = self.dao.fetch()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source & delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = memoList.count
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = memoList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell") as! MemoCell
        
        cell.title.text = data.title
        cell.contents.text = data.contents
        cell.imgView.image = data.thumbnail
        
        if cell.title.text == ""{
            cell.title.text = "무제"
        }
        
        if data.thumbnail == nil {
            cell.trailConstOfTitle.constant = 10
        } else {
            cell.trailConstOfTitle.constant = 80
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy. M. d (E)"
        cell.creationDate.text = formatter.string(from: data.date!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = memoList[indexPath.row]
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MemoVC") as? MemoViewController else {
            return
        }
        
        vc.readData = data
        vc.memoMode = .read
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let data = memoList[indexPath.row]
        
        if dao.delete(data.objectID!) {
            memoList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
