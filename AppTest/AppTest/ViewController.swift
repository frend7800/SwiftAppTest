//
//  ViewController.swift
//  AppTest
//
//  Created by 魏新杰 on 2021/2/23.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView: UITableView?
    var array = Array<Any>()
    var timer:Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "首页"
        NotificationCenter.default.addObserver(self, selector: #selector(startRequestData), name: NSNotification.Name(rawValue: "startRequest"), object: nil)
        
        let defaults = UserDefaults.standard
        let lastDict:[String:String] = defaults.object(forKey: "lastRequest") as! [String:String]
        self.array.append(lastDict)
        
        self.setupNavigationItem()
        self.setupSubviews()

    }
    
    func setupSubviews() -> Void {
        
        self.tableView = UITableView(frame: self.view.bounds, style: .grouped)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.view.addSubview(self.tableView!)
        
    }
    
    func setupNavigationItem() -> Void {
        
        let rightItem = UIBarButtonItem(title: "历史记录", style: .plain, target: self, action:#selector(rightBarItemClick) )
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc func rightBarItemClick() -> Void {
        
        let historyVc = HistoryViewController()
        self.navigationController?.pushViewController(historyVc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let dictionary : [String:String] = self.array[section] as! [String:String]
        
        return dictionary.keys.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let dictionary : [String:String] = self.array[indexPath.section] as! [String:String]
        let allKeys  = dictionary.keys
        let keyArray = Array(allKeys)
        let keyTitle = keyArray[indexPath.row]
        
        cell?.textLabel?.text = keyTitle
        cell?.detailTextLabel?.text = dictionary[keyTitle]
        return cell!
    }
    
    @objc func startRequestData() -> Void{
        
        self.appRequest(refresh: true)
        timer = Timer.scheduledTimer(timeInterval:TimeInterval(5.0), target: self, selector: #selector(appRequest), userInfo: nil, repeats: true)
    }
    
    @objc  func appRequest(refresh : Bool) -> Void {
        
        let url = "https://api.github.com/"
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            
            guard error == nil else {
                print("ERROR: HTTP request error!")
                return
            }
            let responseString = NSString(data: data!,encoding: String.Encoding.utf8.rawValue)! as String

            let dictionary = self.getDictionaryFromJSONString(jsonString: responseString)
            
            let defaults = UserDefaults.standard
            
            self.array.removeAll()
            self.array.append(dictionary)
            
            if refresh {
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }
            
            let queue = DispatchQueue(label: "default.name")
            queue.async {
                let  dat:Date = Date.init(timeIntervalSinceNow: 0)
                
                let  timestamp:TimeInterval = dat.timeIntervalSince1970;
                
                //此处的数据可持久化，都采用的是userDefaults,比较简单一点，如果是项目的数据比较复杂，数据量较大的情况，还是使用数据库更好
                
                let historyDict:[String:Any] = ["requestData":dictionary,"requestTime":String(UInt64(timestamp))]
                
                var historyArray = defaults.array(forKey: "historyRequest")
                
                if historyArray == nil{
                    
                    historyArray = [Any]()
                }
                
                historyArray?.insert(historyDict, at: 0)
                defaults.set(dictionary, forKey: "lastRequest")
                defaults.set(historyArray, forKey: "historyRequest")
            }
        
            
        }
        task.resume()
    }
    
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
     
        let jsonData:Data = jsonString.data(using: .utf8)!
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    
    }

    deinit {
        
        NotificationCenter.default.removeObserver(self)
        guard let timer1 = self.timer
        else{ return }
        timer1.invalidate()
    }
    
}

