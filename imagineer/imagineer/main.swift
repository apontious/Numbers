//
//  main.swift
//  imagineer http://github.com/apontious/Numbers
//
//  Created by Andrew Pontious on 7/24/18.
//  Copyright © 2018 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//
//  Project to automatically generate icon files and JSON files needed by the Numbers project.

import AppKit

let kCount = 500
let kColorCycleInterval = 50
let localFilePath = NSString(string: "~/Documents/Numbers").resolvingSymlinksInPath // <--- change this to your own directory. Folder (and Icons folder within it) must exist for this to succeed
let repositoryPartialPath = "apontious/Numbers/master/Icons" // <--- point to your own repository, if forking the Numbers repository

let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
paragraphStyle.alignment = .center

let font = NSFont(name: "Impact", size: 70.0)!

var jsonString = "[\n"

let formatter = NumberFormatter()
formatter.numberStyle = .spellOut

var i = 1

while i <= kCount {
    let color = NSColor(hue:CGFloat(i % kColorCycleInterval) / CGFloat(kColorCycleInterval), saturation:1.0, brightness:1.0, alpha:1.0)

    let rect = NSRect(x: 0.0, y: 0.0, width: 126.0, height: 126.0)
    let image = NSImage(size:rect.size)

    image.lockFocus()
    NSColor.white.setFill()
    rect.fill()

    let string: NSString = NSString(string: "\(i)")

    string.draw(in: rect, withAttributes: [.paragraphStyle: paragraphStyle,
                                           .font: font,
                                           .foregroundColor: color])

    image.unlockFocus()

    let imageData = image.tiffRepresentation!
    let imageRep = NSBitmapImageRep(data: imageData)!
    let pngData: Data = imageRep.representation(using: .png, properties: [.compressionFactor: 1.0])!
    try pngData.write(to: URL(fileURLWithPath: "\(localFilePath)/Icons/\(i).png"))

    let title = NSString(string:formatter.string(from: NSNumber(value:i))!).capitalized

    jsonString.append("  {\n    \"name\" : \"\(title)\",\n    \"url\" : \"https://raw.githubusercontent.com/\(repositoryPartialPath)/\(i).png\"\n  }")

    if i < kCount {
        jsonString.append(",\n")
    } else {
        jsonString.append("\n")
    }

    i = i + 1
}

jsonString.append("]\n")

try jsonString.write(toFile: "\(localFilePath)/list.json", atomically: true, encoding: .utf8)
