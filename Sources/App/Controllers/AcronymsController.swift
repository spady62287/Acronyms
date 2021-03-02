//
//  File.swift
//  
//
//  Created by Daniel Spady on 2021-03-02.
//

import Vapor
import Fluent

// Route Collections

// Inside a controller, you define different route handlers. To access these routes, you must register these handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct AcronymsController: RouteCollection {
    // RouteCollection requires you to implement boot(router:) to register routes. Add a new route handler after boot(routes:):
    func boot(routes: RoutesBuilder) throws {
        // If you need to change the /api/acronyms/ path, you have to change the path in multiple locations. If you add a new route, you have to remeber to add both parts of the path. Vapor provides route groups to simplify this.
        let acronymsRoutes = routes.grouped("api", "acronyms")
        // replace the below route with the grouped route
//        routes.get("api", "acronyms", use: getAllHandler)
        // C
        acronymsRoutes.post(use: createHandler)
        // R
        acronymsRoutes.get(use: readAllHandler)
        acronymsRoutes.get(":acronymID", use: readHandler)
        // U
        acronymsRoutes.put(":acronymID", use: updateHandler)
        // D
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        // Search
        acronymsRoutes.get("search", use: searchHandler)
        // First
        acronymsRoutes.get("first", use: getFirstHandler)
        // Sorted
        acronymsRoutes.get("sorted", use: sortedHandler)
    }
    // The body of the handler is identical to the one written earlier and the signature matches the signature of the closure you used before. Register the route in boot(router:):
    // C
    func createHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db).map { acronym }
    }
    // R
    func readAllHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db).all()
    }
    func readHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    // U
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        let updatedAcronym = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { acronym in
                acronym.short = updatedAcronym.short
                acronym.long = updatedAcronym.long
                return acronym.save(on: req.db).map {
                    acronym
                }
            }
    }
    // D
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    // Search
    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req.db).group(.or) { or in
            or.filter(\.$short == searchTerm)
            or.filter(\.$long == searchTerm)
        }.all()
    }
    // First
    func getFirstHandler(_ req: Request) throws -> EventLoopFuture<Acronym> {
        return Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    // Sort
    func sortedHandler(_ req: Request) throws -> EventLoopFuture<[Acronym]> {
        return Acronym.query(on: req.db)
            .sort(\.$short, .ascending).all()
    }
}
