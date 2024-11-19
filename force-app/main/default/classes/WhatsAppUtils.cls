public class WhatsAppUtils {
    
    public static List<WAMessage__c> listAllMessageByCustomer(String customerPhone){
        List<WAMessage__c> messages = new List<WAMessage__c>();
        messages = [SELECT Id, Name, MessageContent__c, Message_Type__c, Outgoing__c FROM WAMessage__c WHERE CustomerPhone__c =: customerPhone];
        return messages;
    }
    //sending Message to WhatsApp
    public static WAMessage__c sendTextMessage (String messageContent, String toPhone){
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://graph.facebook.com/'+system.label.WHATSAPPPAGEID+'/messages');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer '+System.Label.WHATSAPPACCESSTOKEN);
        
        String messageBody = '{'+
            '    "messaging_product": "whatsapp",'+
            '    "recipient_type": "individual",'+
            '    "to": "'+toPhone+'",'+
            '    "type": "text",'+
            '    "text": {'+
            '        "preview_url": false,'+
            '        "body": "'+messageContent+'"'+
            '    }'+
            '}';
        
        httpReq.setBody(messageBody);
        
        Http http = new Http();
        WAMessage__c salesforceMessage = new WAMessage__c();
        try{
            HttpResponse response = http.send(httpReq);
            if( response.getStatusCode() == 200 ){
                // Parse & Create Message Record
                System.debug('Successful!');
                WhatsAppUtils responseFromWA = (WhatsAppUtils) JSON.deserialize( response.getBody() , WhatsAppUtils.class);
                
                salesforceMessage.MessageContent__c = messageContent;
                salesforceMessage.CustomerPhone__c = toPhone;
                salesforceMessage.Message_ID__c = responseFromWA.messages.get(0).id;
                salesforceMessage.Message_Type__c = 'text';
                salesforceMessage.Platform__c = 'WhatsApp';
                salesforceMessage.Outgoing__c = True;
                salesforceMessage.AgentName__c = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                upsert salesforceMessage Message_ID__c;
            }
        }catch(System.CalloutException ex){
            System.debug(' CalloutException Executed '+ ex.getStackTraceString() );
            System.debug(' CalloutException Executed '+ ex.getMessage() );
        }catch(System.Exception ex){
            System.debug(' System.Exception Executed '+ ex.getStackTraceString() );
        }
        return salesforceMessage;
    }
    
    //sending Message to facebook
    public static WAMessage__c sendTextMessageToFaceBook (String messageContent, String toSenderId){
        String token = system.label.FaceBookAccessToken;
        // String token = 'EAA0p1zl7zBIBO2U3WpqHcGKZCu6XCshdmKyKLR8CDUd4gI52sBTpXnQPFOJlkcZAhnatSyP2Mk6BQhr0e0otM19uCZBjsoDZBbHOsC4oGw8OJoNZBb0ZB1LN1otPoHI4x4lAH5PugnR96gvybsXDismYpIAF3aoKcv5Iisb9ZADKzwrldqC2TIXt8nfnrDVRftVEDieuKlaeAZDZD';
        // String tokn = 'EAAIWgWNbPk4BOzVJUluj65P3ZAOcMgKrKJqPzma2eIQoeK3xjHk4ZBncDJIORjZBU9qM08X4IZBQs6xpIZABocidygcLfj1fvlNl59kykZCKWFeRGlbP25yxGpNj36ZCeI33c1jcZCfZB9bqH1z1aAXRPn328GWB0QO44ndcYWstP76W7z3QhsjxjQBqXDqxmOCveD4p7qdXTYgZDZD';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://graph.facebook.com/'+system.label.FACEBOOKPAGEID+'/messages');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer '+token);
        
        String messageBody = '{'+
            '    "recipient": {'+
            '        "id":"'+toSenderId+'"'+'},'+
            '    "message": {'+
            '        "text": "'+messageContent+'"'+
            '    }'+
            '}';
        
        httpReq.setBody(messageBody);
        
        Http http = new Http();
        WAMessage__c salesforceMessage = new WAMessage__c();
        try{
            HttpResponse response = http.send(httpReq);
            if( response.getStatusCode() == 200 ){
                System.debug(System.LoggingLevel.DEBUG,' Headers response.getBody   '+ response.getBody() );
                // Parse & Create Message Record
                System.debug('Successful!');
                FaceBookMessage responseFromFB = (FaceBookMessage) JSON.deserialize( response.getBody() , FaceBookMessage.class);
                
                salesforceMessage.MessageContent__c = messageContent;
                salesforceMessage.CustomerPhone__c = toSenderId;
                //  salesforceMessage.Message_ID__c = responseFromFB.entry[0].messaging[0].message.mid != null?responseFromFB.entry[0].messaging[0].message.mid : null;
                salesforceMessage.Message_Type__c = 'text';
                salesforceMessage.Platform__c = 'FaceBook';
                salesforceMessage.Outgoing__c = True;
                salesforceMessage.AgentName__c = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                insert salesforceMessage ;
            }
        }catch(System.CalloutException ex){
            System.debug(' CalloutException Executed '+ ex.getStackTraceString() );
            System.debug(' CalloutException Executed '+ ex.getMessage() );
        }catch(System.Exception ex){
            System.debug(' System.Exception Executed '+ ex.getStackTraceString() );
        }
        System.debug(System.LoggingLevel.DEBUG,' salesforceMessage getBody   '+ salesforceMessage );
        return salesforceMessage;
    }
    //sending Message to instagram
    public static WAMessage__c sendTextMessageToInstagram (String messageContent, String toSenderId){
        String token = system.label.InstagramAccessToken;
        // String token = 'EAA0p1zl7zBIBO2U3WpqHcGKZCu6XCshdmKyKLR8CDUd4gI52sBTpXnQPFOJlkcZAhnatSyP2Mk6BQhr0e0otM19uCZBjsoDZBbHOsC4oGw8OJoNZBb0ZB1LN1otPoHI4x4lAH5PugnR96gvybsXDismYpIAF3aoKcv5Iisb9ZADKzwrldqC2TIXt8nfnrDVRftVEDieuKlaeAZDZD';
        // String tokn = 'EAAIWgWNbPk4BOzVJUluj65P3ZAOcMgKrKJqPzma2eIQoeK3xjHk4ZBncDJIORjZBU9qM08X4IZBQs6xpIZABocidygcLfj1fvlNl59kykZCKWFeRGlbP25yxGpNj36ZCeI33c1jcZCfZB9bqH1z1aAXRPn328GWB0QO44ndcYWstP76W7z3QhsjxjQBqXDqxmOCveD4p7qdXTYgZDZD';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://graph.instagram.com/'+system.label.INSTAGRAMPAGEID+'/messages');
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer '+token);
        
        String messageBody = '{'+
            '    "recipient": {'+
            '        "id":"'+toSenderId+'"'+'},'+
            '    "message": {'+
            '        "text": "'+messageContent+'"'+
            '    }'+
            '}';
        
        httpReq.setBody(messageBody);
        
        Http http = new Http();
        WAMessage__c salesforceMessage = new WAMessage__c();
        try{
            HttpResponse response = http.send(httpReq);
            if( response.getStatusCode() == 200 ){
                System.debug(System.LoggingLevel.DEBUG,' Headers response.getBody   '+ response.getBody() );
                // Parse & Create Message Record
                System.debug('Successful!');
                FaceBookMessage responseFromFB = (FaceBookMessage) JSON.deserialize( response.getBody() , FaceBookMessage.class);
                
                salesforceMessage.MessageContent__c = messageContent;
                salesforceMessage.CustomerPhone__c = toSenderId;
                //  salesforceMessage.Message_ID__c = responseFromFB.entry[0].messaging[0].message.mid != null?responseFromFB.entry[0].messaging[0].message.mid : null;
                salesforceMessage.Message_Type__c = 'text';
                salesforceMessage.Platform__c = 'Instagram';
                salesforceMessage.Outgoing__c = true;
                salesforceMessage.AgentName__c = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                upsert salesforceMessage ;
            }
        }catch(System.CalloutException ex){
            System.debug(' CalloutException Executed '+ ex.getStackTraceString() );
            System.debug(' CalloutException Executed '+ ex.getMessage() );
        }catch(System.Exception ex){
            System.debug(' System.Exception Executed '+ ex.getStackTraceString() );
        }
        return salesforceMessage;
    }
    
    public String messaging_product;
    public contacts[] contacts;
    public messages[] messages;
    public class contacts {
        public String input;
        public String wa_id;
    }
    public class messages {
        public String id;
    }
}