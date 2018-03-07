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
    case group              = "PBXGroup"
    case variantGroup       = "PBXVariantGroup"
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


enum Explicit: String {
    ///other
    case application    = "wrapper.application"
    case dsym           = "wrapper.dsym"
    case cfbundle       = "wrapper.cfbundle"
    case folder         = "folder"
    case asset          = "folder.assetcatalog"
    case stickers       = "folder.stickers"
    case framework      = "wrapper.framework"
    case htmld          = "wrapper.htmld"
    case mpkg           = "wrapper.installer-mpkg"
    case pkg            = "wrapper.installer-pkg"
    case plug           = "wrapper.app-extension"
    case rtfd           = "wrapper.rtfd"
    case xpc            = "wrapper.xpc-service"
    case project        = "wrapper.pb-project"
    ///CoreData
    case mapping        = "wrapper.xcmappingmodel"
    case model          = "wrapper.xcdatamodel"
    case version        = "wrapper.xcdatamodeld"
}

enum Destination {
    
    case absolute
    case dsym
    case cfbundle
    case folder
    case asset
    case stickers
    case framework
    case htmld
    case mpkg
    case pkg
    case plug
    
}


