public with sharing class WhatsAppMessageController {
    @AuraEnabled(Cacheable=true)
    public static void sendSMS(String businessPhoneNumber, String customerPhone, String messageContent) {
        // Replace these with your Twilio account SID and Auth Token
        String accountSid = 'AC8229413cf66b237d6bf977ed6052ab2c';
        String authToken = 'eb0cd34a516ac049e4ad8d4f1ab13c2d';
        
        // Twilio API endpoint
        String twilioEndpoint = 'https://api.twilio.com/2010-04-01/Accounts/' + accountSid + '/Messages.json';
        
        // Prepare the message payload
        Map<String, String> params = new Map<String, String>();
        params.put('From', businessPhoneNumber);
        params.put('To', customerPhone);
        params.put('Body', messageContent);
        
        // Encode the parameters
        String body = '';
        for (String key : params.keySet()) {
            if (body != '') {
                body += '&';
            }
            body += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
        }

        // Make the HTTP request to Twilio
        HttpRequest req = new HttpRequest();
        req.setEndpoint(twilioEndpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(accountSid + ':' + authToken)));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 201) {
            throw new CalloutException('Failed to send SMS: ' + res.getBody());
        }
    }
}