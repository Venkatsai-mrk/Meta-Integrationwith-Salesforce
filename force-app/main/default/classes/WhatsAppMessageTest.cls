@isTest
public class WhatsAppMessageTest {
    
    @isTest
    public static void testWhatsAppMessageStructure() {
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
        
        // Initialize context, reaction, image, and video
        message.context = new WhatsAppMessage.context();
        message.context.fromx = '12345';
        message.context.id = 'context1';
        
        message.reaction = new WhatsAppMessage.reaction();
        message.reaction.emoji = '👍';
        message.reaction.message_id = 'msg1';
        
        message.image = new WhatsAppMessage.image();
        message.image.mime_type = 'image/jpeg';
        message.image.id = 'image1';
        message.image.sha256 = 'abc123';
        
        message.video = new WhatsAppMessage.image(); // Assuming video is of type image
        message.video.mime_type = 'video/mp4';
        message.video.id = 'video1';
        message.video.sha256 = 'def456';
        
        value.messages = new List<WhatsAppMessage.messages>{message};
        
        change.value = value;
        entry.changes.add(change);
        whatsAppMessage.entry.add(entry);
        
        // Assertions to validate structure
        System.assertEquals('EntryId', whatsAppMessage.entry[0].id);
        System.assertEquals(1, whatsAppMessage.entry[0].changes.size());
        System.assertEquals('messages', whatsAppMessage.entry[0].changes[0].field);
        System.assertEquals('whatsapp', whatsAppMessage.entry[0].changes[0].value.messaging_product);
        System.assertEquals('1234567890', whatsAppMessage.entry[0].changes[0].value.metadata.display_phone_number);
        System.assertEquals('Test User', whatsAppMessage.entry[0].changes[0].value.contacts[0].profile.name);
        System.assertEquals('Hello, this is a test message.', whatsAppMessage.entry[0].changes[0].value.messages[0].text.body);
        System.assertEquals('👍', whatsAppMessage.entry[0].changes[0].value.messages[0].reaction.emoji);
        System.assertEquals('image/jpeg', whatsAppMessage.entry[0].changes[0].value.messages[0].image.mime_type);
        System.assertEquals('video/mp4', whatsAppMessage.entry[0].changes[0].value.messages[0].video.mime_type);
    }
}