//
//  XSLXManager.swift
//  StringsConverter
//
//  Created by liao on 2024/4/30.
//

import Foundation

class XSLXManager {
    
    static var pannel: NSSavePanel?
    
    static var showWindow: NSWindow?
    
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
                    countryDataDict[cell.columnIndex()] = CountryInfoModel(countryCode: cellContent)
                } else {
                    // 剩下的行
                    if cell.columnIndex() == 1 {
                        // 第一列是key
                        currentKey = cellContent
                    } else {
                        if let countryModel = countryDataDict[cell.columnIndex()], !currentKey.isEmpty {
                            // 后面的是对应的国家的信息
                            countryModel.iOSContent.append("\n\"\(currentKey)\"=\"\(cellContent)\";")
                            countryModel.androidContent.append("\n  <string name=\"\(currentKey)\"><![CDATA[\"\(cellContent)\"]]></string>")
                        }
                    }
                }
            }
        }
        let countries = countryDataDict.values.compactMap({$0})
        countries.forEach { countryModel in
            if !countryModel.androidContent.isEmpty {
                countryModel.androidContent = "<resources>" + countryModel.androidContent + "\n</resources>"
            }
        }
        
        saveCountryInfosToDesktop(of: countries)
        DispatchQueue.main.async {
            self.exprotFile()
        }
    }
    
    static func saveCountryInfosToDesktop(of countries: [CountryInfoModel]) {
        // 先创建result文件夹
        creatFolder(of: String.Path.resultDoc)
        creatFolder(of: String.Path.resultiOSDoc)
        creatFolder(of: String.Path.resultAndroidDoc)
        creatIOSStrings(of: countries)
        creatAndroidStrings(of: countries)
    }
    
    
    /// 创建iOS Strings 文件
    /// - Parameter contries: 国家
    static func creatIOSStrings(of countries: [CountryInfoModel]) {
        for country in countries {
            // 先创建文件夹
            let countryDocument = String.Path.resultiOSDoc + "/\(country.countryCode).lproj"
            creatFolder(of: countryDocument)
            //再到country文件夹下创建strings文件
            let stringsURL = URL(filePath: countryDocument + "/Localizable.strings")
            try! country.iOSContent.trimmingCharacters(in: .whitespacesAndNewlines).write(to: stringsURL, atomically: true, encoding:.utf8)
        }
    }
    
    /// 创建Android Strings 文件
    /// - Parameter contries: 国家
    static func creatAndroidStrings(of countries: [CountryInfoModel]) {
        for country in countries where androidCountryFoldNameDict[country.countryCode] != nil {
            // 先创建文件夹
            let countryDocument = String.Path.resultAndroidDoc + "/" + (androidCountryFoldNameDict[country.countryCode] ?? "")
            creatFolder(of: countryDocument)
            //再到country文件夹下创建strings文件
            let stringsURL = URL(filePath: countryDocument + "/strings.xml")
            try! country.androidContent.trimmingCharacters(in: .whitespacesAndNewlines).write(to: stringsURL, atomically: true, encoding:.utf8)
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
        guard let keywindow = showWindow else { return }
        let pannel = NSSavePanel()
        XSLXManager.pannel = pannel
        pannel.nameFieldLabel = "🍃"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M_d"
        
        pannel.nameFieldStringValue = "output_\(formatter.string(from: Date()))"
        pannel.message = "choose your save path"
        pannel.allowsOtherFileTypes = true
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
        
        static var resultiOSDoc: String {
            return resultDoc.appending("/iOS")
        }
        
        static var resultAndroidDoc: String {
            return resultDoc.appending("/Android")
        }
        
    }
}

let androidCountryFoldNameDict: [String: String] = [
    "zh-CN": "values-zh-rCN",
    "zh-TW": "values-zh-rTW",
    "en-US": "values-en-rUS",
    "es-MX": "values-es-rMX",
    "ja-JP": "values-ja-rJP",
    "ko-KR": "values-ko-rKR",
    "ru-RU": "values-ru-rRU",
    "fr-FR": "values-fr-rFR",
    "de-DE": "values-de-rDE",
    "pt-BR": "values-pt-rBR",
    "ar-SA": "values-ar-rSA",
    "he-IL": "values-he-rIL",
    "iw-IL": "values-iw-rIL",
    "hi-IN": "values-hi-rIN",
    "uk-UA": "values-uk-rUA",
    "th-TH": "values-th-rTH",
    "id-ID": "values-id-rID",
    "in-ID": "values-in-rID",
    "it-IT": "values-it-rIT",
    "bg-BG": "values-bg-rBG",
    "tr-TR": "values-tr-rTR",
    "pl-PL": "values-pl-rPL",
    // 适配iOS端手动加的几个
    "en": "values-en-rUS",
    "de": "values-de-rDE",
    "uk": "values-de-rDE",
    "zh-Hant": "values-zh-rCN",
]
