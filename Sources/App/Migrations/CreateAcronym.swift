//
//  File.swift
//  
//
//  Created by Daniel Spady on 2021-03-01.
//

import Fluent

// Define a new type, Create Acronym that conforms to Migration
struct CreateAcronym: Migration {
    
    // Implement prepare(on:) as required by Migration. You call this method when you run your migrations
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        // Define the table name for this model. This must match schema from the model
        database.schema("acronyms")
        
        // Define the ID column in the database
        .id()
        
        // Define columns for short and long. Set the column type to string and mark the columns as required. This matches the non-optional String properties in the model. The field names must match the key of the propery wrapper
        .field("short", .string, .required)
        .field("long", .string, .required)
            
        // Create the table in the database
        .create()
    }
    
    // Implement revert(on:) as required by Migration. You call this function when you revert your migrations. This deletes the table referenced with schema(_:).
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms").delete()
    }
}
