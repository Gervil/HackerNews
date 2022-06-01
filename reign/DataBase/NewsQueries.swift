//
//  NewsQuerys.swift
//  reign
//
//  Created by Gerardo Villarroel on 31-05-22.
//

import UIKit
import CoreData

class NewsQueries {
    
    let container: NSPersistentContainer!
    
    init() {
        container = NSPersistentContainer(name: "HackerNews")
        setupDatabase()
    }
    
    //Connect data base
    func setupDatabase() {
        container.loadPersistentStores { (desc, error) in
            if let error = error {
                print("Error loading store \(desc) — \(error)")
                return
            }
        }
    }
    
    //Create
    func addData(storyId: Int64, storyTitle: String, author: String, createdAt: String, timeInterval: TimeInterval, storyUrl: String) {
        
        let newNews = News(context: container.viewContext)
        newNews.storyId = storyId
        newNews.storyTitle = storyTitle
        newNews.author = author
        newNews.createdAt = createdAt
        newNews.timeInterval = timeInterval
        newNews.storyUrl = storyUrl
            
        do {
            try container.viewContext.save()
            print("News ID\(storyId) saved")
            
        } catch {
            print("Error \(error)")
        }
    }
    
    //Read
    func fetchData() -> [News] {
        do {
            return try container.viewContext.fetch(News.fetchRequest())

        } catch {
            print("Error: \(error)")
        }
        return []
    }
    
    //Delete all data
    func deleteData(storyId: Int64) {
        do {
            let context = container.viewContext
            let fetchRequest : NSFetchRequest<News> = News.fetchRequest()
            if storyId != 0 {
                fetchRequest.predicate = NSPredicate(format: "storyId LIKE %@", String(storyId))
            }
            let deleteBatch = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

            try context.execute(deleteBatch)
            print("All data was deleted.")

        } catch {
            print("Error: \(error)")
        }
    }
}
