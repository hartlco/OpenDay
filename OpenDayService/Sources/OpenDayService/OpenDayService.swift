import Foundation
import Combine
import Models

public protocol Client {
    func dataTask(request: URLRequest, completion: @escaping (Data?, Error?) -> Void)
}

extension URLSession: Client {
    public func dataTask(request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        dataTask(with: request) { data, _, error in
            completion(data, error)
        }.resume()
    }
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}

public struct SynchronousClient: Client {
    private let urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func dataTask(request: URLRequest, completion: @escaping (Data?, Error?) -> Void) {
        let (data, _, error) = urlSession.synchronousDataTask(urlrequest: request)
        completion(data, error)
    }
}

public final class OpenDayService {
    private let baseURL: URL
    private let client: Client

    private let decoder = JSONDecoder()

    public enum Endpoint {
        case entries
        case createEntry(_ entry: Entry)
        case deleteEntry(_ entry: Entry)
        case updateEntry(_ entry: Entry)

        var path: String {
            switch self {
            case .entries:
                return "entries"
            case .createEntry:
                return "entry"
            case .deleteEntry(let entry):
                return "entry/\(entry.id ?? "")"
            case .updateEntry(let entry):
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
            case .updateEntry:
                return "PUT"
            }
        }

        var httpBody: Data? {
            switch self {
            case .entries, .deleteEntry:
                return nil
            case .createEntry(let entry), .updateEntry(let entry):
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.keyEncodingStrategy = .convertToSnakeCase
                return try? encoder.encode(entry)
            }
        }
    }

    public init(baseURL: URL,
                client: Client) {
        self.baseURL = baseURL
        self.client = client

        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    public func perform<T: Codable>(endpoint: Endpoint) -> Future<T, Error> {
        let queryURL = baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: queryURL)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.httpBody

        return Future<T, Error> { promise in
            self.client.dataTask(request: request) { data, error in
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
        }
    }
}
