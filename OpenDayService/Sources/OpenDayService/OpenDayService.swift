import Foundation
import Combine
import Models

public final class OpenDayService {
    private let baseURL: URL
    private let urlSession: URLSession

    private let decoder = JSONDecoder()

    public enum Endpoint {
        case entries
        case createEntry(_ entry: Entry)
        case deleteEntry(_ entry: Entry)

        var path: String {
            switch self {
            case .entries:
                return "entries"
            case .createEntry:
                return "entry"
            case .deleteEntry(let entry):
                return "entry/\(entry.id ?? "")"
            }
        }

        var method: String {
            switch self {
            case .entries:
                return "GET"
            case .createEntry:
                return "POST"
            case .deleteEntry:
                return "DELETE"
            }
        }

        var httpBody: Data? {
            switch self {
            case .entries, .deleteEntry:
                return nil
            case .createEntry(let entry):
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.keyEncodingStrategy = .convertToSnakeCase
                return try? encoder.encode(entry)
            }
        }
    }

    public init(baseURL: URL,
                urlSession: URLSession) {
        self.baseURL = baseURL
        self.urlSession = urlSession

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    public func perform<T: Codable>(endpoint: Endpoint) -> Future<T, Error> {
        let queryURL = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: queryURL)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.httpBody

        return Future<T, Error> { promise in
            let task = self.urlSession.dataTask(with: request) { data, _, error in
                        guard let data = data else { return }

                        do {
                            let object = try self.decoder.decode(T.self, from: data)
                            DispatchQueue.main.async {
                                promise(.success(object))
                            }
                        } catch let error {
                            DispatchQueue.main.async {
                                #if DEBUG
                                print("JSON Decoding Error: \(error)")
                                #endif
                                promise(.failure(error))
                            }
                        }
                    }
                    task.resume()
        }
    }
}
