//
//  DocumentPicker.swift
//  Starlen
//
//  Created by Pedro Augusto on 08/04/26.
//

import UIKit
import CoreServices
import UniformTypeIdentifiers

public enum SourceType: Int {
    case files
    case folder
}

open class DocumentPicker: NSObject {
    
    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: DocumentDelegate?
    private var folderURL: URL?
    private var sourceType: SourceType!
    private var documents = [Document]()
    
    init(presentationController: UIViewController,
         delegate:   DocumentDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    
    public func present(from sourceView: UIView) {
        let alertController = UIAlertController(title: "Select From",message: nil, preferredStyle: .actionSheet)
        if let action = self.fileAction(for: .files, title: "Files") {
            alertController.addAction(action)
        }
        if let action = self.folderAction(for: .folder, title:
                                            "Folder") {
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title:
                                                    "Cancel", style: .cancel, handler: nil))
        self.presentationController?.present(alertController,
                                             animated: true)
    }
    
    
    public func folderAction(for type: SourceType,
                             title: String) -> UIAlertAction? {
        return UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let self else { return }
            self.pickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder])
            self.pickerController!.delegate = self
            self.sourceType = type
            self.presentationController?.present(self.pickerController!,
                                                 animated: true)
        }
    }
    public func fileAction(for type: SourceType,
                           title: String) -> UIAlertAction? {
        return UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let self else { return }
            self.pickerController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.personType])
            self.pickerController!.delegate = self
            self.pickerController!.allowsMultipleSelection = false
            self.sourceType = type
            self.presentationController?.present(self.pickerController!,
                                                 animated: true)
        }
    }
    
    
    private func documentFromURL(pickedURL: URL) {
        let shouldStopAccessing =
        pickedURL.startAccessingSecurityScopedResource()
        
        if shouldStopAccessing {
            pickedURL.stopAccessingSecurityScopedResource()
        }
        
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error:
                                        NSErrorPointer.none) { (folderURL) in
            let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
            let fileList = FileManager.default.enumerator(at:
                                                            pickedURL, includingPropertiesForKeys: keys)
            switch sourceType {
            case .files:
                let document = Document(fileURL: pickedURL)
                documents.append(document)
            case .folder:
                for case let fileURL as URL in fileList! {
                    if !fileURL.isDirectory {
                        let document = Document(fileURL: fileURL)
                        documents.append(document)
                    }
                }
            case .none: break
            }
        }
    }
}


extension DocumentPicker: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickerDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        documentFromURL(pickedURL: url)
        delegate?.didPickDocuments(documents: documents)
    }
    public func documentPicker (_ controller: UIDocumentPickerViewController) {
        delegate?.didPickDocuments(documents: nil)
    }
}
