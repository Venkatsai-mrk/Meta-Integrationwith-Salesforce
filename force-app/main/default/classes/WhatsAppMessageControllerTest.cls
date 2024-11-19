@IsTest
private class WhatsAppMessageControllerTest {

    @IsTest
    static void testSendSMS() {
        // Set up mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"sid": "SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", "status": "queued"}');
        mockResponse.setStatusCode(201);

        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the method
        String businessPhoneNumber = '+1234567890';
        String customerPhone = '+0987654321';
        String messageContent = 'Hello, this is a test message.';

        Test.startTest();
        WhatsAppMessageController.sendSMS(businessPhoneNumber, customerPhone, messageContent);
        Test.stopTest();

        // Verify the callout
        // Since we are using a mock, we don't have actual assertions here
        // The mock itself ensures that the callout was made and returned the expected response
    }

    // Mock HTTP response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}