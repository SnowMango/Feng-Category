//
//  main.swift
//  AppIcon
//
//  Created by zhengfeng on 2018/2/7.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

import Foundation
import CoreGraphics

print("Hello, World!")


func prase_info(contents json:Dictionary<String, String>) -> Bool{
    
    return true
}

func checkResource(_ path:String) -> Bool
{
    return path.hasSuffix("png")
}

func checkSource(_ path:String) -> Bool
{
    return path.hasSuffix("json") || path.hasSuffix("appiconset")
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
        let url:URL = URL.init(string: rPath)!;
        let source:CGImageSource = CGImageSourceCreateWithURL(url as CFURL, nil)!
        return CGImageSourceCreateImageAtIndex(source , 0, nil)
    }
    return nil;
}


func parseSource(path sPath:String) -> Array<Any>?  {
    
    let jsonData:Data = try! Data.init(contentsOf: URL.init(fileURLWithPath: sPath), options: Data.ReadingOptions.mappedIfSafe);
    
    let parse:Dictionary = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! Dictionary<String, Any>
    let ret:Array? = parse["images"] as? Array<Any>
    return ret
}

func createImage(resImage:CGImage, size:CGSize, radius:Float) -> CGImage {
    let colorSpace:CGColorSpace = resImage.colorSpace!
    let bitsPer:size_t = resImage.bitsPerComponent
    let bitmapInfo:CGBitmapInfo =
        CGBitmapInfo(rawValue:CGBitmapInfo.byteOrderMask.rawValue |
        CGImageAlphaInfo.premultipliedLast.rawValue )
    let bitmap:CGContext? = CGContext.init(data: nil,
                                          width: Int(size.width),
                                          height: Int(size.height),
                                          bitsPerComponent: bitsPer,
                                          bytesPerRow: Int(4*size.width),
                                          space: colorSpace,
                                          bitmapInfo: bitmapInfo.rawValue)
    var retImage:CGImage = resImage.copy()!
    if bitmap != nil {
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        bitmap?.draw(resImage, in: rect)
        retImage = bitmap!.makeImage()!
    }
    return retImage
}

func parseItem(item:Dictionary<String,String>) -> (fileName:String,size:CGSize) {
    let idiom:String = item["idiom"]!
    var scaleStr:String = item["scale"]!
    scaleStr.removeLast()
    let scale:Int = Int(scaleStr)!
    let sizeArray:Array<String> = item["size"]!.components(separatedBy: "x")
    
    let size:CGSize = CGSize.init(width: Int(sizeArray.first!)!*scale, height: Int(sizeArray.last!)!*scale)
    var suffix:String = ".png"
    if scale > 1 {
        suffix = "@\(scale)x.png"
    }
    let fileName:String =  "\(idiom)(\(item["size"]!))\(suffix)"
    return (fileName,size)
}

func readArg(_ args:Array<String>) -> Bool {
    let resourcePath:String = args[1]
    let sourcePath:String   = args[2]
    let destinationPath:String = args[3]

    print("resource path: \(checkResource(resourcePath))")
    print("source path: \(checkSource(sourcePath))")
    print("destination path: \(checkDestination(destinationPath))")
    
    let arr = parseSource(path: sourcePath)
    print(arr ?? "def")
    
    let result:(String, CGSize) = parseItem(item: arr?.first as! Dictionary<String,String>)
    
    print("name = \(result.0) size=\(NSStringFromSize(result.1))")
    return true
}

if CommandLine.arguments.count > 3{
    print(readArg(CommandLine.arguments))
}

func testParseItem() -> Bool {
    let item:Dictionary = ["idiom":"mac",
                           "scale":"2x",
                           "size":"512x512"]
    
    let result:(String, CGSize) = parseItem(item: item)
    print("name = \(result.0) size=\(NSStringFromSize(result.1))")
    return true
}







