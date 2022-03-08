//
//  Story.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//

struct Story {
    let id: String
    let name: String
    let image: String
    let created_at: String
    let updated_at: String
    let deleted_at: String
}

struct StoryRequest: Codable {
    var Plot_id = Int()
    var Page = Int()
}
/* {
 "id": 8,
 "name": "Adventure",
 "image": "storage/app/public/story/znKzwtzPD3Exh69vSxGz4Z5dDlVOQ3geVmTOmYWs.jpg",
 "created_at": "2022-03-07T11:24:18.000000Z",
 "updated_at": "2022-03-08T11:40:12.000000Z",
 "deleted_at": null
}*/
