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
    
    // Register a new route handler that accepts a GET request which returns EventLoopFuture<[Acronym]>, a future array of Acronyms.
    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        
        // Perform a query to get all the acronyms
        Acronym.query(on: req.db).all()
    }
    // Register a route at /api/acronyms/<ID> to handle a GET request. The route takes the acronyms's id property as the final path segment. This returns EventLoopFuture<Acronym>.
    app.get("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        // Get the parameter passed in with the name acronymID. Use find(_:on:) to query the database for an Acronym with that ID. Note that because find(_:on:) takes a UUID as the first parameter (because Acronym's id type is UUID), get(_:) infers the return type as UUID. By default, it returns String. You can specify the type with get(_:as:).
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
        // find(_:on:) returns EventLoopFuture<Acronym?> because an acronym with that ID might not exist in the database. Use unwrap(or:) to ensure that you return an acronym. If no acronym is found, unwrap(or:) returns a failed future with the error provided. In this case, it returns a 404 Not Found error.
            .unwrap(or: Abort(.notFound))
    }
    // Register a route for a PUT request to /api/acronyms/<ID> that returns EventLoopFuture<Acronym>
    app.put("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        // Decode the request body to Acronym to get the new details.
        let updateAcronym = try req.content.decode(Acronym.self)
        // Get the acronym using the ID from the request URL. Use unwrap(or:) to return a 4040 Not Found if no acronym with the ID provided is found. This returns EventLoopFuture<Acronym> so use flatMap(_:) to wait for the future to complete.
        return Acronym.find(req.parameters.get("acronymID"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { acronym in
            // Update the acronym's properties with the new values.
            acronym.short = updateAcronym.short
            acronym.long = updateAcronym.long
            // Save the acronym and wait for it to complete with map(_:). Once the save has returned, return the updated acronym.
            return acronym.save(on: req.db).map { acronym }
        }
    }
    // Register a route for a DELETE request to /api/acronyms/<ID> that returns EventLoopFuture<HTTPStatus>.
    app.delete("api", "acronyms", ":acronymID") { req -> EventLoopFuture<HTTPStatus> in
        // Extract the acronym to delete from the requests parameters as before.
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
                // Use flatMap(_:) to wait for the acronym to return from the database.
                .flatMap { acronym  in
                    // Delete the acronym using delete(on:)
                    acronym.delete(on: req.db)
                        // Transform the result into a 204 No Content response. This tells the client the request has successfully completed but there's no content to return
                        .transform(to: .noContent)
                }
    }
}
