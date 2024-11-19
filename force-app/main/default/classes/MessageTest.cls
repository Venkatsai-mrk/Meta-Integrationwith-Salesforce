@isTest
public class MessageTest {
    
    @testSetup
    static void setup() {
        // Create test data
        List<WAMessage__c> messages = new List<WAMessage__c>();
        for (Integer i = 0; i < 15; i++) {
            WAMessage__c message = new WAMessage__c(
                AgentName__c = 'Test Agent ' + i,
                BusinessPhoneNumber__c = '1234567890',
                MessageContent__c = 'This is a test message ' + i,
                //CreatedById = UserInfo.getUserId(),
                CustomerName__c = 'Test Customer ' + i,
                CustomerPhone__c = '0987654321',
                Image_ID__c = 'ImageID' + i,
                Image_Type__c = 'ImageType' + i,
                ImageSHA256__c = 'SHA256' + i,
                Message_ID__c = 'MessageID' + i,
                Message_Sent_Time__c = System.now().addMinutes(-i),
                Message_Type__c = 'text',
                Outgoing__c = false,
                Parent_Message_ID__c = 'ParentMessageID' + i,
                Reaction__c = 'Reaction' + i,
                Is_Seen__c = false
            );
            messages.add(message);
        }
        insert messages;
    }
    
    @isTest
    static void testGetMessages() {
        Test.startTest();
        List<WAMessage__c> messages = message.getMessages();
        Test.stopTest();
        
        System.assertEquals(10, messages.size(), 'Expected 10 messages to be returned');
        for (WAMessage__c msg : messages) {
            System.assertEquals(false, msg.Is_Seen__c, 'Expected Is_Seen__c to be false');
        }
    }
}