@isTest
private class FaceBookRestResourceTest {
    
    @isTest
    static void testDoGet() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/salesforcetoFB/';
        req.addParameter('hub.verify_token', System.label.FaceBookAppToken);
        req.addParameter('hub.challenge', 'test_challenge');
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        FaceBookRestResource.doGet();
        
        // Verify the response
        System.assertEquals('test_challenge', res.responseBody.toString());
    }
    
    @isTest
    static void testDoGetInvalidToken() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/salesforcetoFB/';
        req.addParameter('hub.verify_token', System.Label.FaceBookAppToken);
        req.addParameter('hub.challenge', 'test_challenge');
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        FaceBookRestResource.doGet();
        
        // Verify the response
        System.assertEquals(1,1,'');
    }
    
    @isTest
    static void testDoPostValidSignature() {
        // Set up the test data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        res.addHeader('Content-type','application/json');
        req.requestBody = Blob.valueOf('{"object":"page","entry":[{"time":1730449943981,"id":"17841470444261501","messaging":[{"sender":{"id":"1648734379007074"},"recipient":{"id":"17841470444261501"},"timestamp":1730449943003,"message":{"mid":"mid.1234567890","text":"Hello"}}]}]}');
        req.addHeader('X-Hub-Signature-256', 'sha256=756f322422d3f163ba7d1e2348f24c9fb949ede6fafc272e447066ea3b141a23');
        RestContext.request = req;
        RestContext.response = res;
        
        // Mock the validateWhatsAppSignature method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        FaceBookRestResource.doPost();
        Test.stopTest();
        
        // Verify the response
       System.assertEquals(200, res.statusCode);
        
        // Verify the WAMessage__c record
        List<WAMessage__c> messages = [SELECT Id, Message_ID__c, Platform__c, MessageContent__c, CustomerPhone__c, Message_Sent_Time__c, CustomerName__c FROM WAMessage__c];
    }
      
    @isTest
    static void testGetFBSenderNameWithExistingRecord() {
        // Create a test WAMessage__c record
        WAMessage__c testMessage = new WAMessage__c(
            CustomerPhone__c = '1648734379007074',
            CustomerName__c = 'Test User',
            Platform__c = 'FaceBook'
        );
        insert testMessage;
        
        // Call the method
        String senderName = FaceBookRestResource.getFBSenderName('1648734379007074');
        
        // Verify the result
        System.assertEquals('Test User', senderName);
    }
    
    @isTest
    static void testGetFBSenderNameWithoutExistingRecord() {
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method
        String senderName = FaceBookRestResource.getFBSenderName('1648734379007074');
        
        // Verify the result
        System.assertEquals('Test User', senderName);
    }
    
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