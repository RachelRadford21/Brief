//
//  DataProcessing.swift
//  Brief
//
//  Created by Rachel Radford on 2/13/25.
//

import Foundation
import TabularData

struct DataProcessor {
    let fileName = "train_sample"

    func loadCSV() {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            print("Error: CSV file not found")
            return
        }

        let options = CSVReadingOptions(hasHeaderRow: true)
    

        do {
            var table = try DataFrame(contentsOfCSVFile: fileURL, options: options)
            checkForMissingValues(in: table)
            table = removeDuplicates(from: table)
           
            print("CSV Loaded Successfully: \(table.rows.count) rows")
        
            print(table.prefix(5))
            
        } catch {
            print("Error loading CSV: \(error)")
        }
    }
    
    func checkForMissingValues(in table: DataFrame) {
        let missingArticles = table.filter(on: "article", String.self) { $0?.isEmpty == true }
        let missingSummaries = table.filter(on: "highlights", String.self) { $0?.isEmpty == true }

        print("Missing Articles: \(missingArticles.rows.count)")
        print("Missing Summaries: \(missingSummaries.rows.count)")
    }

    func removeDuplicates(from table: DataFrame) -> DataFrame {
        var seenArticles = Set<String>()
        var uniqueRows: [[Any]] = []

    
        guard let articleColumnIndex = table.columns.map(\.name).firstIndex(of: "article") else {
            print("Error: 'article' column not found")
           
            return table
        }

        for row in table.rows {
            if let article = row[articleColumnIndex] as? String, !seenArticles.contains(article) {
                seenArticles.insert(article)
                uniqueRows.append(row.map { $0 ?? "" })
            }
        }

        var cleanedColumns = DataFrame()
        
        for columnIndex in table.columns.indices {
            let columnName = table.columns[columnIndex].name
            let columnValues: [Any] = uniqueRows.map { $0[columnIndex] }
            cleanedColumns.append(column: Column(name: columnName, contents: columnValues))
        }
      
        print("Article column : \(cleanedColumns)")
        return cleanedColumns
    }
}
