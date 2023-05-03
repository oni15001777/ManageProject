
import Foundation

extension URLSession {
    
    func fetchData<T: Codable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        self.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: nil)))
                return
            }
            
            if let data = data {
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch let decoderError {
                    completion(.failure(decoderError))
                }
            } else {
                completion(.failure(NSError(domain: "MissingData", code: -1, userInfo: nil)))
            }
        }.resume()
    }

    func putData<T: Codable>(_ object: T, urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            request.httpBody = data
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON data before sending the request: \(jsonString)")
            }
            
        } catch {
            completion(.failure(error))
        }
        
        self.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in URLSession data task: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updatedObject = try decoder.decode(T.self, from: data)
                completion(.success(updatedObject))
            } catch {
                print("Error decoding JSON: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteData(urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
          guard let url = URL(string: urlString) else {
              return
          }
          
          var request = URLRequest(url: url)
          request.httpMethod = "DELETE"
          
          self.dataTask(with: request) { _, response, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              
              guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                  completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: nil)))
                  return
              }
              
              completion(.success(()))
          }.resume()
      }
      
      func postData<T: Codable>(_ object: T, urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
          guard let url = URL(string: urlString) else {
              return
          }
          
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          
          do {
              let encoder = JSONEncoder()
              let data = try encoder.encode(object)
              request.httpBody = data
              
              if let jsonString = String(data: data, encoding: .utf8) {
                  print("JSON data before sending the request: \(jsonString)")
              }
              
          } catch {
              completion(.failure(error))
          }
          
          self.dataTask(with: request) { data, response, error in
              if let error = error {
                  print("Error in URLSession data task: \(error)")
                  completion(.failure(error))
                  return
              }
              
              if let httpResponse = response as? HTTPURLResponse {
                  print("HTTP Status Code: \(httpResponse.statusCode)")
              }
              
              guard let data = data else {
                  completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                  return
              }
              
              do {
                  let decoder = JSONDecoder()
                  let createdObject = try decoder.decode(T.self, from: data)
                  completion(.success(createdObject))
              } catch {
                  print("Error decoding JSON: \(error)")
                  completion(.failure(error))
              }
          }.resume()
      }
  }
