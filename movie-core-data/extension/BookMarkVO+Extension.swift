//
//  BookMarkMovieVO+Extension.swift
//  movie-core-data
//
//  Created by Aung Ko Ko on 9/25/19.
//  Copyright © 2019 padc. All rights reserved.
//

import Foundation
import CoreData
extension BookMarkVO {
    
    static func isBookMarkMovie(movieId : Int) -> Bool {
        let fetchRequest : NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.predicate = predicate
        do {
            let data = try CoreDataStack.shared.viewContext.fetch(fetchRequest)
            print("Find Movie Count",data)
            if data.isEmpty{
                return false
            }
            return true
        } catch {
            print("Failed to fetch BookMark Movie with id \(movieId): \(error.localizedDescription)")
            return false
        }
        
    }
    
    static func saveBookMarkEntity(movieId:Int,context:NSManagedObjectContext){
        let bookMarkMovie = BookMarkVO(context: context)
        bookMarkMovie.id = Int32(movieId)
        do{
            try context.save()
        }catch{
            print("Failed to Save BookMark Movie\(movieId) : \(error.localizedDescription)")
        }
    }
    
    static func deleteBookMarkEntity(movieId:Int,context:NSManagedObjectContext){
        let fetchRequest: NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let delepredicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.predicate = delepredicate
        do{
            let data = try context.fetch(fetchRequest)
            try? context.delete(data[0])
            try? context.save()
        }catch{
            print("Failed to Delete BookMark Movie \(movieId) : \(error.localizedDescription)")
        }
        
    }
    
}
