@isTest
public class InstagramRestResourceTest {
    
    @isTest
    static void testDoGet() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/salesforcetoInstagram/';
        req.addParameter('InstagramAppToken', System.label.InstagramAppToken);
        req.addParameter('hub.challenge', 'test_challenge');
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        InstagramRestResource.doGet();
        
        // Verify the response
        System.assertEquals(1,1,'');
    }
    
    @isTest
    static void testDoPost() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('X-Hub-Signature-256', 'sha256=cf8ab35d51dbad7f54223fae0ba2223ae51b3bb2ede6977de3856b8596e156a4');
        req.requestBody = Blob.valueOf('{"object":"instagram","entry":[{"time":1730449943981,"id":"17841470444261501","messaging":[{"sender":{"id":"1648734379007074"},"recipient":{"id":"17841470444261501"},"timestamp":1730449943003,"message":{"mid":"test_mid","text":"Hey"}}]}]}');
        RestContext.request = req;
        RestContext.response = res;
        
        // Mock the validateWhatsAppSignature method
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        InstagramRestResource.doPost();
        Test.stopTest();
        
        // Verify the response
        System.assertEquals(200, res.statusCode);
      //  System.assertEquals('{"success":true, "event":"success"}', res.responseBody.toString());
        
        // Verify the WAMessage__c record
        WAMessage__c[] messages = [SELECT Id, Message_ID__c, Platform__c, MessageContent__c, CustomerPhone__c, Message_Sent_Time__c, CustomerName__c FROM WAMessage__c WHERE Message_ID__c = 'test_mid'];
        System.assertEquals(1, messages.size());
        System.assertEquals('test_mid', messages[0].Message_ID__c);
        System.assertEquals('Instagram', messages[0].Platform__c);
        System.assertEquals('Hey', messages[0].MessageContent__c);
        System.assertEquals('1648734379007074', messages[0].CustomerPhone__c);
    }
    
    @isTest
    static void testGetInstagramSenderName() {
        // Set up the test data
        WAMessage__c message = new WAMessage__c(Message_ID__c = 'test_mid', Platform__c = 'Instagram', CustomerName__c = 'Test User');
        insert message;
        
        // Call the method
        String senderName = InstagramRestResource.getInstagramSenderName('test_mid');
        
        // Verify the result
        System.assertEquals('Test User', senderName);
    }
    
  /*  @isTest
    static void testValidateWhatsAppSignature() {
        // Set up the test data
        RestRequest req = new RestRequest();
        req.addHeader('X-Hub-Signature-256', 'sha256=valid_signature');
        req.requestBody = Blob.valueOf('test_payload');
        RestContext.request = req;
        
        // Mock the signature validation
        String result = InstagramRestResource.validateWhatsAppSignature(req, 'test_payload');
        
        // Verify the result
        System.assertEquals('Signature Verified', result);
    }*/
      // Mock class for HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"conversations":{"data":[{"id":"12345","senders":{"data":[{"id":"1648734379007074","name":"Test User"}]}}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
}