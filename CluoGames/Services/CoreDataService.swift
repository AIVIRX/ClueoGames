//
//  CoreDataService.swift
//  CluoGames
//
//  Created by Maicol Cabreja on 9/27/25.
//

import Foundation
import CoreData

// MARK: - Core Data Service
class CoreDataService {
    static let shared = CoreDataService()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CluoGames")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, you might want to handle this error more gracefully
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Save Context
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Puzzle Results
    func savePuzzleResult(_ result: GameResult) {
        let context = persistentContainer.viewContext
        let puzzleResult = PuzzleResult(context: context)
        
        puzzleResult.puzzleId = result.puzzleId
        puzzleResult.puzzleType = result.puzzleType.rawValue
        puzzleResult.date = result.date
        puzzleResult.timeToSolve = result.timeToSolve
        puzzleResult.mistakes = Int16(result.mistakes)
        puzzleResult.isPerfect = result.isPerfect
        puzzleResult.streak = Int16(result.streak)
        
        save()
    }
    
    func fetchPuzzleResults() -> [GameResult] {
        let request: NSFetchRequest<PuzzleResult> = PuzzleResult.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PuzzleResult.date, ascending: false)]
        
        do {
            let results = try context.fetch(request)
            return results.map { coreDataResult in
                GameResult(
                    puzzleId: coreDataResult.puzzleId ?? "",
                    puzzleType: GameResult.PuzzleType(rawValue: coreDataResult.puzzleType ?? "connections") ?? .connections,
                    date: coreDataResult.date ?? Date(),
                    timeToSolve: coreDataResult.timeToSolve,
                    mistakes: Int(coreDataResult.mistakes),
                    isPerfect: coreDataResult.isPerfect,
                    streak: Int(coreDataResult.streak)
                )
            }
        } catch {
            print("Core Data fetch error: \(error)")
            return []
        }
    }
    
    // MARK: - User Progress
    func saveUserProgress(_ progress: UserGameProgress) {
        let context = persistentContainer.viewContext
        
        // Clear existing progress (assuming single user)
        let request: NSFetchRequest<NSFetchRequestResult> = UserProgress.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Core Data delete error: \(error)")
        }
        
        // Save new progress
        let userProgress = UserProgress(context: context)
        userProgress.currentStreak = Int16(progress.currentStreak)
        userProgress.longestStreak = Int16(progress.longestStreak)
        userProgress.totalPuzzlesSolved = Int16(progress.totalPuzzlesSolved)
        userProgress.lastPlayDate = progress.lastPlayDate
        
        save()
    }
    
    func fetchUserProgress() -> UserGameProgress? {
        let request: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            guard let coreDataProgress = results.first else { return nil }
            
            return UserGameProgress(
                currentStreak: Int(coreDataProgress.currentStreak),
                longestStreak: Int(coreDataProgress.longestStreak),
                totalPuzzlesSolved: Int(coreDataProgress.totalPuzzlesSolved),
                solvedPuzzleIds: [], // This would need separate storage
                lastPlayDate: coreDataProgress.lastPlayDate,
            )
        } catch {
            print("Core Data fetch error: \(error)")
            return nil
        }
    }
    
    // MARK: - Statistics
    func getTotalPuzzlesSolved() -> Int {
        let request: NSFetchRequest<PuzzleResult> = PuzzleResult.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.count
        } catch {
            print("Core Data fetch error: \(error)")
            return 0
        }
    }
    
    func getAverageSolveTime() -> TimeInterval {
        let request: NSFetchRequest<PuzzleResult> = PuzzleResult.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            let totalTime = results.reduce(0) { $0 + $1.timeToSolve }
            return results.isEmpty ? 0 : totalTime / Double(results.count)
        } catch {
            print("Core Data fetch error: \(error)")
            return 0
        }
    }
    
    func getPerfectSolves() -> Int {
        let request: NSFetchRequest<PuzzleResult> = PuzzleResult.fetchRequest()
        request.predicate = NSPredicate(format: "isPerfect == YES")
        
        do {
            let results = try context.fetch(request)
            return results.count
        } catch {
            print("Core Data fetch error: \(error)")
            return 0
        }
    }
}
