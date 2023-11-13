//
//  readCSVFile.swift
//  Live-Tracking_App
//
//  Created by Donghan Hu on 11/7/23.
//

import Foundation


class readCSVFile {
    func readCSVFile(filePath : String) -> Array<Array<String>>{
        let contentsOfFilePath = Bundle.main.path(forResource: filePath, ofType: "csv") ?? ""
        if (contentsOfFilePath == ""){
            print("the content of this file is empty, the file path is: " + filePath)
        }
        var fileContents = try! String(contentsOfFile: contentsOfFilePath, encoding: .utf8)
        // remove empty rows
        fileContents = cleanRows(file: fileContents)
        let resultArray = csvTransfer(data: fileContents)
        // type: Array<Array<String>>
        // print(type(of: afterTransfer))
        // print(afterTransfer)
        
        return resultArray

    }
    
    // clean rows, replace \r and \n\n with a new line
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    // transfer a string to a string array
    func csvTransfer(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            // print(row)
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    
    func readCSVFileToGlobalDicrionary(fileName : String) {
        let csvContent = readCSVFile(filePath: "applescript")
        //let csvContent = readCSVFile(filePath: fileName)
        let csvContentRow = csvContent.count
        // [0] : application name
        // [1] : metadata 1
        // [2] : metadata 2
        // ? add category later?
        for row in csvContent {
            if(row.count >= 3){
                // print(row)
                let applicationName = row[0]
                let appleScript1 = row[1]
                let appleScript2 = row[2]
                appleScriptDicrionary[applicationName] = [String]()
                appleScriptDicrionary[applicationName]!.append(appleScript1)
                appleScriptDicrionary[applicationName]!.append(appleScript2)
            }

        }
        // print(appleScriptDicrionary)
    }
}
