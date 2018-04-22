import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where
    JWTPayload == JWTKeychain.Payload
{}

extension JWTKeychainUser {
    public func makePayload(expirationTime: Date, on req: Request) -> Future<JWTPayload> {
        return Future.map(on: req) {
            try JWTPayload(
                exp: ExpirationClaim(value: expirationTime),
                sub: SubjectClaim(value: self.requireID().convertToString())
            )
        }
    }
}

public protocol JWTCustomPayloadKeychainUser:
    Content,
    HasHashedPassword,
    JWTAuthenticatable,
    PublicRepresentable
where
    Self.Database: QuerySupporting,
    Self.ID: StringConvertible
{
    associatedtype Login: PasswordPayload
    associatedtype Registration: PasswordPayload
    associatedtype Update: Decodable

    static func logIn(with: Login, on: DatabaseConnectable) throws -> Future<Self?>
    init(_: Registration) throws

    func update(using: Update) throws
}

extension JWTCustomPayloadKeychainUser {
    public static func validateStrength(ofPassword password: String) throws {
        // TODO: stricter validation
        guard password.count > 8 else {
            throw JWTKeychainError.weakPassword
        }
    }

    public static var bCryptCost: Int {
        return 4
    }

    public static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?> {
        return try find(.convertFromString(payload.sub.value), on: connection)
    }

    public static func logIn(on request: Request) throws -> Future<Self> {
        return try request
            .content
            .decode(Login.self)
            .flatMap(to: Self.self) { login in
                try logIn(with: login, on: request)
                    .unwrap(or: JWTKeychainError.userNotFound)
                    .map(to: Self.self) { user in
                        guard
                            let created = Data(base64Encoded: user.password.value),
                            try BCrypt.verify(login.password, created: created)
                        else {
                            throw JWTKeychainError.incorrectPassword
                        }

                        return user
                    }
            }
    }

    public static func register(on request: Request) throws -> Future<Self> {
        let content = request.content

        return try content
            .decode(Registration.self)
            .flatMap(to: Self.self) { registration in
                return try Self(registration).save(on: request)
            }
    }
}
