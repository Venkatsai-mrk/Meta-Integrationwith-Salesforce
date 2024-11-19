@isTest
private class RestResourceForWebHooksTest {
     
    @isTest
    public static void testWhatsAppMessageStructure() {
       
    }
    @isTest
    static void testDoGet() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.params.put('hub.verify_token', System.Label.WHATSAPPTOKEN);
        request.params.put('hub.challenge', '0x515b7e01');
        RestContext.request = request;
        RestContext.response = response;
        
        RestResourceForWebHooks.doGet();
        
    }
    
    @isTest
    static void testDoPost() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        response.addHeader('Content-type','application/json');
        // Set up request body and headers for testing
        request.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[{"id":"479735611885458","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"15551620333","phone_number_id":"456006777597423"},"contacts":[{"profile":{"name":"Venkat Jami \ud83d\ude09"},"wa_id":"919063903825"}],"messages":[{"from":"919063903825","id":"wamid.HBgMOTE5MDYzOTAzODI1FQIAEhggRTE1QzlFQkI1OEMxNkVEQjJEM0YyMDM5QzI4MUEyQTkA","timestamp":"1730783928","text":{"body":"Response check"},"type":"text"}]},"field":"messages"}]}]}');
        request.headers.put('X-Hub-Signature-256', 'sha256=028996a1a6f49b55ba4260c940d81caaa578fa53a7b07f6fe0fd5a72adb0f838');
         // Create an instance of WhatsAppMessage
        WhatsAppMessage whatsAppMessage = new WhatsAppMessage();
        
        // Initialize entry list and add an entry
        whatsAppMessage.entry = new List<WhatsAppMessage.entry>();
        WhatsAppMessage.entry entry = new WhatsAppMessage.entry();
        entry.id = 'EntryId';
        
        // Initialize changes list and add a changes instance
        entry.changes = new List<WhatsAppMessage.changes>();
        WhatsAppMessage.changes change = new WhatsAppMessage.changes();
        change.field = 'messages';
        
        // Initialize value and set its properties
        WhatsAppMessage.value value = new WhatsAppMessage.value();
        value.messaging_product = 'whatsapp';
        
        WhatsAppMessage.metadata metadata = new WhatsAppMessage.metadata();
        metadata.display_phone_number = '1234567890';
        metadata.phone_number_id = '09876';
        value.metadata = metadata;
        
        WhatsAppMessage.contacts contact = new WhatsAppMessage.contacts();
        contact.wa_id = '67890';
        contact.profile = new WhatsAppMessage.profile();
        contact.profile.name = 'Test User';
        value.contacts = new List<WhatsAppMessage.contacts>{contact};
        
        WhatsAppMessage.messages message = new WhatsAppMessage.messages();
        message.fromx = '12345';
        message.id = 'msg1';
        message.timestamp = '2024-11-06T05:00:00Z';
        message.text = new WhatsAppMessage.text();
        message.text.body = 'Hello, this is a test message.';
        message.typex = 'text';
        value.messages = new List<WhatsAppMessage.messages>{message};
        
        change.value = value;
        entry.changes.add(change);
        whatsAppMessage.entry.add(entry);
        
        // Assertions to validate structure
        System.assertEquals('EntryId', whatsAppMessage.entry[0].id);
       /* System.assertEquals(1, whatsAppMessage.entry[0].changes.size());
        System.assertEquals('messages', whatsAppMessage.entry[0].changes[0].field);
        System.assertEquals('whatsapp', whatsAppMessage.entry[0].changes[0].value.messaging_product);
        System.assertEquals('1234567890', whatsAppMessage.entry[0].changes[0].value.metadata.display_phone_number);
        System.assertEquals('Test User', whatsAppMessage.entry[0].changes[0].value.contacts[0].profile.name);
        System.assertEquals('Hello, this is a test message.', whatsAppMessage.entry[0].changes[0].value.messages[0].text.body);*/
        RestResourceForWebHooks.doPost();
        
        // Add assertions here based on the expected behavior of doPost method
    }
    
    @isTest
    static void testValidateWhatsAppSignature() {
        RestRequest request = new RestRequest();
        String responseString = '"{\"object\":\"whatsapp_business_account\",\"entry\":[{\"id\":\"479735611885458\",\"changes\":[{\"value\":{\"messaging_product\":\"whatsapp\",\"metadata\":{\"display_phone_number\":\"15551620333\",\"phone_number_id\":\"456006777597423\"},\"contacts\":[{\"profile\":{\"name\":\"Venkat Jami \\ud83d\\ude09\"},\"wa_id\":\"919063903825\"}],\"messages\":[{\"from\":\"919063903825\",\"id\":\"wamid.HBgMOTE5MDYzOTAzODI1FQIAEhggNzMzNTQ4RTE3RkM4RjY3NDQyMTNCNDQ3MTlFMTU2NDkA\",\"timestamp\":\"1730785969\",\"text\":{\"body\":\"Testing \\ud83e\\uddea\"},\"type\":\"text\"}]},\"field\":\"messages\"}]}]}"';
        request.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[{"id":"479735611885458","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"15551620333","phone_number_id":"456006777597423"},"contacts":[{"profile":{"name":"Venkat Jami \ud83d\ude09"},"wa_id":"919063903825"}],"messages":[{"from":"919063903825","id":"wamid.HBgMOTE5MDYzOTAzODI1FQIAEhggRTE1QzlFQkI1OEMxNkVEQjJEM0YyMDM5QzI4MUEyQTkA","timestamp":"1730783928","text":{"body":"Response check"},"type":"text"}]},"field":"messages"}]}]}');
        request.headers.put('X-Hub-Signature-256', 'sha256=028996a1a6f49b55ba4260c940d81caaa578fa53a7b07f6fe0fd5a72adb0f838');
        RestContext.request = request;
        String whatsAppPayload = RestContext.request.requestBody.toString();
        String METAAPPSECRET = System.Label.METAAPPSECRET;
        Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(whatsAppPayload), Blob.valueOf( METAAPPSECRET ));
        String result = RestResourceForWebHooks.validateWhatsAppSignature(request, responseString);
        
        // Add assertions here based on the expected behavior of validateWhatsAppSignature method
    }
}