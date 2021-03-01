import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    // Register a new route at /api/acronyms that accepts a POST request and returns EventLoopFuture<Acronym>. It returns the acronym once it's saved.
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        
        // Decode the requests's JSON into an Acronym model using Codable
        let acronym = try req.content.decode(Acronym.self)
        
        // Save the model using Fluent and the databse from Requests
        return acronym.save(on: req.db).map {
            // save(on:) returns EventLoopFuture<Void> so use map to return the acronym when the save completes
            acronym
        }
    }
}
