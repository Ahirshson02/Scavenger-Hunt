//
//  Task.swift
//  ScavengerHunt
//
//  Created by Debbie Hirshson on 1/19/25.
//

import UIKit
import CoreLocation

class Task{
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool{
        image != nil;
    }
    init(title: String, description: String){
        self.title = title
        self.description = description
    }
    func set(_ image: UIImage, with location: CLLocation){
        self.image = image
        self.imageLocation = location
    }
}
extension Task{
    static var mockHunts: [Task]{
        return [
            Task(title: "Your favorite park", description: "Where is your favorite park?"), Task(title: "Biggest Tree Around", description: "Where is the biggest tree?"), Task(title: "Local Mom & Pop Restaurant", description: "Where's the restaurant?")
        ]
    }
}
