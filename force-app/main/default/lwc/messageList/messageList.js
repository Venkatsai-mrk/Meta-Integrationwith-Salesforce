import { LightningElement, track, wire } from 'lwc';
import getWAMessages from '@salesforce/apex/MessageController.getMessages';

const actions = [
    { label: 'Register New Mobile', name: 'register_new_mobile' },
    { label: 'Send Text Message', name: 'send_text_message' }
];

const columns = [
    { label: 'Message ID', fieldName: 'Name', type: 'text' },
    { label: 'Message Content', fieldName: 'MessageContent__c', type: 'richtext' },
    { label: 'Customer Phone', fieldName: 'CustomerPhone__c', type: 'phone', 
      typeAttributes: { 
          label: { fieldName: 'CustomerPhone__c' }, 
          target: '_blank' 
      } 
    },
    { label: 'Message Sent Time', fieldName: 'Message_Sent_Time__c', type: 'date' },
    { type: 'action', typeAttributes: { rowActions: actions } }
];

export default class MessageComponent extends LightningElement {
    @track messages;
    @track columns = columns;
    @track showDropdown = false;
    @track selectedMessageId;

    @wire(getWAMessages)
    wiredMessages({ error, data }) {
        if (data) {
            this.messages = data;
        } else if (error) {
            console.error('Error fetching WA messages:', error);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedMessageId = row.Id;

        switch (actionName) {
            case 'register_new_mobile':
                this.registerNewMobile();
                break;
            case 'send_text_message':
                this.sendTextMessage();
                break;
            default:
                break;
        }
    }

    registerNewMobile() {
        // Logic for registering new mobile
        console.log('Register New Mobile for message ID:', this.selectedMessageId);
        this.showDropdown = false;
    }

    sendTextMessage() {
        // Logic for sending text message
        console.log('Send Text Message for message ID:', this.selectedMessageId);
        this.showDropdown = false;
    }

    handlePhoneClick(event) {
        event.preventDefault();
        const phoneNumber = event.target.dataset.phone;
        window.location.href = `/chat?mobile=${phoneNumber}`;
    }
}