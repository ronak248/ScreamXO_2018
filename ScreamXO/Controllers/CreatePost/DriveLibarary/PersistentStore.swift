/*
* Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
* See LICENSE in the project root for license information.
*/

import UIKit

class PersistentStore {

    
    init() {
        if let archivedItems = NSKeyedUnarchiver.unarchiveObject(withFile: fileRecordsArchiveURL.path) as? [FileRecord] {
            fileRecords += archivedItems
        }
        else {
            fileRecords = [FileRecord]()
        }
    }
    
    // MARK: Sync Token
    let defaults = UserDefaults.standard
    
    var syncToken: String? {
        get {
            return defaults.object(forKey: "syncToken") as! String?
        }
        set(newSyncToken) {
            if let _ = newSyncToken {
                defaults.set(newSyncToken, forKey: "syncToken")
            }
            else {
                defaults.removeObject(forKey: "syncToken")
            }
        }
    }
   
    // MARK: File records
    var fileRecords = [FileRecord]()
    
    let fileRecordsArchiveURL: URL = {
        let documentsDirectories =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("fileRecords.archive")
    }()
    
    
    
    func processDeltaArrayForFoldeWithId(_ folderId:String, items: [DeltaItem]?) {
        
        for item:FileRecord in fileRecords {
            item.isNew = false;
        }
        
        if let nonNilItems = items {
            for item:DeltaItem in nonNilItems {
                if item.parentId == folderId {
                    if item.isDelete {
                        tryDeleteFile(item.fileId)
                    }
                    else {
                        tryCreateOrUpdateFile(item.fileId, fileName: item.fileName!, isFolder: item.isFolder, lastModified: item.lastModified)
                    }
                }
            }
        }
    }
    
    func tryDeleteFile(_ fileId: String) {
        
        for index in 0..<fileRecords.count {
            if fileRecords[index].fileId == fileId {
                fileRecords.remove(at: index)
            }
        }
        
    }
    
    func tryCreateOrUpdateFile(_ fileId: String, fileName: String, isFolder: Bool, lastModified: String) {

        // flag to indicate update 
        var updated = false
        
        for fileRecord: FileRecord in fileRecords {
            if fileRecord.fileId == fileId {
                updated = true
                fileRecord.fileName = fileName
                fileRecord.isNew = true
                fileRecord.dateModified = lastModified
            }
        }
        
        if updated == false {
            let newRecord = FileRecord(fileId: fileId, fileName: fileName, dateModified: lastModified, isNew: true, isFolder: isFolder)
            fileRecords.append(newRecord)
        }
    }
    
    func createRecord(_ record: FileRecord) {
        fileRecords.append(record)
    }
    
    // MARK: Reset
    func resetStorage() {
        self.syncToken = nil
        fileRecords.removeAll()
    }
    
    func saveFileRecordChanges() -> Bool {
        return NSKeyedArchiver.archiveRootObject(fileRecords, toFile: fileRecordsArchiveURL.path)
    }
   
}
