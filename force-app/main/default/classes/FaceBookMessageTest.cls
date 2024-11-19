@isTest
public class FaceBookMessageTest {
    
    @isTest
    public static void testFaceBookMessageStructure() {
        // Create an instance of FaceBookMessage
        FaceBookMessage fbMessage = new FaceBookMessage();
        fbMessage.objects = 'Sample Object';
        
        // Initialize entry list and add an entry
        fbMessage.entry = new List<FaceBookMessage.Entry>();
        FaceBookMessage.Entry entry = new FaceBookMessage.Entry();
        entry.times = 1234567890L;
        entry.id = 'EntryId';
        
        // Initialize messaging list and add a messaging instance
        entry.messaging = new List<FaceBookMessage.Messaging>();
        FaceBookMessage.Messaging messaging = new FaceBookMessage.Messaging();
        
        // Set sender and recipient
        FaceBookMessage.Sender sender = new FaceBookMessage.Sender();
        sender.id = 'SenderId';
        messaging.sender = sender;
        
        FaceBookMessage.Recipient recipient = new FaceBookMessage.Recipient();
        recipient.id = 'RecipientId';
        messaging.recipient = recipient;
        
        // Set timestamp and message details
        messaging.timestamp = 1234567890L;
        
        FaceBookMessage.Message message = new FaceBookMessage.Message();
        message.mid = 'MessageId';
        message.text = 'Hello, this is a test message';
        messaging.message = message;
        
        // Add messaging instance to entry and entry to fbMessage
        entry.messaging.add(messaging);
        fbMessage.entry.add(entry);
        
        // Assertions to validate structure
        System.assertEquals('Sample Object', fbMessage.objects);
        System.assertEquals(1, fbMessage.entry.size());
        System.assertEquals('EntryId', fbMessage.entry[0].id);
        System.assertEquals(1, fbMessage.entry[0].messaging.size());
        System.assertEquals('SenderId', fbMessage.entry[0].messaging[0].sender.id);
        System.assertEquals('RecipientId', fbMessage.entry[0].messaging[0].recipient.id);
        System.assertEquals('MessageId', fbMessage.entry[0].messaging[0].message.mid);
        System.assertEquals('Hello, this is a test message', fbMessage.entry[0].messaging[0].message.text);
    }
}