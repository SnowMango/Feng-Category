//
//  ProjModel.swift
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

public class Xcodeproj {
    
    var archiveVersion:String = "1"
    var classes:[String:Any] = [String:Any]()
    var objectVersion:String = "46"
    var objects:[Base] = [Base]()
    var rootObject:Project?
}

public class Base {
    var identifier:String = projIdentifier()
    private(set) var isa:Isa?

}

// MARK: - PBXProject
// FIXME: - This is the element for a build target that produces a binary content (application or library).
public class Project:Base {
    override var isa:Isa? { return Isa.project }
    
    var attributes:[String:Any] = ["LastUpgradeCheck":"9999"]
    var buildConfigurationList:ConfigList = ConfigList()
    
    var compatibilityVersion:ProjectFomat = .xcode8_0
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
    override var isa:Isa? { return Isa.buildConfig }
    var baseConfigurationReference:FileReference?
    var buildSettings:[String:Any] = [String:Any]()
    var name:String
    
    init(name:String) {
        self.name = name
    }
}

// MARK: - XCConfigurationList
// FIXME: - This is the element for listing build configurations.
public class ConfigList : Base {
    override var isa:Isa? { return Isa.configList }
    var buildConfigurations:[BuildConfig] = [BuildConfig]()
    var defaultConfigurationIsVisible:String = "0"
    var defaultConfigurationName:String = "res"
    
}

// MARK: - PBXTarget
// FIXME: - This element is an abstract parent for specialized targets.
public enum Target {
    case native(NativeTarget)
    case aggregate(AggregateTarget)

    var isa:String {
        switch self {
        case .native(let item):
            return item.isa!.rawValue
        case .aggregate(let item):
            return item.isa!.rawValue
        }
    }
    var name:String {
        switch self {
        case .native(let item):
            return item.name
        case .aggregate(let item):
            return item.name
        }
    }
    var productName:String {
        switch self {
        case .native(let item):
            return item.productName
        case .aggregate(let item):
            return item.productName
        }
    }
}

// FIXME: - This is the element for a build target that produces a binary content (application or library).
public class NativeTarget : Base {
    override var isa:Isa? { return Isa.native }
    
    var buildConfigurationList:ConfigList = ConfigList()
    var buildPhases:[BuildPhase] = [BuildPhase]()
    var dependencies:[TargetDependency] = [TargetDependency]()
    
    public var name:String
    public var productName:String
    
    var buildRules:[BuildPhase] = [BuildPhase]()
    var productInstallPath:String?
    var productReference:FileReference?
    var productType:ProductType
    
    init(productType: ProductType, name: String) {
        self.name = name
        self.productType = productType
        self.productName = name
    }
}
// FIXME: This is the element for a build target that aggregates several others.
public class AggregateTarget :Base {
    override var isa:Isa? { return Isa.aggregate }
    
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
public enum Reference {
    case file(FileReference)
    case variant(VariantGroup)
    case proxy(RefProxy)
    
    var isa:String {
        switch self {
        case .file(let item):
            return item.isa!.rawValue
        case .variant(let item):
            return item.isa!.rawValue
        case .proxy(let item):
            return item.isa!.rawValue
        }
    }
}
// FIXME: - A PBXFileReference is used to track every external file referenced by the project: source files, resource files, libraries, generated application files, and so on.
public class FileReference :Base {
    override var isa:Isa? { return Isa.fileReference }
    
    var fileEncoding:String?
    var explicitFileType:Explicit?
    var lastKnownFileType:String?
    var lineEnding:FileEnding?
    var usesTabs:String?
    var includeInIndex:String?
    
    var name:String
    var path:String
    var sourceTree:PathBase
    
    init(name:String,path:String,tree:PathBase) {
        self.name = name
        self.path = path
        self.sourceTree = tree
    }
    
}
// FIXME: -This is the element to group files or groups.
public class Group : Base {
    override var isa:Isa? { return Isa.group }
    
    var children:[Reference] = [Reference]()
    var name:String
    var sourceTree:PathBase
    
    init(name:String,tree:PathBase) {
        self.name = name
        self.sourceTree = tree
    }
}
// FIXME: - This is the element for referencing localized resources.
public class VariantGroup : Base {
    override var isa:Isa? { return Isa.variantGroup }
    
    var children:[FileReference] = [FileReference]()
    var name:String
    var sourceTree:PathBase
    
    init(name:String,tree:PathBase) {
        self.name = name
        self.sourceTree = tree
    }
}
// FIXME: - This is the element for referencing localized resources.
public class VersionGroup : Base {
    override var isa:Isa? { return Isa.versionGroup }
    
    var children:[FileReference] = [FileReference]()
    var path:String
    var sourceTree:PathBase
    var currentVersion:FileReference?
    var versionGroupType:String?
    init(path:String,tree:PathBase) {
        self.path = path
        self.sourceTree = tree
    }
}

// MARK: - PBXBuildFile
// FIXME: This element indicate a file reference that is used in a PBXBuildPhase (either as an include or resource).
let Public:[String:Any]     = ["ATTRIBUTES":["Public"]]
let Private:[String:Any]    = ["ATTRIBUTES":["Private"]]

public class BuildFile: Base{
    override var isa:Isa? { return Isa.buildFile }
    
    var fileRef:Reference
    var settings:[String:Any]?
    
    init(_ fileRef: Reference) {
        self.fileRef = fileRef
    }
    //Public，Private or nil
    func updateSetting(set:[String:Any]?) {
        settings = set
    }
}

// MARK: - PBXBuildPhase
// FIXME: -This element is an abstract parent for specialized build phases.
public protocol BuildPhase {

}
//public enum BuildPhase {
//    case copyFiles(CopyFiles)
//    case variant(VariantGroup)
//    case proxy(RefProxy)
//    case file(FileReference)
//    case variant(VariantGroup)
//    case proxy(RefProxy)
//    
//    var isa:String {
//        switch self {
//        case .file(let item):
//            return item.isa!.rawValue
//        case .variant(let item):
//            return item.isa!.rawValue
//        case .proxy(let item):
//            return item.isa!.rawValue
//        }
//    }
//}
// MARK: - PBXCopyFilesBuildPhase
// FIXME: -This is the element for the copy file build phase.
public class CopyFiles :Base,BuildPhase {
    override var isa:Isa? { return Isa.copyFiles }
    
    var buildActionMask:BuildActionMask = .def
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
    
    var dstPath:String = ""
    var dstSubfolderSpec:Destination
   
    init(spec:Destination) {
        dstSubfolderSpec = spec
    }
    
}
// MARK: - PBXFrameworksBuildPhase
// FIXME: -This is the element for the framewrok link build phase.
public class Frameworks :Base,BuildPhase {
    override var isa:Isa? { return Isa.frameworks }
    
    let buildActionMask:BuildActionMask = .def
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
    
}
// MARK: - PBXHeadersBuildPhase
// FIXME: - This is the element for the framewrok link build phase.
public class Headers :Base,BuildPhase {
    override var isa:Isa? { return Isa.headers }
    
    let buildActionMask:BuildActionMask = .def
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
}
// MARK: - PBXResourcesBuildPhase
// FIXME: - This is the element for the resources copy build phase.
public class Resources :Base,BuildPhase {
    override var isa:Isa? { return Isa.resources }
    
    let buildActionMask:BuildActionMask = .def
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
}
// MARK: - PBXShellScriptBuildPhase
// FIXME: -This is the element for the resources copy build phase.
public class ShellScript :Base,BuildPhase {
    override var isa:Isa? { return Isa.shellScript }
    
    var buildActionMask:BuildActionMask = .def
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
    ///showEnvVarsInLog:"0"、"1" or nil
    var showEnvVarsInLog:String?
    var inputPaths:[String] = [String]()
    var outputPaths:[String] = [String]()
    
    var shellPath:String = "/bin/sh"
    var shellScript:String = ""
}
// MARK: - PBXSourcesBuildPhase
// FIXME: - This is the element for the sources compilation build phase.
public class Sources :Base,BuildPhase {
    override var isa:Isa? { return Isa.sources }
    
    let buildActionMask:BuildActionMask = .def
    var files:[BuildFile] = [BuildFile]()
    var runOnlyForDeploymentPostprocessing:String = "0"
}

// MARK: - PBXTargetDependency
// FIXME: - This is the element for referencing other target through content proxies.
public class TargetDependency :Base {
    override var isa:Isa? { return Isa.dependency }
    
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
    override var isa:Isa? { return Isa.proxy }
    
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

// MARK: -PBXReferenceProxy

public class RefProxy :Base {
    override var isa:Isa? { return Isa.refProxy }
    
    var path:String=""
    var fileType:Explicit
    var remoteRef:Proxy
    var sourceTree:PathBase
    
    init(path:String,ref:Proxy,type:Explicit,tree:PathBase) {
        self.path = path
        self.fileType = type
        self.remoteRef = ref
        self.sourceTree = tree
    }
}

// MARK: -PBXBuildRule
// FIXME: -
public class BuildRules :Base {
    override var isa:Isa? { return Isa.rules }
    
    var compilerSpec:String = ""
    var filePatterns:String?
    var fileType:String = ""
    var isEditable:String = "1"
    var outputFiles:[String] = [String]()
    var script:String = "# builtin-copyPlist\n"
}






