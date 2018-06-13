//
//  StockDataViewController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 3/19/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit
import FirebaseDatabase

class StockDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
   
    var ref:DatabaseReference?
    var bike:FB_Bike!
    var keyArray = [String]()
    var valueArray = [String]()
    var stockData = [String]()
    
    var cellId = "cellId"
    
    var tableView:UITableView = UITableView()
    
    var titleBar:TitleBar = TitleBar()
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.bike = BikeData.sharedInstance.bike!
        
        guard let bike = bike else { return }
        super.viewWillAppear(animated)
        
        if (bike.year != nil && bike.year != "Unknown" && bike.year != "No Year Selected") {
            getData(mk:bike.make!, mdl:bike.model!, yr:bike.year!)
        } else {
            print("Now show something else")
            let noDataController = NoDataViewController()
            self.navigationController?.pushViewController(noDataController, animated: false)
            //let navController = UINavigationController(rootViewController: noDataController)
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo_2"))
        
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        titleBar.addTitleBarAndLabel(page: view, initialTitle: "STOCK DATA", ypos: 64)
        //let titleBar = addTitleBarAndLabel(page: view, title: "Projects", ypos: 64)
        tableView.anchor(top: view.topAnchor , left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        tableView.register(StockCell.self, forCellReuseIdentifier: cellId)
      
//        if (bike.year != nil && bike.year != "Unknown" && bike.year != "No Year Selected") {
//            getData(mk:bike.make!, mdl:bike.model!, yr:bike.year!)
//        } else {
//            print("Now show something else")
//            let noDataController = NoDataViewController()
//            //let navController = UINavigationController(rootViewController: noDataController)
//            self.present(noDataController, animated:true, completion:nil)
//        }
    }
    
//    func cancelThisView(_ sender: UIBarButtonItem) {
//        self.navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.keyArray.count) > 0 {
            return (self.keyArray.count)
        }else {
        return 0
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        configure(cell: cell, for: indexPath)
       
        return cell
    }
    
    func getData(mk:String, mdl:String, yr:String) {
        ref = Database.database().reference()
        
       
        
        ref?.child("bikes").child(mk).child(mdl).child(yr).queryOrderedByKey().observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            guard let dictionary = snapshot.value as? NSDictionary else {return}

//            let sortedKeys = (dictionary.allKeys as! [String]).sorted(by: <)
//            let sortedValues = (dictionary.allValues as! [String]).sorted(by: <)
            
            let tupleArray = dictionary.sorted { ($0.key as AnyObject).localizedCompare($1.key as! String) == .orderedAscending  }
            print(tupleArray)
            for i in 0..<tupleArray.count {
                
                if (tupleArray[i].value as! String != "") {
                    self.valueArray.append(tupleArray[i].value as! String)
                    let str:String = (tupleArray[i].key) as! String
                    let dropped = str.dropFirst(3)
                    self.keyArray.append(String(dropped))
                }
            }

            print(self.keyArray)
            print(self.valueArray)
            //let sortedKeys = (dictionary.allKeys as! [String])
            //let sortedValues = (dictionary.allValues as! [String])
////
           // self.keyArray = sortedKeys
            //self.valueArray = sortedValues
            
            
//
        
            self.tableView.reloadData()
        })
    }
        
        func configure(cell: UITableViewCell, for indexPath: IndexPath) {
            guard let cell = cell as? StockCell else {
                return
            }
        
            cell.itemLabel.text = "\(self.keyArray[indexPath.row]):"
            cell.dataLabel.text = "\(self.valueArray[indexPath.row])"
        }

}
