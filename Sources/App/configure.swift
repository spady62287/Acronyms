import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql)
    
    // Add CreateAcronym to the list of migrations to run
    app.migrations.add(CreateAcronym())
    
    // Set the log level for the application to debug. This provides more information and enables you to see your migrations.
    app.logger.logLevel = .debug
    
    // Automatically run migrations and wait for the result. Fluent allows you to choose when to run you migrations. This is helpful when you need to schedule them, for example. You can use wait() here since you're not running on an EventLoop
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
