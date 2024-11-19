import { LightningElement, track, wire } from 'lwc';
import getMessages from '@salesforce/apex/WhatsAppLWCService.getMessages';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getSingleMessage from '@salesforce/apex/WhatsAppLWCService.getSingleMessage';
import getRecentMessages from '@salesforce/apex/WhatsAppLWCService.getRecentMessages';
import { refreshApex } from '@salesforce/apex';
import updateRecentseenItems from '@salesforce/apex/WhatsAppLWCService.updateRecentseenItems';
import SOCIAL_MEDIA_IMAGES from '@salesforce/resourceUrl/SocialMediaImages';

export default class MessageComponent extends NavigationMixin(LightningElement) {
    @track messages = [];
    @track filteredMessages = [];
    @track mobileNumber = '';
    @track otp = '';
    isChatOpen = false;
    mobileToChildCom = '';
    disableButt = true;
    @track fullResult;
    @track openTable = '';
    // Handling Tabset 
    whatsappImage = `${SOCIAL_MEDIA_IMAGES}/SocialMediaImages/WhatsApp.jpg`;
    facebookImage = `${SOCIAL_MEDIA_IMAGES}/SocialMediaImages/Messenger.jpg`;
    instagramImage = `${SOCIAL_MEDIA_IMAGES}/SocialMediaImages/Instagram.jpg`;
    @track whatsappMessageCount = 0; // Initialize with the count of new messages
    @track facebookMessageCount = 0; // Initialize with the count of new messages
    @track instagramMessageCount = 0;
    wiredRefreshData;
    handleTabClick(event) {
        const tabName = event.currentTarget.getAttribute('data-tab-name');
        var selectedWhatsappTab = this.template.querySelector('[data-tab-name="WhatsApp"]');
        var selectedfacebookTab = this.template.querySelector('[data-tab-name="FaceBook"]');
        var selectedInstaTab = this.template.querySelector('[data-tab-name="Instagram"]');

        console.log(tabName); // This will log "WhatsApp" or "Facebook"
        if (tabName == 'WhatsApp') {
            selectedWhatsappTab.classList.add("clickcolor");
            selectedfacebookTab.classList.remove("clickcolor");
            selectedInstaTab.classList.remove("clickcolor");
            this.openTable = tabName;
            // this.whatsappMessageCount = 0;
            this.filteredMessages = this.messages.filter(message => message.Platform__c == 'WhatsApp'
            );
        } else if (tabName == 'FaceBook') {
            selectedWhatsappTab.classList.remove("clickcolor");
            selectedfacebookTab.classList.add("clickcolor");
            selectedInstaTab.classList.remove("clickcolor");
            this.openTable = tabName;
            // this.facebookMessageCount = 0; 
            this.filteredMessages = this.messages.filter(message => message.Platform__c == 'FaceBook'
            );
        } else if (tabName == 'Instagram') {
            selectedWhatsappTab.classList.remove("clickcolor");
            selectedfacebookTab.classList.remove("clickcolor");
            selectedInstaTab.classList.add("clickcolor");
            this.openTable = tabName;
            this.filteredMessages = this.messages.filter(message => message.Platform__c == 'Instagram');
        }
    }
    renderedCallback() {
        this.properties = 'set by renderedCallback';
        console.log('properties ' + this.properties);
    }
    formatDateTime(dateTime) {
        const dateObj = new Date(dateTime);
        const options = {
            timeZone: 'Asia/Kolkata',
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        };
        return new Intl.DateTimeFormat('en-GB', options).format(dateObj);
    }

    handleMobileClick(event) {
        const mobile = event.target.dataset.id;
        // Redirect to chat component logic here
        updateRecentseenItems({ Phonenumber: mobile })
            .then((result) => {
                refreshApex(this.wiredRefreshData);
            })
            .catch((error) => {
                console.log('Error while updating the recent message seen');
            })
        this.mobileToChildCom = mobile;
        this.isChatOpen = true;
    }

    mobilehandler() {
        this.isChatOpen = false;
    }
    handlePhoneChange(event) {
        event.preventDefault();
        this.mobileToChildCom = event.target.value;
        console.log(this.mobileToChildCom);
        this.disableButt = false;
    }
    handleChatComp() {
        this.isChatOpen = true;
    }
    // added by jami for executing platform event
    eventName = '/event/WA_Message_Event__e'; // Platform Event
    subscription = {};
    //@track messageCount = 0; // Initialize the message count

    connectedCallback() {
        this.getAllCustomers();
        this.handleErrorRegister();
        this.handleSubscribe();
    }

    disconnectedCallback() {
        this.handleUnSubscribe();
    }
   /* @wire(getRecentMessages)
    getAllRecent(result) {
        this.whatsappMessageCount = 0;
        this.facebookMessageCount = 0;
        this.instagramMessageCount = 0;
        this.wiredRefreshData = result;
        if (result.data) {
            this.error = undefined;
            this.messages = result.data.map(message => {
                if (message.Platform__c == 'WhatsApp') {
                    this.whatsappMessageCount++;
                } else if (message.Platform__c == 'FaceBook') {
                    this.facebookMessageCount++;
                } else if (message.Platform__c == 'Instagram') {
                    this.instagramMessageCount++;
                }
                return {
                    ...message,
                    CreatedDate: this.formatDateTime(message.CreatedDate)
                };
            });
        } else if (result.error) {
            this.error = result.error;
        }
    }*/
   getAllCustomers() {
        getRecentMessages({
        }).then(res => {
            this.messages = res.map(message => {
                if (message.Platform__c == 'WhatsApp') {
                    this.whatsappMessageCount++
                } else if (message.Platform__c == 'FaceBook') {
                    this.facebookMessageCount++
                } else if (message.Platform__c == 'Instagram') {
                    this.instagramMessageCount++
                }
                return {
                    ...message,
                    CreatedDate: this.formatDateTime(message.CreatedDate)
                };
            });
        })
            .catch((error) => {
                console.error('Error While Receiving the Platform Event Message');
            });
    }

    handleSubscribe() {
        subscribe(this.eventName, -1, this.handleSubscribeResponse.bind(this)).then((response) => {
            this.subscription = response;
            console.log('Subscribed to channel ', JSON.stringify(response));
        });
    }

    handleSubscribeResponse(response) {
        console.log('Response from WhatsApp Webhook ', JSON.stringify(response));
        let data = response.data.payload;
        let messageId = data.MessageId__c;
        let customerPhone = data.CustomerPhone__c;
        if (messageId) {
            getSingleMessage({
                recordId: messageId,
                customerPhone: customerPhone
            }).then(res => {
                res.CreatedDate = this.formatDateTime(res.CreatedDate);
                this.messages.unshift(res);
                if (res.Platform__c == 'WhatsApp') {
                    this.whatsappMessageCount++;
                    if (this.openTable == 'WhatsApp') {
                        this.filteredMessages = this.messages.filter(message => message.Platform__c == 'WhatsApp');
                    }
                    //this.openTable = true;

                } else if (res.Platform__c == 'FaceBook') {
                    this.facebookMessageCount++;
                    if (this.openTable == 'FaceBook') {
                        this.filteredMessages = this.messages.filter(message => message.Platform__c == 'FaceBook');
                    }

                    // this.filteredMessages = this.messages.filter(message => message.Platform__c == 'FaceBook');
                } else if (res.Platform__c == 'Instagram') {
                    this.instagramMessageCount++;
                    if (this.openTable == 'Instagram') {
                        this.filteredMessages = this.messages.filter(message => message.Platform__c == 'Instagram');
                    }
                    // this.filteredMessages = this.messages.filter(message => message.Platform__c == 'Instagram');
                }
                // { currentTarget: { getAttribute: () => tabName } }

            })
                .catch((error) => {
                    console.error('Error While Receiving the Platform Event Message');
                });
        }
        this.messages = [...this.messages];
    }
    handleUnSubscribe() {
        unsubscribe(this.subscription);
    }

    handleErrorRegister() {
        onError((error) => {
            console.error('Received error from server: ', JSON.stringify(error));
        });
    }

}