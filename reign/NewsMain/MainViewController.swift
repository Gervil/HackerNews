//
//  MainViewController.swift
//  reign
//
//  Created by Gerardo Villarroel on 01-06-22.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: Controls
    @IBOutlet var mTableView: UITableView!
    
    //MARK: Variables
    var mNewsDatas = [NewsData]()
    var mRefreshControl: UIRefreshControl!
    var mNewsSelected = 0
    
    //MARK: Constants
    let mDataBaseManager = NewsQueries()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRefreshControl()
        getApiData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: Refresh
    func addRefreshControl() {
        mRefreshControl = UIRefreshControl()
        mRefreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.mTableView.addSubview(mRefreshControl)
    }
    
    @objc func refreshList() {
        if !Util.checkInternetAccess() {
            present(Messages.errorConnection(), animated: true, completion: nil)
            endRefreshing()
            return
        }
        mNewsDatas.removeAll()
        mTableView.reloadData()
        mNewsSelected = 0
        getApiData()
    }
    
    func endRefreshing() {
        if self.mRefreshControl != nil {
            self.mRefreshControl.endRefreshing()
        }
    }

    //----------------------------------------------------------------------------------------------
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNewsDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NewsCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MainTableViewCell  else {
            fatalError("The dequeued cell is not an instance of TableViewCell.")
        }
        let data = mNewsDatas[indexPath.row]
        cell.mNewsTitle.text = data.storyTitle
        cell.mAuthorAndTime.text = "\(data.author) - \(data.createdAt)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Util.checkInternetAccess() {
            self.present(Messages.errorConnection(), animated: true, completion: nil)
            return
        }
        if mNewsDatas[indexPath.row].storyUrl.isEmpty {
            self.present(Messages.errorUrl(), animated: true, completion: nil)
            return
        }
        mNewsSelected = indexPath.row
        self.performSegue(withIdentifier: "NewsDetail", sender: self)
    }
    
    //Delete items options
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //Handle delete (by removing the data from your array and updating the tableview)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            Util.setNewsDeleted(storyId: mNewsDatas[indexPath.row].storyId)
            mDataBaseManager.deleteData(storyId: mNewsDatas[indexPath.row].storyId)
            mNewsDatas.remove(at: indexPath.row)
            mTableView.reloadData()
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //MARK: Get Api data
    func getApiData() {
        
        //Check internet connection
        if !Util.checkInternetAccess() {
            offlineMode()
            endRefreshing()
            return
        }
        
        //Url request
        let request = Util.cloudConnect(api_url: ApiConnection.NEWS, parms: "")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            OperationQueue.main.addOperation {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? NSDictionary
                    self.getData(jsonResponse!.value(forKey: "hits") as! NSArray)
                    self.dispatch()
                    
                } catch _ {
                    self.offlineMode()
                    self.endRefreshing()
                    return
                }
            }
        }
        task.resume()
    }

    //MARK: Data extractor
    func getData(_ data: NSArray) {
        mDataBaseManager.deleteData(storyId: 0)
        var storyId: Int64
        var title = "", storyTitle = "", author = "", createdAt = "", storyUrl1 = "", storyUrl2 = ""
        
        for item in data {
            let data = item as! NSDictionary
            storyId = Int64(data.value(forKey: "story_id") as? Int64 ?? 0)
            title = data.value(forKey: "title") as? String ?? ""
            storyTitle = data.value(forKey: "story_title") as? String ?? ""
            author = data.value(forKey: "author") as? String ?? ""
            createdAt = data.value(forKey: "created_at") as? String ?? ""
            storyUrl1 = data.value(forKey: "url") as? String ?? ""
            storyUrl2 = data.value(forKey: "story_url") as? String ?? ""
            
            let newsDate = Util.isoDateToDate(isoDate: createdAt)
            let timeInterval = Util.dateToTimeInterval(newsDate: newsDate)
            
            let storyIdsDeleted = Util.getNewsDeleted()
            var addItem = true
            for item in storyIdsDeleted {
                if item == storyId {
                    addItem = false
                    break
                }
            }
            
            if addItem {
                let titleNews = title.isEmpty ? storyTitle : title
                if !titleNews.isEmpty && storyId != 0 {
                    //Online News
                    let news = NewsData(storyId: storyId
                                        , storyTitle: titleNews
                                        , author: author
                                        , createdAt: timeInterval
                                        , timeInterval: newsDate.timeIntervalSinceReferenceDate
                                        , storyUrl: storyUrl1.isEmpty ? storyUrl2 : storyUrl1)!
                    mNewsDatas.append(news)
                    
                    //Offline News
                    mDataBaseManager.addData(storyId: storyId
                                             , storyTitle: title.isEmpty ? storyTitle : title
                                             , author: author
                                             , createdAt: timeInterval
                                             , timeInterval: newsDate.timeIntervalSinceReferenceDate
                                             , storyUrl: storyUrl1.isEmpty ? storyUrl2 : storyUrl1)
                }
            }
        }
    }
    
    //Show news
    func dispatch() {
        DispatchQueue.main.async {
            if self.mTableView != nil {
                self.mNewsDatas.sort() {
                    $0.timeInterval > $1.timeInterval
                }
                self.endRefreshing()
                self.mTableView.reloadData()
            }
        }
    }
    
    //----------------------------------------------------------------------------------------------
    //MARK: Offline Data
    func offlineMode() {
        let data = mDataBaseManager.fetchData()
        if data.isEmpty {
            self.present(Messages.errorConnection(), animated: true, completion: nil)
            self.endRefreshing()
            return
        }
        for item in data {
            let news = NewsData(storyId: item.storyId
                                , storyTitle: item.storyTitle!
                                , author: item.author!
                                , createdAt: item.createdAt!
                                , timeInterval: item.timeInterval
                                , storyUrl: item.storyUrl!)!
            mNewsDatas.append(news)
        }
        dispatch()
    }
    
    //Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier == "NewsDetail" {
            if let destination = segue.destination as? DetailViewController {
                destination.mUrl = mNewsDatas[mNewsSelected].storyUrl
            }
        }
    }
}
