//
//  GenreClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

class GenreClient {
    static func getData(_ completion: @escaping([Genre]?) -> Void) {
        APIClient.shared.get("", feed: .Genres, completion: { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var genres = [Genre]()
                if let genre = response {
                    genre.forEach({ (object) in
                        genres.append(Genre(object))
                    })
                }
                completion(genres)
            }
        })
    }
}
