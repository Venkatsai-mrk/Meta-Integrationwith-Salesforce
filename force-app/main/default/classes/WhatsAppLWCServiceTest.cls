@isTest
public class WhatsAppLWCServiceTest {
    
    @testSetup
    static void setup() {
        // Create test data
        List<WAMessage__c> messages = new List<WAMessage__c>();
        for (Integer i = 0; i < 5; i++) {
            WAMessage__c message = new WAMessage__c(
                MessageContent__c = 'This is a test message ' + i,
                Message_Type__c = 'text',
                Platform__c = 'WhatsApp',
                CustomerPhone__c = '1234567890',
                CustomerName__c = 'Test Customer',
                AgentName__c = 'Test Agent',
                Outgoing__c = false,
                Is_Seen__c = false
            );
            messages.add(message);
        }
        insert messages;
    }
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"messages":[{"id":"wamid.HBgL1234567890"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testListAllMessages() {
        Test.startTest();
        List<WAMessage__c> messages = WhatsAppLWCService.listAllMessages('1234567890');
        WhatsAppLWCService.listAllMessageByCustomer('1234567890');
        WhatsAppUtils.listAllMessageByCustomer('1234567890');
        WhatsAppLWCService.getMessages();
        WhatsAppLWCService.getRecentMessages();
        Test.stopTest();
        
        System.assert(messages.size() == 5);
    }
    
    @isTest
    static void testGetSingleMessage() {
        WAMessage__c message = [SELECT Id FROM WAMessage__c LIMIT 1];
        
        Test.startTest();
        WAMessage__c result = WhatsAppLWCService.getSingleMessage(message.Id, '1234567890');
        Test.stopTest();
        
        System.assert(result != null);
        System.assertEquals(result.Id, message.Id);
    }
    
    @isTest
    static void testSendTextMessage() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        WAMessage__c message = WhatsAppLWCService.sendTextMessage('Hello, WhatsApp!', '1234567890');
        Test.stopTest();
        
        System.assert(message != null);
        System.assertEquals(message.MessageContent__c, 'Hello, WhatsApp!');
    }
    
    @isTest
    static void testSendTextMessageToFaceBook() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        WAMessage__c message = WhatsAppLWCService.sendTextMessageToFaceBook('Hello, Facebook!', '1234567890');
        Test.stopTest();
        
        System.assert(message != null);
        System.assertEquals(message.MessageContent__c, 'Hello, Facebook!');
    }
    
    @isTest
    static void testSendTextMessageToInstagram() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        Test.startTest();
        WAMessage__c message = WhatsAppLWCService.sendTextMessageToInstagram('Hello, Instagram!', '1234567890');
        Test.stopTest();
        
        System.assert(message != null);
        System.assertEquals(message.MessageContent__c, 'Hello, Instagram!');
    }
    
    @isTest
    static void testUpdateRecentseenItems() {
        Test.startTest();
        WhatsAppLWCService.updateRecentseenItems('1234567890');
        Test.stopTest();
        
        List<WAMessage__c> messages = [SELECT Is_Seen__c FROM WAMessage__c WHERE CustomerPhone__c = '1234567890'];
        System.debug('Messages: ' + messages);
        for (WAMessage__c message : messages) {
            System.assert(message.Is_Seen__c);
        }
    }
}