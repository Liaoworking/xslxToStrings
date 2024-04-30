//
//  XSLXManager.swift
//  StringsConverter
//
//  Created by liao on 2024/4/30.
//

import Foundation

class XSLXManager {
    
    static var pannel: NSSavePanel?
    
    static func analysisXSLXFile(at urlString: String) -> Void {
                
        debugPrint("获取到的文件地址",urlString)
        // 存储国家数据的模型[columIndex: ContryInfo]  每一列是一个国际 通过 columIndex 获取到国家
        var countryDataDict:[Int: CountryInfoModel] = [:]
        
        // 谨记： contentsOfFile 不需要file:// 只要/user这种就行。。。
        let result = BRAOfficeDocumentPackage(contentsOfFile: urlString)
        let firstWorkSheet = result?.workbook?.worksheets.first as? BRAWorksheet
        
        let allCells = firstWorkSheet?.cells as? [BRACell]
        
        var currentKey = ""
        
        for cell in allCells ?? [] {
            let cellContent = cell.stringValue().trimmingCharacters(in: .whitespacesAndNewlines)
            debugPrint("\(cell.rowIndex())_______\(cell.columnIndex())_______\(cellContent)")
        }
        
        for cell in allCells ?? [] {
            let cellContent = cell.stringValue().trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cell.rowIndex() > 1 && !cellContent.isEmpty {
                
                if cell.rowIndex() == 2 && cell.columnIndex() > 1 {
                    // 读取第二行是国家信息
                    countryDataDict[cell.columnIndex()] = CountryInfoModel(countryCode: cellContent, content: "")
                } else {
                    // 剩下的行
                    if cell.columnIndex() == 1 {
                        // 第一列是key
                        currentKey = cellContent
                    } else {
                        if let countryModel = countryDataDict[cell.columnIndex()], !currentKey.isEmpty {
                            // 后面的是对应的国家的信息
                            countryModel.content.append("\n\"\(currentKey)\"=\"\(cellContent)\";")
                        }
                    }
                }
            }
        }
        let countries = countryDataDict.values.compactMap({$0})
        saveCountryInfosToDeskTop(of: countries)
        DispatchQueue.main.async {
            self.exprotFile()
        }
    }
    
    static func saveCountryInfosToDeskTop(of contries: [CountryInfoModel]) {
        // 先创建result文件夹
        creatFolder(of: String.Path.resultDoc)
        for country in contries {
            // 先创建文件夹
            let countryDocument = String.Path.resultDoc + "/\(country.countryCode).lproj"
            creatFolder(of: countryDocument)
            //再到country文件夹下创建strings文件
            let stringsURL = URL(filePath: countryDocument + "/Localizable.strings")
            try! country.content.trimmingCharacters(in: .whitespacesAndNewlines).write(to: stringsURL, atomically: true, encoding:.utf8)
        }
    }
    
    static func creatFolder(of filePath: String) {
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(at: URL(filePath: filePath))
            }
            try fileManager.createDirectory(at: URL(filePath: filePath), withIntermediateDirectories: false, attributes: nil)
        } catch {
            print("创建文件夹时出错: \(error.localizedDescription)")
        }
    }
    
    /// 导出要错词或者已收藏的单词
    static func exprotFile() {
        guard let keywindow = NSApplication.shared.keyWindow else { return }
        let pannel = NSSavePanel()
        XSLXManager.pannel = pannel
        pannel.nameFieldLabel = "🍃"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M_d"
        
        pannel.nameFieldStringValue = "output_\(formatter.string(from: Date()))"
        pannel.message = "choose your save path"
        pannel.allowsOtherFileTypes = true
//        pannel.allowedFileTypes = ["xlsx"]
        pannel.isExtensionHidden = false
        pannel.canCreateDirectories = true
        pannel.beginSheetModal(for: keywindow) { (response) in
            if !(pannel.url?.path.isEmpty ?? true) && response == .OK {
                do {
                    try FileManager.default.copyItem(at: URL(filePath: String.Path.resultDoc), to: URL(fileURLWithPath: (pannel.url?.path)!))
                } catch {}
            }
        }
    }
    
}

extension String {
    struct Path {
        static var defaultExcel: String {
            let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
            return docPath.appending("/default.xslx")
        }
        
        static var resultDoc: String {
            let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
            return docPath.appending("/result")
        }
        
    }
}
