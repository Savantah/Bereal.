import Foundation
import ParseSwift

struct Post: ParseObject {
    
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    
    var caption: String?
    var imageFile: ParseFile?
    var user: Pointer<User>?
}


extension Post {
    init(caption: String, imageFile: ParseFile, user: User) {
        self.caption = caption
        self.imageFile = imageFile
        self.user = try? user.toPointer()
    }
}
