//
//  DataModel.swift
//  GitHub Explorer
//
//  Created by Daniel Wahby on 19/04/2021.
//

import Foundation

struct GitHubUser:Codable{
    var full_name:String?
    var owner:Owner?
    var description:String?
    var extraInfo:ExtraRepoInfo?
}

struct Owner:Codable{
    var login:String?
    var avatar_url:String?
    var url:String?
}
struct ExtraRepoInfo:Codable{
    var created_at:String?
    var location:String?
    var followers:Int?
    var following:Int?
}
