//
//  TriviaClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 14/03/22.
//


import Foundation
import UIKit
import SwiftyJSON

class TriviaClient {
    
    static func getTriviaHome(_ completion: @escaping(TriviaHome?) -> Void) {
        APIClient.shared.postJson(parameters: TriviaHomeRequest(), feed: .TriviaHome) { result in
            ResponseAPI.getResponseJson(result) { response in
                var home = TriviaHome()
                if let data = response {
                    home = TriviaHome(data)
                }
                completion(home)
            }
        }
    }
    
    static func getTriviaDailyPost(_ pageNumber: Int, completion: @escaping([TriviaPost]?) -> Void) {
        APIClient.shared.post("?page=\(pageNumber)", parameters: EmptyRequest(), feed: .TriviaDaily) { result in
            ResponseAPI.getResponseArray(result) { response in
                var daily = [TriviaPost]()
                if let dly = response {
                    dly.forEach { object in
                        daily.append(TriviaPost(object))
                    }
                }
                completion(daily)
            }
        }
    }
    
    static func getCategoryPosts(_ pageNumber: Int, req: TriviaCategoryRequest, completion: @escaping([TriviaPost]?) -> Void) {
        APIClient.shared.post("?page=\(pageNumber)", parameters:req, feed: .TriviaCategoryPost) { result in
            ResponseAPI.getResponseArray(result) { response in
                var posts = [TriviaPost]()
                if let psts = response {
                    psts.forEach { object in
                        posts.append(TriviaPost(object))
                    }
                }
                completion(posts)
            }
        }
    }
    
    static func submitAnswer(_ req: SubmitAnswerRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .TriviaSubmitAnswer) { result in
            ResponseAPI.getResponseJsonBool(result, showSuccMessage: true) { status in
                completion(status)
            }
        }
    }
    
    static func getAnswers(_ req: PostIdRequest, completion: @escaping(TriviaAnswer?) -> Void) {
        APIClient.shared.post(parameters: req, feed: .TriviaViewAnswer) { result in
            ResponseAPI.getResponseArray(result) { response in
                var answers = TriviaAnswer()
                if let anss = response {
                    anss.forEach { object in
                        let triAns = TriviaAnswer(object)
                        if triAns.Post_id == req.post_id {
                            answers = triAns
                        }
                       // answers.append(TriviaAnswer(object))
                    }
                }
                completion(answers)
            }
        }
    }
    
    static func getComments(_ req: PostIdRequest, completion: @escaping([TriviaComment]?) -> Void) {
        APIClient.shared.post(parameters: req, feed: .TriviaViewCommnets) { result in
            ResponseAPI.getResponseArray(result) { response in
                var comments = [TriviaComment]()
                if let coms = response {
                    coms.forEach { object in
                        comments.append(TriviaComment(object))
                    }
                }
                completion(comments)
            }
        }
    }
    
    static func addComments(_ req: AddCommentRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .TriviaAddCommennt) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
    
    static func viewPost(_ req: PostIdRequest, completion: @escaping(Bool?) -> Void) {
        APIClient.shared.postJson(parameters: req, feed: .TriviaPostView) { result in
            ResponseAPI.getResponseJsonBool(result) { status in
                completion(status)
            }
        }
    }
    
    static func getLeaderboards(_ completion: @escaping(LeaderboardData?) -> Void) {
        APIClient.shared.postJson(parameters: EmptyRequest(), feed: .Leaderboard) { result in
            ResponseAPI.getResponseJson(result) { response in
                var leaderData: LeaderboardData?
                if let data = response {
                    leaderData = LeaderboardData(data)
                }
                completion(leaderData)
            }
        }
        
    }
}
