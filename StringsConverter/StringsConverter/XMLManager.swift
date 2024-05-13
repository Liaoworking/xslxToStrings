//
//  XMLManager.swift
//  StringsConverter
//
//  Created by liao on 2024/5/13.
//

import Foundation
class XMLManager {
        
    static func analysisXMLFile(at urlString: String) -> Void {
        debugPrint("获取到的文件地址",urlString)
        let data = try! Data(contentsOf: URL(filePath: urlString))
        let delegate = XMLStringParser()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        print(delegate.results)  // 打印解析的结果
        
        var keyContent = ""
        var enContent = ""
        
        for item in delegate.results {
            keyContent.append("\n\(item.name)")
            enContent.append("\n\(item.value)")
        }

        keyContent = keyContent.trimmingCharacters(in: .whitespacesAndNewlines)
        enContent = enContent.trimmingCharacters(in: .whitespacesAndNewlines)

        XSLXManager.creatFolder(of: String.Path.xmlDoc)
        
        let keyFileURL = URL(filePath: String.Path.xmlDoc + "/key.txt")
        try! keyContent.trimmingCharacters(in: .whitespacesAndNewlines).write(to: keyFileURL, atomically: true, encoding:.utf8)
        
        let enFileURL = URL(filePath: String.Path.xmlDoc + "/en.txt")
        try! enContent.trimmingCharacters(in: .whitespacesAndNewlines).write(to: enFileURL, atomically: true, encoding:.utf8)
        DispatchQueue.main.async {
            XMLManager.exprotFile()
        }
    }
    
    /// 导出要错词或者已收藏的单词
    static func exprotFile() {
        guard let keywindow = XSLXManager.showWindow else { return }
        let pannel = NSSavePanel()
        XSLXManager.pannel = pannel
        pannel.nameFieldLabel = "🍃"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M_d"
        
        pannel.nameFieldStringValue = "xml_output_\(formatter.string(from: Date()))"
        pannel.message = "choose your xml path"
        pannel.allowsOtherFileTypes = true
        pannel.isExtensionHidden = false
        pannel.canCreateDirectories = true
        pannel.beginSheetModal(for: keywindow) { (response) in
            if !(pannel.url?.path.isEmpty ?? true) && response == .OK {
                do {
                    try FileManager.default.copyItem(at: URL(filePath: String.Path.xmlDoc), to: URL(fileURLWithPath: (pannel.url?.path)!))
                } catch {}
            }
        }
    }
}


struct XMLStringElement {
    let name: String
    let value: String
}


class XMLStringParser: NSObject, XMLParserDelegate {

    var results = [XMLStringElement]()
    var currentElement: String?
    var currentAttributes: [String: String]?
    var currentText = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentAttributes = attributeDict
        currentText = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let name = currentAttributes?["name"], currentElement == "string" {
            results.append(XMLStringElement(name: name, value: currentText.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
    }

}
