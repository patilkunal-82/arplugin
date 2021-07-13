import Foundation
import Contacts


@objc(ArPlugin) class ArPlugin : CDVPlugin {

    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

    //This method is called when the plugin is initialized; plugin setup methods got here
    override func pluginInitialize() {
    }

    @objc(add:) func add(_ command: CDVInvokedUrlCommand) {

        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        let param1 = (command.arguments[0] as? NSObject)?.value(forKey: "param1") as? Int
        let param2 = (command.arguments[0] as? NSObject)?.value(forKey: "param2") as? Int

        if let p1 = param1 , let p2 = param2 {

            if p1 >= 0 && p1 >= 0 {

                let total = String(p1 + p2)
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: total)
            } else {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Something wrong")
            }
        }

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(getContacts:) func getContacts(_ command CDVInvokedUrlCommand) {

          var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
          let value = command.getString("filter") ?? ""
          let contactStore = CNContactStore();
          var contacts = [Any]()
          let keys = [
              CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
              CNContactPhoneNumbersKey, CNContactEmailAddressesKey
          ] as [Any]

           let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
           contactStore.requestAccess(for: .contacts) { (granted, error) in

            if let error = error {
                print("failed to request access", error)
                command.reject("aaccess denied")
                return
            }

            if granted {
                do {

                    try contactStore.enumerateContacts(with: request) {
                               (contact, stop) in
                        contacts.append([
                            "firstName": contact.givenName,
                            "lastName": contact.familyName,
                            "telephone": contact.phoneNumbers.first?.value.stringValue ?? ""
                        ])
                       }
                       print(contacts)
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: contacts)
                       command.success([
                           "results": contacts
                       ])
                      

                } catch {
                       print("unable to fetch contacts")
                       pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Something wrong")
                       command.reject("Unable to fetch contacts")
                       
                }

            } else {
                    print("access denied")
                      pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Something wrong")
                    command.reject("access denied")
                  
            }


           }

           self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)

    }

}

/* 
@objc(ContactPluginPlugin)
public class ContactPluginPlugin: CAPPlugin {
    private let implementation = ContactPlugin()

    
    @objc func getContacts(_ call: CAPPluginCall) {
            
        let value = call.getString("filter") ?? ""
            // You could filter based on the value passed to the function!
            
            let contactStore = CNContactStore()
            var contacts = [Any]()
            let keys = [
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                            CNContactPhoneNumbersKey,
                            CNContactEmailAddressesKey
                    ] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
            
            contactStore.requestAccess(for: .contacts) { (granted, error) in
                if let error = error {
                    print("failed to request access", error)
                    call.reject("access denied")
                    return
                }
                if granted {
                   do {
                       try contactStore.enumerateContacts(with: request){
                               (contact, stop) in
                        contacts.append([
                            "firstName": contact.givenName,
                            "lastName": contact.familyName,
                            "telephone": contact.phoneNumbers.first?.value.stringValue ?? ""
                        ])
                       }
                       print(contacts)
                       call.success([
                           "results": contacts
                       ])
                   } catch {
                       print("unable to fetch contacts")
                       call.reject("Unable to fetch contacts")
                   }
                } else {
                    print("access denied")
                    call.reject("access denied")
                }
            }
        }
}
*/