import Vapor
import HTTP

/// Defines basic authorization functionality.
public protocol UserControllerType {
    /// Initializes the UsersController with a JWT configuration.
    ///
    /// - Parameters:
    /// configuration : the JWT configuration to be used to generate user tokens.
    init(configuration: ConfigurationType)

    /// Registers a user on the DB.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or if unable to store data on the DB.
    func register(request: Request) throws -> ResponseRepresentable

    /// Logins the user on the system, giving the token back.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on invalid data or wrong credentials.
    func login(request: Request) throws -> ResponseRepresentable

    /// Logs the user out of the system.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON success response.
    /// - Throws: if not able to find token.
    func logout(request: Request) throws -> ResponseRepresentable

    /// Generates a new token for the user.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON with token.
    /// - Throws: if not able to generate token.
    func regenerate(request: Request) throws -> ResponseRepresentable

    /// Returns the authenticated user data.
    ///
    /// - Parameter request: current request.
    /// - Returns: JSON response with User data.
    /// - Throws: on no user found.
    func me(request: Request) throws -> ResponseRepresentable
}