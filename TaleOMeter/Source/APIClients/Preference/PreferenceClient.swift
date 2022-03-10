//
//  PreferenceClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

class PreferenceClient {
    static func getBubbles(_ completion: @escaping([Preference]?) -> Void) {
        APIClient.shared.get("", feed: .GetPreference, completion: { result in
            ResponseAPI.getResponseArray(result) { response in
                var prefBubbles = [Preference]()
                if let prefBubble = response {
                    prefBubble.forEach({ (object) in
                        prefBubbles.append(Preference(object))
                    })
                }
                completion(prefBubbles)
            }
        })
    }
    
    static func getCategories(_ completion: @escaping([PreferenceCategory]?) -> Void) {
        APIClient.shared.get("", feed: .GetPrefCategory, completion: { result in
            ResponseAPI.getResponseArray(result) { response in
                var prefCategories = [PreferenceCategory]()
                if let prefCategory = response {
                    prefCategory.forEach({ (object) in
                        prefCategories.append(PreferenceCategory(object))
                    })
                }
                completion(prefCategories)
            }
        })
    }
    
    static func getUserBubbles(_ completion: @escaping([UserPreference]?) -> Void) {
        APIClient.shared.get("", feed: .UserPreferences, completion: { result in
            ResponseAPI.getResponseArray(result, showAlert: false) { response in
                var userPrefs = [UserPreference]()
                if let userPref = response {
                    userPref.forEach({ (object) in
                        userPrefs.append(UserPreference(object))
                    })
                }
                completion(userPrefs)
            }
        })
    }
    
    static func setUserBubbles(_ prefRequest: PreferenceRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(prefRequest, feed: .UserPreferences) { result in
            ResponseAPI.getResponseJsonBool(result, showAlert: false) { status in
                completion(status)
            }
        }
    }
}
