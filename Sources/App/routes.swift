import Fluent
import Vapor

func routes(_ app: Application) throws {
    // Create a new AcronymsController
    let acronymsController = AcronymsController()
    
    // Register the new type with the application to ensure the controller's routes get registered.
    try app.register(collection: acronymsController)
}
