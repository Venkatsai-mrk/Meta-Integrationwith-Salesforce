public with sharing class WhatsAppLWCService {
    
    @AuraEnabled(cacheable=true)
    public static List<WAMessage__c> listAllMessages(String customerPhone){
        List<WAMessage__c> messages = new List<WAMessage__c>();
        messages = [SELECT Id, Name, MessageContent__c, Message_Type__c,Platform__c,CustomerPhone__c, CustomerName__c, AgentName__c, Outgoing__c, CreatedDate
                    FROM WAMessage__c
                    WHERE CustomerPhone__c =: customerPhone
                    Order By CreatedDate ASC
                   ];
        return messages;
    }
    
    @AuraEnabled
    public static WAMessage__c getSingleMessage(String recordId, String customerPhone){
        return [SELECT Id, Name, MessageContent__c, Message_Type__c,Platform__c,CustomerPhone__c, CustomerName__c, AgentName__c, Outgoing__c, CreatedDate
                FROM WAMessage__c
                WHERE Id =: recordId AND 
                CustomerPhone__c =: customerPhone
                Order By CreatedDate ASC
               ];
    }
    //sending Message to WhatsApp
    @AuraEnabled
    public static WAMessage__c sendTextMessage(String messageContent, String toPhone){
        WAMessage__c message = WhatsAppUtils.sendTextMessage(messageContent, toPhone);
        return [SELECT Id, Name, MessageContent__c, Message_Type__c,Platform__c, CustomerPhone__c,CustomerName__c, AgentName__c, Outgoing__c, CreatedDate
                FROM WAMessage__c
                WHERE Id =: message.Id
                Order By CreatedDate ASC
               ];
    }
    //sending Message to facebook
    @AuraEnabled
    public static WAMessage__c sendTextMessageToFaceBook(String messageContent, String toSenderId){
        WAMessage__c message = WhatsAppUtils.sendTextMessageToFaceBook(messageContent, toSenderId);
        system.debug('message'+message);
        return [SELECT Id, Name, MessageContent__c, Message_Type__c,Platform__c, CustomerPhone__c,CustomerName__c, AgentName__c, Outgoing__c, CreatedDate
                FROM WAMessage__c
                WHERE Id =: message.Id
                Order By CreatedDate ASC
               ];
    }
    //sending Message to instagram
     @AuraEnabled
    public static WAMessage__c sendTextMessageToInstagram(String messageContent, String toSenderId){
        WAMessage__c message = WhatsAppUtils.sendTextMessageToInstagram(messageContent, toSenderId);
        system.debug('message'+message);
        return [SELECT Id, Name, MessageContent__c, Message_Type__c,Platform__c, CustomerPhone__c,CustomerName__c, AgentName__c, Outgoing__c, CreatedDate
                FROM WAMessage__c
                WHERE Id =: message.Id
                Order By CreatedDate ASC
               ];
    }
    @AuraEnabled(cacheable=true) 
    public static List<WAMessage__c> listAllMessageByCustomer(String customerPhone){
        List<WAMessage__c> messages = new List<WAMessage__c>();
        messages = [SELECT Id, Name, MessageContent__c, Message_Type__c,Platform__c,CustomerPhone__c, CustomerName__c, AgentName__c, Outgoing__c, CreatedDate
                    FROM WAMessage__c 
                    WHERE CustomerPhone__c =: customerPhone 
                    Order By CreatedDate ASC
                   ];
        return messages;
    }
    @AuraEnabled(cacheable=true)
    public static List<WAMessage__c> getMessages() {
        return [SELECT  AgentName__c, BusinessPhoneNumber__c, MessageContent__c,
                CreatedBy.Name, CustomerName__c, CustomerPhone__c, Image_ID__c,Platform__c, Image_Type__c,ImageSHA256__c,Message_ID__c,Message_Sent_Time__c,Message_Type__c,Outgoing__c,Parent_Message_ID__c,Reaction__c
                FROM WAMessage__c
                ORDER BY Message_Sent_Time__c DESC
                LIMIT 10];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WAMessage__c> getRecentMessages() {
        return [SELECT  Id, Name, MessageContent__c, Message_Type__c,Platform__c,CustomerPhone__c, CustomerName__c, AgentName__c, Is_Seen__c, Outgoing__c, CreatedDate
                FROM WAMessage__c where Is_Seen__c = false and Outgoing__c = false
                ORDER BY CreatedDate DESC
                LIMIT 100];
    }
    
    @AuraEnabled
    public static void updateRecentseenItems(String Phonenumber) {
        
        if(String.isNotBlank(Phonenumber))
        {
            List<WAMessage__c> lstmsgToUpdate = [SELECT  Id, Name, Platform__c,MessageContent__c, Message_Type__c,CustomerPhone__c, CustomerName__c, AgentName__c, Is_Seen__c, Outgoing__c, CreatedDate
                                                 FROM WAMessage__c where Is_Seen__c = false and Outgoing__c = false and CustomerPhone__c = :Phonenumber
                                                 ORDER BY Message_Sent_Time__c DESC
                                                ];
            
            if(lstmsgToUpdate != null && lstmsgToUpdate.size() > 0)
            {
                for(WAMessage__c msg :lstmsgToUpdate)
                {
                    msg.Is_Seen__c = true;
                }
                
                update lstmsgToUpdate;
            }
            
            
        }
    }
    
    
}