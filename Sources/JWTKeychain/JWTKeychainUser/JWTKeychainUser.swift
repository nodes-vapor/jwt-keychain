import Authentication
import Crypto
import Fluent
import JWT
import Sugar
import Vapor

public protocol JWTKeychainUser: JWTCustomPayloadKeychainUser where
    JWTPayload == Payload
{}

extension JWTKeychainUser {
    public func makePayload(
        expirationTime: Date,
        on container: Container
    ) throws -> Future<Payload> {
        return Future.map(on: container) {
            try Payload(
                exp: ExpirationClaim(value: expirationTime),
                sub: SubjectClaim(value: self.requireID().convertToString())
            )
        }
    }
}

// MARK: - JWTCustomPayloadKeychainUser

public protocol JWTCustomPayloadKeychainUser:
    Content,
    HasPassword,
    JWTAuthenticatable,
    UserType,
    PasswordAuthenticatable,
    PublicRepresentable
where
    Self.Database: QuerySupporting,
    Self.ID: StringConvertible
{}

extension JWTCustomPayloadKeychainUser {
    public static func authenticate(
        using payload: JWTPayload,
        on connection: DatabaseConnectable
    ) throws -> Future<Self?> {
        return try find(.convertFromString(payload.sub.value), on: connection)
    }
}

extension Model where Database: QuerySupporting {
    static func requireFind(_ id: ID, on worker: DatabaseConnectable) throws -> Future<Self> {
        return try Self
            .find(id, on: worker)
            .unwrap(or: Abort(.notFound, reason: "\(Self.self) with id \(id) not found"))
    }
}
