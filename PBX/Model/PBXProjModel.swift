//
//  PBXProjModel.swift
//  PBX
//
//  Created by zhengfeng on 2018/3/7.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

import Foundation

public func projIdentifier() ->String
{
    var str = UUID.init().uuidString
    var arr:Array = str.components(separatedBy: "-")
    arr.removeLast()
    str = arr.joined(separator: "")
    return str
}

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

public class Proj :CustomStringConvertible {
    
    var archiveVersion:String = "1"
    var classes:[String:Any] = [String:Any]()
    var objectVersion:String = "46"
    var objects:[Base] = [Base]()
    var rootObject:String = ""
    
    public var description: String{
        get{
            return """
            \(Proj.self)={
            archiveVersion = \(archiveVersion)
            objectVersion = \(objectVersion)
            rootObject = \(rootObject)
            }
            """
        }
    }
}

public class Base {
    var identifier:String = projIdentifier()
    private(set) var isa:Isa = Isa.fileReference
    
    func plist() -> Plist{
        var propreties:[String:Any] = [String:Any]()
        propreties["isa"] = isa.rawValue
        return Plist.plistWithObj(propreties)!
    }
}

// MARK: - PBXProject
// FIXME: - This is the element for a build target that produces a binary content (application or library).
public class Project:Base {
    override var isa:Isa { return Isa.project }
    
    var attributes:[String:Any] = ["LastUpgradeCheck":"9999"]
    var buildConfigurationList:ConfigList = ConfigList()
    
    var compatibilityVersion:String = "Xcode 8.0";
    var developmentRegion:String = "English"
    var hasScannedForEncodings:String = "0"
    var knownRegions:[String] = ["en"]
    
    var mainGroup:Group
    var productRefGroup:Group
    var projectDirPath:String = ""
    var projectRoot:String = ""
    
    var projectReferences:[String]?
    var targets:[Target] = [Target]()
    
    init(main:Group, product:Group) {
        mainGroup = main
        productRefGroup = product
    }
}

// MARK: - XCBuildConfiguration
// FIXME: - This is the element for defining build configuration.
public class BuildConfig : Base {
    override var isa:Isa { return Isa.buildConfig }
    var baseConfigurationReference:String = ""
    var buildSettings:[String:Any] = [String:Any]()
    var name:String = ""
    
}

// MARK: - XCConfigurationList
// FIXME: - This is the element for listing build configurations.
public class ConfigList : Base {
    override var isa:Isa { return Isa.configList }
    var buildConfigurations:[BuildConfig] = [BuildConfig]()
    var defaultConfigurationIsVisible:String = "0"
    var defaultConfigurationName:String = "Release"
    
}

// MARK: - PBXTarget
// FIXME: - This element is an abstract parent for specialized targets.
public protocol Target {
    var name:String {get set}
    var productName:String {get set}
}

// FIXME: - This is the element for a build target that produces a binary content (application or library).
public class NativeTarget : Base, Target {
    override var isa:Isa { return Isa.native }
    
    var buildConfigurationList:ConfigList = ConfigList()
    var buildPhases:[BuildPhase] = [BuildPhase]()
    var dependencies:[TargetDependency] = [TargetDependency]()
    
    public var name:String
    public var productName:String
    
    var buildRules:[BuildPhase] = [BuildPhase]()
    var productInstallPath:String?
    var productReference:FileReference?
    var productType:ProductType
    
    public enum ProductType: String {
        case application = "com.apple.product-type.application"
        case staticArchive = "com.apple.product-type.library.static"
        case dynamicLibrary = "com.apple.product-type.library.dynamic"
        case framework = "com.apple.product-type.framework"
        case executable = "com.apple.product-type.tool"
        case bundle = "com.apple.product-type.bundle"
        var asString: String { return rawValue }
    }
    
    init(productType: ProductType, name: String) {
        self.name = name
        self.productType = productType
        self.productName = name
    }
}
// FIXME: This is the element for a build target that aggregates several others.
public class AggregateTarget :Base, Target {
    override var isa:Isa { return Isa.aggregate }
    
    var buildConfigurationList:ConfigList = ConfigList()
    var buildPhases:[BuildPhase] = [BuildPhase]()
    var dependencies:[TargetDependency] = [TargetDependency]()
    public var name:String
    public var productName:String
    
    init(name: String) {
        self.name = name
        self.productName = name
    }
}

// MARK: - PBXFileElement
// FIXME: - This element is an abstract parent for file and group elements.
public protocol FileElement {
  
}
// FIXME: - A PBXFileReference is used to track every external file referenced by the project: source files, resource files, libraries, generated application files, and so on.
public class FileReference :Base,FileElement {
    override var isa:Isa { return Isa.fileReference }
    
    var fileEncoding:String = "4"
    var explicitFileType:String = ""
    var lastKnownFileType:String = ""
    var name:String = ""
    var path:String = ""
    var sourceTree:String = ""
    
}
// FIXME: -This is the element to group files or groups.
public class Group : Base {
    override var isa:Isa { return Isa.group }
    
    var children:[String] = [String]()
    var name:String = ""
    var sourceTree:String = ""
}
// FIXME: - This is the element for referencing localized resources.
public class VariantGroup : Base,FileElement {
    override var isa:Isa { return Isa.variantGroup }
    
    var children:[String] = [String]()
    var name:String = ""
    var sourceTree:String = ""
}

// MARK: - PBXBuildFile
// FIXME: This element indicate a file reference that is used in a PBXBuildPhase (either as an include or resource).
public class BuildFile: Base{
    override var isa:Isa { return Isa.buildFile }
    
    var fileRef:FileElement
    var settings:[String:Any]?
    
    init(_ fileRef: FileElement) {
        self.fileRef = fileRef
    }

}

// MARK: - PBXBuildPhase
// FIXME: -This element is an abstract parent for specialized build phases.

public protocol BuildPhase {

}
// FIXME: -This is the element for the copy file build phase.
public class CopyFiles :Base,BuildPhase {
    override var isa:Isa { return Isa.copyFiles }
    
    var buildActionMask:String = String(Int(2^32-1))
    var dstPath:String = ""
    var dstSubfolderSpec:String = ""
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
    
}
// FIXME: -This is the element for the framewrok link build phase.
public class Frameworks :Base,BuildPhase {
    override var isa:Isa { return Isa.frameworks }
    
    var buildActionMask:String = String(Int(2^32-1))
    var files:[String] = [String]()
    var runOnlyForDeploymentPostprocessing:String = "0"
    
}
// FIXME: - This is the element for the framewrok link build phase.
public class Headers :Base,BuildPhase {
    override var isa:Isa { return Isa.headers }
    
    var buildActionMask:String = String(Int(2^32-1))
    var files:[String] = [String]()
    var runOnlyForDeploymentPostprocessing:String = "0"
}
// FIXME: - This is the element for the resources copy build phase.
public class Resources :Base,BuildPhase {
    override var isa:Isa { return Isa.resources }
    
    var buildActionMask:String = String(Int(2^32-1))
    var files:[String] = [String]()
    var runOnlyForDeploymentPostprocessing:String = "0"
}
// FIXME: -This is the element for the resources copy build phase.
public class ShellScript :Base,BuildPhase {
    override var isa:Isa { return Isa.shellScript }
    
    var buildActionMask:String = String(Int(2^32-1))
    var files:[String] = [String]()
    var runOnlyForDeploymentPostprocessing:String = "0"
    
    var inputPaths:[String] = [String]()
    var outputPaths:[String] = [String]()
    
    var shellPath:String = ""
    var shellScript:String = ""
}
// FIXME: - This is the element for the sources compilation build phase.
public class Sources :Base,BuildPhase {
    override var isa:Isa { return Isa.sources }
    
    var buildActionMask:String = String(Int(2^32-1))
    var files:[String] = [String]()
    var runOnlyForDeploymentPostprocessing:String = "0"
}

// MARK: - PBXTargetDependency
// FIXME: - This is the element for referencing other target through content proxies.
public class TargetDependency :Base {
    override var isa:Isa { return Isa.dependency }
    
    var target:Target
    var targetProxy:Proxy
    
    init(target:Target,proxy:Proxy) {
        self.target = target
        self.targetProxy = proxy
    }
}
// MARK: -PBXContainerItemProxy
// FIXME: -This is the element for to decorate a target item.
public class Proxy :Base {
    override var isa:Isa { return Isa.proxy }
    
    var containerPortal:Project
    var proxyType:String = "1"
    var remoteGlobalIDString:Target
    var remoteInfo:String
    
    init(project:Project,target:Target) {
        self.containerPortal = project
        self.remoteGlobalIDString = target
        self.remoteInfo = target.name
    }
}

// MARK: -PBXBuildRule
// FIXME: -
public class BuildRules :Base {
    override var isa:Isa { return Isa.rules }
    
    var compilerSpec:String = ""
    var filePatterns:String?
    var fileType:String = ""
    var isEditable:String = "1"
    var outputFiles:[String] = [String]()
    var script:String = "# builtin-copyPlist\n"
}






