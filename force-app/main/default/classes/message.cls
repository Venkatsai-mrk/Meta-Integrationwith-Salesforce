public with sharing class message{
    
    @AuraEnabled(cacheable=true)
    public static List<WAMessage__c> getMessages() {
        return [SELECT  AgentName__c, BusinessPhoneNumber__c, MessageContent__c,
CreatedBy.Name, CustomerName__c, CustomerPhone__c, Image_ID__c, Image_Type__c,ImageSHA256__c,Message_ID__c,Message_Sent_Time__c,Message_Type__c,Outgoing__c,Parent_Message_ID__c,Reaction__c,Is_Seen__c
                FROM WAMessage__c WHERE Is_Seen__c= false
                ORDER BY Message_Sent_Time__c DESC
                LIMIT 10];
    }
}