//
//  ProjModelSerialization.swift
//  PBX
//
//  Created by zhengfeng on 2018/3/8.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

import Foundation



protocol Serialization
{
    func plist() -> Plist
}



extension Project: Serialization{
     func plist() -> Plist {
        var propreties:[String:Any] = [String:Any]()
        propreties["isa"] = isa!.rawValue
        propreties["buildConfigurationList"] = buildConfigurationList.identifier
        propreties["compatibilityVersion"] = compatibilityVersion
        propreties["hasScannedForEncodings"] = hasScannedForEncodings
        propreties["knownRegions"] = knownRegions
        propreties["mainGroup"] = mainGroup.identifier
        propreties["productRefGroup"] = productRefGroup.identifier
        propreties["projectDirPath"] = projectDirPath
        propreties["projectRoot"] = projectRoot
        if projectReferences != nil {
            propreties["projectReferences"] = projectReferences
        }
        propreties["targets"] = targets.map({ return $0.isa })
        return Plist.plistWithObj(propreties)!
    }
}

extension NativeTarget: Serialization {
     func plist() -> Plist {
        var propreties:[String:Any] = [String:Any]()
        propreties["isa"] = isa!.rawValue

        return Plist.plistWithObj(propreties)!
    }
}

extension AggregateTarget : Serialization {
     func plist() -> Plist {
        var propreties:[String:Any] = [String:Any]()
        propreties["isa"] = isa!.rawValue
        
        return Plist.plistWithObj(propreties)!
    }
}
