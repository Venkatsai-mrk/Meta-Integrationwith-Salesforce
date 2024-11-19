@RestResource(urlMapping='/salesforcetoFB/*')
global class FaceBookRestResource {
    private static Final String SIGNATURE_VALID_MESSAGE     = 'Signature Verified';
    private static Final String SIGNATURE_NOT_VALID_MESSAGE = 'Signature could not be verified';
    
    @HttpGet // GET
    global static void doGet() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;
        system.debug(System.LoggingLevel.DEBUG,'$$'+request.params.get('hub.verify_token'));
        if(request.params.get('hub.verify_token') ==System.label.FaceBookAppToken){
            response.responseBody = Blob.valueOf( request.params.get('hub.challenge') );
            system.debug(System.LoggingLevel.DEBUG,'$$'+Blob.valueOf( request.params.get('hub.challenge')));
        }
    }
    
    @HttpPost // POST
    global static void doPost() {
        
        RestResponse response = RestContext.response;
        response.addHeader('Content-type','application/json');
        String responseString = RestContext.request.requestBody.toString();
        system.debug(System.LoggingLevel.DEBUG,'responseString@@'+responseString);
        Map<String, String> headers = RestContext.request.headers;
        String responseValid = validateWhatsAppSignature(RestContext.request, responseString);
        
        if(responseValid == SIGNATURE_VALID_MESSAGE){
            System.debug(System.LoggingLevel.DEBUG,' Headers Response From WhatsApp \n  '+ JSON.serialize(headers) );
            System.debug(System.LoggingLevel.DEBUG,' Response From WhatsApp \n  '+ responseString);
            String finalResponseString = responseString.replace('type', 'typex');
            system.debug('finalResponseString@@'+finalResponseString);
            //Sample JSON Recieving {"object":"page","entry":[{"time":1730449943981,"id":"17841470444261501","messaging":[{"sender":{"id":"1648734379007074"},"recipient":{"id":"17841470444261501"},"timestamp":1730449943003,"message":{"mid":"aWdfZAG1faXRlbToxOklHTWVzc2FnZAUlEOjE3ODQxNDcwNDQ0MjYxNTAxOjM0MDI4MjM2Njg0MTcxMDMwMTI0NDI1OTU2MTc1MDQ0NjQ4NTAyMTozMTkyMTE2NzIzMDk1MjkyOTQ3ODgwMTA3MDQ5Nzk4ODYwOAZDZD","text":"Hey \ud83d\udc4b"}}]}]}
            FaceBookMessage parentMessage = (FaceBookMessage)JSON.deserialize(finalResponseString, FaceBookMessage.class);
            List<FaceBookMessage.Entry> messageEntries = parentMessage.entry;
            
            if (messageEntries != null && !messageEntries.isEmpty()) {
                FaceBookMessage.Entry entryMessage = messageEntries.get(0);
                List<FaceBookMessage.Messaging> messagingList = entryMessage.messaging;
                
                if (messagingList != null && !messagingList.isEmpty()) {
                    FaceBookMessage.Messaging messaging = messagingList.get(0);
                    FaceBookMessage.Message message = messaging.message;
                    
                    // Create record into WAMessage__c
                    WAMessage__c salesforceMessage = new WAMessage__c();
                    salesforceMessage.Message_ID__c = message.mid != null? message.mid : null;
                    salesforceMessage.Platform__c = 'FaceBook';
                    salesforceMessage.MessageContent__c = message.text != null? message.text : null;
                    salesforceMessage.CustomerPhone__c = messaging.sender != null? messaging.sender.id : null;
                    salesforceMessage.Message_Sent_Time__c = messaging.timestamp != null ? DateTime.valueOf(messaging.timestamp) : null;
                    salesforceMessage.CustomerName__c = getFBSenderName(salesforceMessage.CustomerPhone__c);
                    // Insert the WAMessage__c record
                    upsert salesforceMessage Message_ID__c;
                    
                    WA_Message_Event__e platformEvent = new WA_Message_Event__e();
                    platformEvent.MessageId__c = salesforceMessage.Id;
                    platformEvent.CustomerPhone__c =  messaging.sender != null? messaging.sender.id : null;
                    Eventbus.publish( platformEvent );
                }
            }
        }else{
            response.responseBody = Blob.valueOf('{success:false, event:"Unknown","message:"'+responseValid+'"}');
            response.statusCode = 401;
            return;
        }
        
        response.statusCode = 200;
        response.responseBody = Blob.valueOf('{success:true, event:"success"}');
    }
    
    public static String getFBSenderName(String FBSenderId){
        List<WAMessage__c> res = [SELECT  Name, MessageContent__c,CustomerPhone__c,CustomerName__c FROM WAMessage__c WHERE CustomerPhone__c = :FBSenderId AND CustomerName__c!= '' AND Platform__c = 'FaceBook']; 
        if (res.size() > 0) {
            return res[0].CustomerName__c;
        }else{
            string FBCustomerName = '';
            String token = system.label.FaceBookAccessToken;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://graph.facebook.com/'+system.label.FACEBOOKPAGEID+'?fields=conversations{senders}');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json'); // Set headers as needed
            request.setHeader('Authorization', 'Bearer '+token);
            
            try {
                // Send the HTTP request
                HttpResponse response = http.send(request);
                
                // Check for a successful response
                if (response.getStatusCode() == 200) {
                    // Deserialize the response body into a Map
                    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    
                    // Accessing conversations
                    Map<String, Object> conversations = (Map<String, Object>)responseMap.get('conversations');
                    List<Object> dataList = (List<Object>)conversations.get('data');
                    
                    for (Object conversationObj : dataList) {
                        Map<String, Object> conversation = (Map<String, Object>)conversationObj;
                        String conversationId = (String)conversation.get('id');
                        
                        // Accessing senders
                        Map<String, Object> senders = (Map<String, Object>)conversation.get('senders');
                        List<Object> senderList = (List<Object>)senders.get('data');
                        for (Object senderObj : senderList) {
                            Map<String, Object> sender = (Map<String, Object>)senderObj;
                            if(FBSenderId == (String)sender.get('id')){
                                FBCustomerName =   (String)sender.get('name');
                            }
                        }
                    } 
                }
            } catch (Exception e) {
                // Handle any exceptions
                System.debug('Exception: ' + e.getMessage());
            }
            return  FBCustomerName;
        }
    }
    private static String validateWhatsAppSignature(RestRequest request, String responseString) {
        // Validate Stripe signature Start 
        Map<String, String> headers = request.headers;
        
        String whatsAppSignature = headers.get('X-Hub-Signature-256');
        
        String whatsAppPayload = RestContext.request.requestBody.toString();
        
        // Verify the signature using 'hmacSHA256'. I have the Webhook key stored in a Custom Label
        String METAAPPSECRET = System.Label.METAAPPSECRET; // Facebook Application Secret Key
        Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(whatsAppPayload), Blob.valueOf( METAAPPSECRET ));
        
        String encodedPayload = 'sha256='+EncodingUtil.convertToHex(signedPayload);
        // Return status code based on whether signed payload matches or not
        system.debug('encodedPayload-'+encodedPayload);
        system.debug('signedPayload-@@'+signedPayload);
        String response = (encodedPayload == whatsAppSignature)? SIGNATURE_VALID_MESSAGE : SIGNATURE_NOT_VALID_MESSAGE;
        return response;
        // Validate Stripe signature End 
    }
}