//
//  SQLiteDatabase.swift
//  Ashish
//
//  Created by indianic on 23/11/18.
//  Copyright © 2018 Ashish. All rights reserved.
//

import UIKit
import SQLite3


//let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"


struct Table {
    static let category = "Category"
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

// MARK: The Database Connection

class SQLiteDatabase: NSObject {
    fileprivate let dbPointer: OpaquePointer?
    
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

// MARK: Preparing Statements

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

// MARK: Create Table

protocol SQLTable {
    static var createStatement: String { get }
}

extension Category: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE \(Table.category)(
        Id INT PRIMARY KEY NOT NULL,
        Name CHAR(255),
        Image CHAR(255)
        );
        """
    }
}

extension SQLiteDatabase {
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        defer {
            sqlite3_finalize(createTableStatement)
        }
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("\(table) table created.")
    }
}


// MARK: Write

extension SQLiteDatabase {
    
    func insertAllRecords(table:String, qString:String) throws {
   
        let insertStatement = try prepareStatement(sql: qString)
        defer {
            sqlite3_finalize(insertStatement)
        }
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func deleteAllRecords(qString:String) throws {
        
        let deleteStatement = try prepareStatement(sql: qString)
        defer {
            sqlite3_finalize(deleteStatement)
        }
        guard sqlite3_step(deleteStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}


// MARK: Read

extension SQLiteDatabase {
    func getAllCategory() -> [Category] {
       
        var arrCatList:[Category] = []
        
        let querySql = "SELECT * FROM \(Table.category);"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return arrCatList
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            
//            let id = String(cString:sqlite3_column_int(queryStatement, 0)) as Int
            let id = sqlite3_column_int(queryStatement, 0)
            let name = String(cString:sqlite3_column_text(queryStatement, 1)) as String
            let image = String(cString:sqlite3_column_text(queryStatement, 2)) as String
            
            let dictCat:[String:Any] = ["id":id,
                                        "name":name,
                                        "image":image,
                                        ]
            
            arrCatList.append(Category.init(object: dictCat))
        }
        return arrCatList
    }

    func getProductDetails(_ itemCode:String) -> Product? {
        
        var productObj:Product? = nil
        
        let querySql = "SELECT * FROM \(Table.product) WHERE Id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
    
        let code = itemCode as NSString
        guard sqlite3_bind_text(queryStatement, 1, code.utf8String, -1, nil) == SQLITE_OK else  {
            return nil
        }

        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        if sqlite3_step(queryStatement) == SQLITE_ROW {
            
            let id = sqlite3_column_int(queryStatement, 0)
            let name = String(cString:sqlite3_column_text(queryStatement, 1)) as String
            let code = String(cString:sqlite3_column_text(queryStatement, 2)) as String
            let pImage = String(cString:sqlite3_column_text(queryStatement, 3)) as String
            let strImage = String(cString:sqlite3_column_text(queryStatement, 4)) as String
            let description = String(cString:sqlite3_column_text(queryStatement, 5)) as String
            
            let arrImg = strImage.components(separatedBy:",")
            
            let dictProduct:[String:Any] = ["id":id,
                                            "name":name,
                                            "primary_image":pImage,
                                            "image":arrImg,
                                            "item_code":code,
                                            "description": description]
            productObj = Product.init(object: dictProduct)
        }
        return productObj
    }
    
}

extension SQLiteDatabase {
    // MARK: Destroy Database
    
    func destroyDatabase(db: String) {
        do {
            if FileManager.default.fileExists(atPath: db) {
                try FileManager.default.removeItem(atPath: db)
            }
        } catch {
            print("Could not destroy \(db) Database file.")
        }
    }
}

// ====

// MARK: database methods
/*
func createDatabase(){
    
    do {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let dbPath = documentDirectory.appendingPathComponent("dexgreen.sqlite")
        print(dbPath)
        dbDexGreen = try SQLiteDatabase.open(path: dbPath)
        print("Successfully opened connection to database.")
        cratetable()
    } catch SQLiteError.OpenDatabase(let message) {
        print("Unable to open database. Verify that you created the directory described in the Getting Started section.")
        print(message)
    } catch (let error){
        // Catch any other errors
        print(error)
    }
}

func cratetable(){
    do { try dbDexGreen?.createTable(table: Category.self) } catch { print(error) }
    do { try dbDexGreen?.createTable(table: Product.self) } catch { print(error) }
    do { try dbDexGreen?.createTable(table: Resource.self) } catch { print(error) }
    do { try dbDexGreen?.createTable(table: News.self) } catch { print(error) }
}

//
 

func insertCategory(){
    
    var insertStmt = "INSERT OR REPLACE  INTO \(Table.category) (Id, Name, Image) VALUES "
    
    for (index, catObj) in category.enumerated() {
        if index == (category.count - 1) {
            insertStmt.append("(\(catObj.id ?? 0),\"\(catObj.name ?? "")\",\"\(catObj.image ?? "")\");")
        } else {
            insertStmt.append("(\(catObj.id ?? 0),\"\(catObj.name ?? "")\",\"\(catObj.image ?? "")\"),")
        }
    }
    
    do {
        try appDelegateSharedInstance.dbDexGreen?.insertAllRecords(table: Table.category, qString: insertStmt)
    } catch (let error) {
        print("category insert error : \(error)")
    }
}
 
 */

