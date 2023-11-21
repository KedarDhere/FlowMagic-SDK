//
//  ScreenFlow+CoreDataProperties.swift
//  FlowMagic-SDK
//
//  Created by Kedar Dhere on 10/10/23.
//
//

import Foundation
import CoreData


extension ScreenFlow {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScreenFlow> {
        return NSFetchRequest<ScreenFlow>(entityName: "ScreenFlow")
    }

    @NSManaged public var destinationScreen: String?
    @NSManaged public var sourceScreen: String?

}
