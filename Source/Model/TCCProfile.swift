//
//  TCCProfile.swift
//  PPPC Utility
//
//  MIT License
//
//  Copyright (c) 2018 Jamf Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

typealias TCCPolicyIdentifierType = String

extension TCCPolicyIdentifierType {
    static let bundleID = "bundleID"
    static let path = "path"
}

struct TCCPolicy : Codable {
    var comment: String
    var identifier: String
    var identifierType: TCCPolicyIdentifierType
    var codeRequirement: String
    var allowed: Bool
    var receiverIdentifier: String?
    var receiverIdentifierType: TCCPolicyIdentifierType?
    var receiverCodeRequirement: String?
    enum CodingKeys: String, CodingKey {
        case identifier = "Identifier"
        case identifierType = "IdentifierType"
        case allowed = "Allowed"
        case codeRequirement = "CodeRequirement"
        case comment = "Comment"
        case receiverIdentifier = "AEReceiverIdentifier"
        case receiverIdentifierType = "AEReceiverIdentifierType"
        case receiverCodeRequirement = "AEReceiverCodeRequirement"
    }
    init(identifier: String, codeRequirement: String, allowed: Bool, receiverIdentifier: String? = nil, receiverCodeRequirement: String? = nil) {
        self.allowed = allowed
        self.comment = ""
        self.identifier = identifier
        self.identifierType = identifier.contains("/") ? .path : .bundleID
        self.codeRequirement = codeRequirement
        self.receiverIdentifier = receiverIdentifier
        if let otherIdentifier = receiverIdentifier {
            self.receiverIdentifierType = otherIdentifier.contains("/") ? .path : .bundleID
        }
        self.receiverCodeRequirement = receiverCodeRequirement
    }
}

struct TCCServices : Codable {
    var addressBook: [TCCPolicy]?
    var calendar: [TCCPolicy]?
    var reminders: [TCCPolicy]?
    var photos: [TCCPolicy]?
    var camera: [TCCPolicy]?
    var microphone: [TCCPolicy]?
    var accessibility: [TCCPolicy]?
    var postEvent: [TCCPolicy]?
    var allFiles: [TCCPolicy]?
    var adminFiles: [TCCPolicy]?
    var fileProviderPresence: [TCCPolicy]?
    var listenEvent: [TCCPolicy]?
    var mediaLibrary: [TCCPolicy]?
    var screenCapture: [TCCPolicy]?
    var speechRecognition: [TCCPolicy]?
    var desktopFolder: [TCCPolicy]?
    var documentsFolder: [TCCPolicy]?
    var downloadsFolder: [TCCPolicy]?
    var networkVolumes: [TCCPolicy]?
    var removableVolumes: [TCCPolicy]?
    var appleEvents: [TCCPolicy]?
    enum CodingKeys: String, CodingKey {
        case addressBook = "AddressBook"
        case calendar = "Calendar"
        case reminders = "Reminders"
        case photos = "Photos"
        case camera = "Camera"
        case microphone = "Microphone"
        case accessibility = "Accessibility"
        case postEvent = "PostEvent"
        case allFiles = "SystemPolicyAllFiles"
        case adminFiles = "SystemPolicySysAdminFiles"
        case fileProviderPresence = "FileProviderPresence"
        case listenEvent = "ListenEvent"
        case mediaLibrary = "MediaLibrary"
        case screenCapture = "ScreenCapture"
        case speechRecognition = "SpeechRecognition"
        case desktopFolder = "SystemPolicyDesktopFolder"
        case documentsFolder = "SystemPolicyDocumentsFolder"
        case downloadsFolder = "SystemPolicyDownloadsFolder"
        case networkVolumes = "SystemPolicyNetworkVolumes"
        case removableVolumes = "SystemPolicyRemovableVolumes"
        case appleEvents = "AppleEvents"
    }
}

struct TCCProfile : Codable {
    struct Content: Codable {
        var payloadDescription: String
        var displayName: String
        var identifier: String
        var organization: String
        var type: String
        var uuid: String
        var version: Int
        var services: TCCServices
        enum CodingKeys: String, CodingKey {
            case payloadDescription = "PayloadDescription"
            case displayName = "PayloadDisplayName"
            case identifier = "PayloadIdentifier"
            case organization = "PayloadOrganization"
            case type = "PayloadType"
            case uuid = "PayloadUUID"
            case version = "PayloadVersion"
            case services = "Services"
        }
    }
    
    var version: Int
    var uuid: String
    var type: String
    var scope: String
    var organization: String
    var identifier: String
    var displayName: String
    var payloadDescription: String
    var content: [Content]
    enum CodingKeys: String, CodingKey {
        case payloadDescription = "PayloadDescription"
        case displayName = "PayloadDisplayName"
        case identifier = "PayloadIdentifier"
        case organization = "PayloadOrganization"
        case scope = "payloadScope"
        case type = "PayloadType"
        case uuid = "PayloadUUID"
        case version = "PayloadVersion"
        case content = "PayloadContent"
    }
    init(organization: String, identifier: String, displayName: String, payloadDescription: String, services: TCCServices) {
        let content = Content(payloadDescription: payloadDescription,
                              displayName: displayName,
                              identifier: identifier,
                              organization: organization,
                              type: "com.apple.TCC.configuration-profile-policy",
                              uuid: UUID().uuidString,
                              version: 1,
                              services: services)
        self.version = 1
        self.uuid = UUID().uuidString
        self.type = content.type
        self.scope = "system"
        self.organization = content.organization
        self.identifier = content.identifier
        self.displayName = content.displayName
        self.payloadDescription = content.payloadDescription
        self.content = [content]
    }
    
    func xmlData() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return try encoder.encode(self)
    }
}
