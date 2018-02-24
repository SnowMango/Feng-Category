//
//  main.swift
//  AppIcon
//
//  Created by zhengfeng on 2018/2/7.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

import Foundation
import CoreGraphics
import AppKit

func checkResource(_ path:String) -> Bool
{
    var ret:Bool = path.hasSuffix("png")
    if ret {
        ret = FileManager.default.fileExists(atPath: path)
    }
    return ret
}

func checkSource(_ path:String) -> Bool
{
    var checkPath = path
    if checkPath.hasSuffix("appiconset") {
        checkPath = checkPath.appending("/Contents.json")
    }
    var ret:Bool = checkPath.hasSuffix("json")
    if ret {
        ret = FileManager.default.fileExists(atPath: checkPath)
    }
    return ret
}

func checkDestination(_ path:String) -> Bool
{
    var ret:Bool = !path.hasSuffix("appiconset")

    if ret {
        
        var dir:ObjCBool = ObjCBool.init(ret);
        
        ret = FileManager.default.fileExists(atPath: path, isDirectory: &dir)

        if !dir.boolValue && ret {
            ret = false
        }
    }
    return ret
}

func parseResource(path rPath:String)-> CGImage?
{
    if FileManager.default.fileExists(atPath: rPath) {
        let url:URL = URL.init(fileURLWithPath: rPath);
        let source:CGImageSource = CGImageSourceCreateWithURL(url as CFURL, nil)!
        return CGImageSourceCreateImageAtIndex(source , 0, nil)
    }
    return nil;
}


func parseSource(path sPath:String) -> Array<Any>?  {
    
    var jsonPath:String = sPath
    
    if jsonPath.hasSuffix("appiconset") {
        jsonPath = jsonPath.appending("/Contents.json")
    }
    let jsonData:Data = try! Data.init(contentsOf: URL.init(fileURLWithPath: jsonPath), options:.mappedIfSafe);
    
    let parse:Dictionary = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Dictionary<String, Any>
    let ret:Array? = parse["images"] as? Array<Any>
    return ret
}

func createImage(resImage:CGImage, size:CGSize, radius:Float) -> CGImage? {
    let colorSpace:CGColorSpace = resImage.colorSpace!
    let bitsPer:size_t = resImage.bitsPerComponent
    let bitmap:CGContext? = CGContext.init(data: nil,
                                          width: Int(size.width),
                                          height: Int(size.height),
                                          bitsPerComponent: bitsPer,
                                          bytesPerRow: Int(4*size.width),
                                          space: colorSpace,
                                          bitmapInfo: 1)
    let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
    if radius > 0 {
        drawRadius(bitmap!, rect: rect, radius: radius)
    }
    bitmap?.draw(resImage, in: rect)
    return bitmap?.makeImage()
}

func drawRadius(_ context:CGContext , rect:CGRect, radius:Float) {
    let x = rect.origin.x
    let y = rect.origin.y
    let w = rect.size.width
    let h = rect.size.height
    let r = CGFloat.init(radius)
    context.saveGState()
    
    context.move(to: CGPoint.init(x: x, y: y+r))
    //右上角
    context.addArc(tangent1End: CGPoint.init(x: x + w, y: y), tangent2End: CGPoint.init(x: x+w, y: y+r), radius: r)
    //右下角
    context.addArc(tangent1End: CGPoint.init(x: x + w, y: y+h), tangent2End: CGPoint.init(x: x+w-r, y: y+h), radius: r)
    //左下角
    context.addArc(tangent1End: CGPoint.init(x: x, y: y+h), tangent2End: CGPoint.init(x: x, y: y+h - r ), radius: r)
    //左上角
    context.addArc(tangent1End: CGPoint.init(x: x, y: y), tangent2End: CGPoint.init(x: x+r, y: y), radius: r)
    
    context.drawPath(using: .fillStroke)
    context.restoreGState()
    if !context.isPathEmpty {
        context.clip()
    }else{
        print("empty")
    }
    
}

func parseItem(item:Dictionary<String,String>) -> (fileName:String,size:CGSize) {
    let idiom:String = item["idiom"]!
    var scaleStr:String = item["scale"]!
    scaleStr.removeLast()
    let scale:Int = Int(scaleStr)!
    let sizeArray:Array<String> = item["size"]!.components(separatedBy: "x")
    
    let size:CGSize = CGSize.init(width: Double(sizeArray.first!)!*Double(scale), height: Double(sizeArray.last!)!*Double(scale))
    var suffix:String = ".png"
    if scale > 1 {
        suffix = "@\(scale)x.png"
    }
    let fileName:String =  "\(idiom)(\(item["size"]!))\(suffix)"
    return (fileName,size)
}

func startParse(resPath:String, souPath:String ,desPath:String)
{
    print("resource path: \(checkResource(resPath))")
    print("source path: \(checkSource(souPath))")
    print("destination path: \(checkDestination(desPath))")
    
    if !checkResource(resPath) {
        print("Resource Path is invalid")
        return
    }
    if !checkSource(souPath) {
        print("Source Path is invalid")
        return
    }
    if !checkDestination(desPath) {
        print("Destination Path is invalid{\(desPath)}")
        return
    }
    
    let resImage:CGImage? = parseResource(path: resPath)
    if resImage == nil{
        return
    }
    let source:Array? = parseSource(path: souPath)
    guard source != nil else {
        return
    }
    let resultPath:String = "\(desPath)/App Icon"
    
    if !FileManager.default.fileExists(atPath: resultPath) {
        try!FileManager.default.createDirectory(at:
            URL.init(fileURLWithPath: resultPath),
                                                withIntermediateDirectories: true,
                                                attributes: nil)
    }
    let json:Data = FileManager.default.contents(atPath: resPath)!
    
    FileManager.default.createFile(atPath: resultPath.appending("/Content.json"), contents: json, attributes: nil)
    for item in source! {
        let i = item as! Dictionary<String,String>
        let info:(String, CGSize) = parseItem(item: i)
        let image:CGImage? = createImage(resImage: resImage!,
                                        size: info.1,
                                        radius: Float.init(info.1.width/2.0))

        if image == nil{
            continue
        }
        let saveImage:NSImage = NSImage.init(cgImage: image!, size: info.1);
        let savePath:String = "\(resultPath)/\(info.0)"
        try! saveImage.tiffRepresentation?.write(to: URL.init(fileURLWithPath: savePath))
    }
}

func runCommand(launchPath: String, arguments: [String]) -> String {
    let pipe = Pipe()
    let file = pipe.fileHandleForReading
    
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = pipe
    task.launch()
    
    let data = file.readDataToEndOfFile()
    return String(data: data, encoding:.utf8)!
}

func showCommandIntroduction()->String
{
    return "this is a test command"
}

func absolutePath(_ path:String) ->Bool
{
    return path.hasPrefix("/")
}

func run()
{
    let pwd:String = runCommand(launchPath: "/bin/pwd", arguments: [])
    let count:Int = CommandLine.arguments.count
    let args:Array = CommandLine.arguments
    
    var resourcePath:String
    var sourcePath:String
    var destinationPath:String
    
    if count == 2{
        resourcePath = args[1]
        sourcePath = pwd.appending("/Content.json")
        destinationPath = pwd
        startParse(resPath: resourcePath,
                   souPath: sourcePath,
                   desPath: destinationPath)
    }else if count == 3{
        resourcePath = args[1]
        sourcePath = args[2]
        destinationPath = pwd
        startParse(resPath: resourcePath,
                   souPath: sourcePath,
                   desPath: destinationPath)
    }else if count == 4{
        resourcePath = args[1]
        sourcePath = args[2]
        destinationPath = args[3]
        startParse(resPath: resourcePath,
                   souPath: sourcePath,
                   desPath: destinationPath)
    }else{
        print(showCommandIntroduction())
    }
}

func testParseItem() -> Bool {
    let item:Dictionary = ["idiom":"mac",
                           "scale":"2x",
                           "size":"512x512"]
    
    let result:(String, CGSize) = parseItem(item: item)
    print("name = \(result.0) size=\(NSStringFromSize(result.1))")
    return true
}
func test()
{
    let resourcePath = "/Users/zhengfeng/Desktop/feng1024.png"
    let sourcePath = "/Users/zhengfeng/Desktop/GitHub/Yang/yang/Assets.xcassets/AppIcon.appiconset/Contents.json"
    let destinationPath = "/Users/zhengfeng/Desktop/save"
    startParse(resPath: resourcePath,
               souPath: sourcePath,
               desPath: destinationPath)
}
//run()


test()












