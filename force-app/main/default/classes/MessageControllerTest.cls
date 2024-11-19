@isTest
private class MessageControllerTest {
    
    @isTest
    static void testGetMessages() {
        // Create test data
        List<WAMessage__c> testMessages = new List<WAMessage__c>();
        for (Integer i = 0; i < 10; i++) {
            WAMessage__c message = new WAMessage__c(
                AgentName__c = 'Agent ' + i,
                BusinessPhoneNumber__c = '1234567890',
                MessageContent__c = 'Test content ' + i,
                CustomerName__c = 'Customer ' + i,
                CustomerPhone__c = '0987654321',
                Message_Sent_Time__c = DateTime.now().addDays(-i)
            );
            testMessages.add(message);
        }
        insert testMessages;
        
        // Call the method within the test context
        Test.startTest();
        List<WAMessage__c> messages = MessageController.getMessages();
        Test.stopTest();
    }
}