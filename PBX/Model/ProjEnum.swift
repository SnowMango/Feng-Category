//
//  ProjEnum.swift
//  PBX
//
//  Created by zhengfeng on 2018/3/7.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

import Foundation

public enum Isa:String  {
    
    case buildFile          = "PBXBuildFile"
    //BuildPhase
    case appleScript        = "PBXAppleScriptBuildPhase"
    case copyFiles          = "PBXCopyFilesBuildPhase"
    case frameworks         = "PBXFrameworksBuildPhase"
    case headers            = "PBXHeadersBuildPhase"
    case resources          = "PBXResourcesBuildPhase"
    case shellScript        = "PBXShellScriptBuildPhase"
    case sources            = "PBXSourcesBuildPhase"
    
    case proxy              = "PBXContainerItemProxy"
    //FileElement
    case fileReference      = "PBXFileReference"
    case refProxy           = "PBXReferenceProxy"
    case group              = "PBXGroup"
    case variantGroup       = "PBXVariantGroup"
    case versionGroup       = "XCVersionGroup"
    //Target
    case aggregate          = "PBXAggregateTarget"
    case legacy             = "PBXLegacyTarget"
    case native             = "PBXNativeTarget"
    
    case project            = "PBXProject"
    case dependency         = "PBXTargetDependency"
    case buildConfig        = "XCBuildConfiguration"
    case configList         = "XCConfigurationList"
    case rules              = "PBXBuildRule"
}

public enum ProductType: String {
    case application = "com.apple.product-type.application"
    case staticArchive = "com.apple.product-type.library.static"
    case dynamicLibrary = "com.apple.product-type.library.dynamic"
    case framework = "com.apple.product-type.framework"
    case executable = "com.apple.product-type.tool"
    case bundle = "com.apple.product-type.bundle"
    var asString: String { return rawValue }
}

/// Determines the base path for a reference's relative path (this is
/// what for some reason is called a "source tree" in Xcode).
public enum PathBase: String {
    /// Indicates that the path is relative to the source root (i.e.
    /// the "project directory").
    case projectDir = "SOURCE_ROOT"
    /// Indicates that the path is relative to the path of the parent
    /// group.
    case groupDir = "<group>"
    /// Indicates that the path is relative to the effective build
    /// directory (which varies depending on active scheme, active run
    /// destination, or even an overridden build setting.
    case buildDir = "BUILT_PRODUCTS_DIR"
    /// The string form, suitable for use in an Xcode project file.
    case sdkDir   = "SDKROOT"
    
    case absolute = "<absolute>"
    
    case developerDir   = "DEVELOPER_DIR"
    
    var asString: String { return rawValue }
}


public enum Explicit {
    public enum Folder :String {
        case asset          = "folder.assetcatalog"
        case stickers       = "folder.stickers"
        case folder         = "folder"
    }
    ///other
    public enum Other :String {
        case application    = "wrapper.application"
        case dsym           = "wrapper.dsym"
        case cfbundle       = "wrapper.cfbundle"
        
        case framework      = "wrapper.framework"
        case htmld          = "wrapper.htmld"
        case mpkg           = "wrapper.installer-mpkg"
        case pkg            = "wrapper.installer-pkg"
        case plug           = "wrapper.app-extension"
        case rtfd           = "wrapper.rtfd"
        case xpc            = "wrapper.xpc-service"
        case project        = "wrapper.pb-project"
    }
    ///CoreData
    public enum CoreData :String {
        case mapping        = "wrapper.xcmappingmodel"
        case model          = "wrapper.xcdatamodel"
        case version        = "wrapper.xcdatamodeld"
    }
    case folder(Folder)
    case other(Other)
    case coreData(CoreData)
    
    func serialize() -> String {
        switch self {
        case .folder(let item):
            return item.rawValue
        case .other(let item):
            return item.rawValue
        case .coreData(let item):
            return item.rawValue
        }
    }
}
    
public enum Destination {

    case absolute
    case products
    case wrapper
    case execurables
    case resources
    case javaRes
    case frameworks
    case shareFrameworks
    case shareSupport
    case plug
    case xpc
    
    var asString:String {
        switch(self){
        case .absolute:
            return "0"
        case .products,.xpc:
            return "16"
        case .wrapper:
            return "1"
        case .execurables:
            return "6"
        case .resources:
            return "7"
        case .javaRes:
            return "15"
        case .frameworks:
            return "10"
        case .shareFrameworks:
            return "11"
        case .shareSupport:
            return "12"
        case .plug:
            return "13"
        }
    }
    var asDefString: String {
        switch(self){
        case .xpc:
            return "$(CONTENTS_FOLDER_PATH)/XPCServices"
        default:
            return ""
        }
    }
}

public enum BuildActionMask:String{
    case install    = "8"
    case build      = "12"
    case def        = "2147483647"
}

public enum ProjectFomat:String{
    case xcode8_0    = "xcode 8.0"
    case xcode6_3    = "xcode 6.3"
    case xcode3_2    = "xcode 3.2"
    case xcode3_1    = "xcode 3.1"
}

public enum FileEnding:String{
    case CF      = "0"
    case CR      = "1"
    case CRLF    = "2"
}



