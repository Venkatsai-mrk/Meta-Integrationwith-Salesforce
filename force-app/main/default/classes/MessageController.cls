public class MessageController {
 // This method fetches a list of WA_Message__c records.
    @AuraEnabled(cacheable=true)
    public static List<WAMessage__c> getMessages() {
        // Query the WA_Message__c object to retrieve the required fields.
        return [
            SELECT  Name,AgentName__c, BusinessPhoneNumber__c, MessageContent__c,
                   CreatedBy.Name, CustomerName__c, CustomerPhone__c,
                   Message_Sent_Time__c
            FROM WAMessage__c
            ORDER BY Message_Sent_Time__c DESC  // Get the most recent messages first.
            LIMIT 10  
        ];
    }
}