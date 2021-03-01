//
//  File.swift
//  
//
//  Created by Daniel Spady on 2021-03-01.
//

import Vapor
import Fluent

// Define a Class that conforms to Model
final class Acronym: Model {
    
    // Specify the schema as required by Model. This is the name of the table in the database
    static let schema = "acronyms"
    
    // Define an optional property that stores the ID of the model, if one has been set. This is annotated with Fluent's @ID property wrapper. This tells Fluent what to use to look up the model in the database
    @ID
    var id: UUID?
    
    // Define two String properties to hold the acronym and its definition. These use the @Field property wrapper to denote a generic database field. The key parameter is the name of the column in the database
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    // Provide an empty initializer as required by Model. Fluent uses this to initialize models returned from database queries.
    init() {}
    
    // Provide an initializer to create the model
    init(id: UUID? = nil, short: String, long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}

extension Acronym: Content {}
