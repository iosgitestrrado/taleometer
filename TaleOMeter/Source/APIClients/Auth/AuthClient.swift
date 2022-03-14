//
//  AuthClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

import Foundation
import UIKit

class AuthClient {
    
    static func login(_ loginReq: LoginRequest, completion: @escaping(Bool) -> Void) {
        APIClient.shared.postJson(loginReq, feed: .SendOtp) { (result) in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
    
    static func verifyOtp(_ veriReq: VerificationRequest, completion: @escaping(ProfileData?, Bool, String, Bool) -> Void) {
        APIClient.shared.postJson(veriReq, feed: .VerifyOtp) { (result) in
            ResponseAPI.getResponseJsonToken(result, showSuccMessage: true, completion: { responseJson, status, token, isNewRegister in
                var verification: ProfileData?
                if let response = responseJson {
                    verification = ProfileData(response)
                }
                completion(verification, status, token, isNewRegister)
            })
        }
    }
    
    static func sendProfileOtp(_ loginReq: LoginRequest, completion: @escaping(Bool) -> Void) {
        APIClient.shared.postJson(loginReq, feed: .SendOtpProfile) { (result) in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
    
    static func verifyProfileOtp(_ veriReq: VerificationRequest, completion: @escaping(ProfileData?) -> Void) {
        APIClient.shared.postJson(veriReq, feed: .VerifyOtpProfile) { (result) in
            ResponseAPI.getResponseJson(result, completion: { responseJson in
                var verification: ProfileData?
                if let response = responseJson {
                    verification = ProfileData(response)
                }
                completion(verification)
            })
        }
    }
    
    static func logout(_ message: String = "") {
        if let cont = UIApplication.shared.windows.first?.rootViewController?.sideMenuController?.rootViewController as? UINavigationController, !(cont.viewControllers.last is LoginViewController) {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            AudioPlayManager.shared.isMiniPlayerActive = false
            AudioPlayManager.shared.isNonStop = false
            
            Login.setGusetData()
            var contStacks = [UIViewController]()
            if let myobject = UIStoryboard(name: Constants.Storyboard.launch, bundle: nil).instantiateViewController(withIdentifier: "LaunchViewController") as? LaunchViewController {
                contStacks.append(myobject)
            }
            if let myobject = UIStoryboard(name: Constants.Storyboard.dashboard, bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
                contStacks.append(myobject)
            }
            cont.viewControllers = contStacks
            let myobject = UIStoryboard(name: Constants.Storyboard.auth, bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            cont.pushViewController(myobject, animated: true)
            if !message.isBlank {
                Snackbar.showAlertMessage(message)
            }
            APIClient.shared.getJson("", feed: .Logout) { result in
                
            }
        }
    }
    
    static func getProfile(_ completion: @escaping(ProfileData?) -> Void) {
        APIClient.shared.getJson("", feed: .GetProfile) { result in
            ResponseAPI.getResponseJson(result) { responseJson in
                var verification: ProfileData?
                if let response = responseJson {
                    verification = ProfileData(response)
                }
                completion(verification)
            }
        }
    }

    static func updateProfile(_ profileReq: ProfileRequest, completion: @escaping(ProfileData?) -> Void) {
        APIClient.shared.postJson(profileReq, feed: .UpdateProfileDetails) { result in
            ResponseAPI.getResponseJson(result) { responseJson in
                var verification: ProfileData?
                if let response = responseJson {
                    verification = ProfileData(response)
                }
                completion(verification)
            }
        }
    }
    
    static func updateProfilePicture(_ imageData: Data, completion: @escaping(ProfileData?) -> Void) {
        self.sendFile("\(Constants.baseURL)/api/update-profile/image", fileName: "profilePic.jpeg", data: imageData) { result in
            ResponseAPI.getResponseJson(result) { responseJson in
                var verification: ProfileData?
                if let response = responseJson {
                    verification = ProfileData(response)
                }
                completion(verification)
            }
        }
    }
    
    static func sendFile(_ urlPath: String, fileName: String, data: Data, completion: @escaping (Result<ResponseModelJSON?, APIError>) -> Void) {
        let url = URL(string: urlPath)!
        var request1: URLRequest = URLRequest(url: url)

        request1.httpMethod = "POST"

        let boundary = "Boundary-\(NSUUID().uuidString)"
        let fullData = self.photoDataToFormData(data, boundary:boundary, fileName:fileName)
        request1.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
//        request1.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // REQUIRED!
        request1.setValue(String(fullData.count), forHTTPHeaderField: "Content-Length")
        request1.setValue(APIClient.shared.getAuthentication(), forHTTPHeaderField: "Authorization")
        //request1.setValue(APIClient.shared.GetDeviceInfo(), forHTTPHeaderField: "Device")

        request1.httpBody = fullData
        request1.httpShouldHandleCookies = false

        URLSession.shared.dataTask(with: request1) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    completion(.failure(.invalidData))
                } else {
                    do {
                        let mutableResponse = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        print(mutableResponse)
                        //completionHandler(mutableResponse as? NSDictionary, (response as! HTTPURLResponse).allHeaderFields as NSDictionary, error)
                    } catch _ {
                        //completionHandler([:], [:], error)
                    }
                    
                    do {
                        let genericModel = try JSONDecoder().decode(ResponseModelJSON.self, from: data!)
                        completion(.success(genericModel))
                    } catch {
                        completion(.failure(.invalidData))
                    }
                }
            }
        }.resume()
    }

    static func photoDataToFormData(_ dataImage: Data, boundary: String, fileName: String) -> Data {
        var fullData = Data()

        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

        // 2
        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.append(lineTwo.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

        // 3
        let lineThree = "Content-Type: image/jpeg\r\n\r\n"
        fullData.append(lineThree.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

        // 4
        fullData.append(dataImage)

        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(using: String.Encoding.utf8, allowLossyConversion: false)!)

        return fullData
    }
}
