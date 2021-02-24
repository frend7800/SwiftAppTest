//
//  HistoryViewController.swift
//  AppTest
//
//  Created by 魏新杰 on 2021/2/24.
//

import UIKit

class HistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var tableView: UITableView?
    var array = Array<Any>()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "历史记录"
        let defaults = UserDefaults.standard
        let historyArray = defaults.array(forKey: "historyRequest")
        self.array = historyArray!
            
        self.setupSubviews()
        // Do any additional setup after loading the view.
    }
    func setupSubviews() -> Void {
        
        self.tableView = UITableView(frame: self.view.bounds, style: .grouped)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(self.tableView!)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let dictionary : [String:Any] = self.array[section] as! [String:Any]
        let listDict : [String:String] = dictionary["requestData"] as! [String:String]
        
        return listDict.keys.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 54.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let sectionView = UIView()
        sectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
        
        let label = UILabel(frame: CGRect(x: 16.0, y: (50.0-30.0)/2.0, width: 300.0, height: 30.0))
        label.backgroundColor = UIColor.clear
        label.textAlignment  = .left
        label.textColor = .darkGray
        sectionView.addSubview(label)
        
        let dictionary : [String:Any] = self.array[section] as! [String:Any]
        let timeStr : String = dictionary["requestTime"] as! String
        
        label.text = "请求时间：" + self.timeStampToString(timeStamp: Double(timeStr) ?? 0, outputFormatter: "yyyy-MM-dd HH:mm:ss")
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let dictionary : [String:Any] = self.array[indexPath.section] as! [String:Any]
        let listDict : [String:String] = dictionary["requestData"] as! [String:String]
        let allKeys  = listDict.keys
        let keyArray = Array(allKeys)
        let keyTitle = keyArray[indexPath.row]
        
        cell?.textLabel?.text = keyTitle
        cell?.detailTextLabel?.text = listDict[keyTitle]
        
        return cell!
    }

    
    //MARK: -时间戳转时间函数
    func timeStampToString(timeStamp: Double, outputFormatter: String)->String {
        let timeSta:TimeInterval
        timeSta = TimeInterval(timeStamp)
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dfmatter = DateFormatter()
        //设定时间格式,这里可以设置成自己需要的格式yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat = outputFormatter
        return dfmatter.string(from: date as Date)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
