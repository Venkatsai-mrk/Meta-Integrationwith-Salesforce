import { LightningElement, track, wire, api } from 'lwc';
import listAllMessages from '@salesforce/apex/WhatsAppLWCService.listAllMessages';
import sendTextMessage from '@salesforce/apex/WhatsAppLWCService.sendTextMessage';
import sendTextMessageToFaceBook from '@salesforce/apex/WhatsAppLWCService.sendTextMessageToFaceBook';
import sendTextMessageToInstagram from '@salesforce/apex/WhatsAppLWCService.sendTextMessageToInstagram';
import getSingleMessage from '@salesforce/apex/WhatsAppLWCService.getSingleMessage';
import { RefreshEvent } from 'lightning/refresh';

import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class Chatcomponent extends LightningElement {
    @track messages = [];
    @track errorDetails;
    @api isModalOpen = false;
    showMessages = false;
    isSpinner = false;
    @api phone;
    messageText;
    eventName = '/event/WA_Message_Event__e'; //PE
    subscription = {};
    customerNameforHeader;
    connectedCallback() {
        this.handleErrorRegister();
        this.handleSubscribe();
        this.handleChat();
    }

    disconnectedCallback() {
        this.handleUnSubscribe();
    }

    closeModal() {
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('mobileclick'));
    }

    handleUnSubscribe() {
        //unsubscribe(this.subscription)
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

        if (this.phone === customerPhone) {
            getSingleMessage({
                recordId: messageId,
                customerPhone: customerPhone
            }).then(res => {
                res.CreatedDate = this.formatDate(res.CreatedDate);
                this.messages.push(res);
                console.log('res@', JSON.stringify(res));
                this.customerNameforHeader = res?.CustomerName__c;
                this.dispatchEvent(new RefreshEvent());
            })
                .catch((error) => {
                    console.error('Error While Receiving the Platform Event Message');
                })
                .finally(() => {
                    let chatArea = this.template.querySelector('.chatArea');
                    if (chatArea) {
                        chatArea.scrollTop = chatArea.scrollHeight;
                    }
                });
        }
        this.messages = [...this.messages];
    }

    handleErrorRegister() {
        onError((error) => {
            console.error('Received error from server: ', JSON.stringify(error));
        });
    }

    handlePhoneChange(event) {
        event.preventDefault();
        this.phone = event.target.value;
        console.log(this.phone);
    }

    handleChat() {
        console.log(this.phone);

        if (this.handleValidate()) {
            this.isSpinner = true;

            listAllMessages({
                customerPhone: this.phone
            })
                .then((result) => {
                    console.log('result@@', JSON.stringify(result));
                    this.messages = result.map(msg => ({
                        ...msg,
                        CreatedDate: this.formatDate(msg.CreatedDate)
                    }));
                    this.customerNameforHeader = result[0]?.CustomerName__c;
                    this.showMessages = true;
                })
                .catch((errors) => {
                    this.errorDetails = errors;
                    this.showMessages = false;
                })
                .finally(() => {
                    let chatArea = this.template.querySelector('.chatArea');
                    if (chatArea) {
                        chatArea.scrollTop = chatArea.scrollHeight;
                    }
                    this.isSpinner = false;
                    this.setUpChatMessage();
                });
        } else {
            return;
        }
        this.messages = [...this.messages];
    }
    setUpChatMessage() {
        let chatInput = this.template.querySelector(".chat-input");
        if (chatInput) {
            chatInput.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    this.handleSendMessage();
                }
            });
        }
    }
    handleSendMessage() {
        let allValid = this.handleValidate();
        let lastPlatform = null;
        // getting platform of last message
        for (let i = this.messages.length - 1; i >= 0; i--) {
            if (this.messages[i].Platform__c) {
                lastPlatform = this.messages[i].Platform__c;
                console.log('lastPlatform@--', JSON.stringify(lastPlatform));
                break;
            }
        }
        console.log('lastPlatform@', JSON.stringify(lastPlatform));
        // console.log(JSON.stringify(this.messages));
        if (allValid) {
            this.isSpinner = true;

            // calling apex based on platform - whatsapp, instagram, facebook
            if (lastPlatform == 'WhatsApp') {
                sendTextMessage({
                    messageContent: this.messageText,
                    toPhone: this.phone
                }).then((result) => {
                    result.CreatedDate = this.formatDate(result.CreatedDate);
                    this.messages.push(result);
                })
                    .catch((errors) => {
                        console.log('errors', JSON.stringify(errors));
                        this.errorDetails = errors;
                    })
                    .finally(() => {
                        let chatArea = this.template.querySelector('.chatArea');
                        if (chatArea) {
                            chatArea.scrollTop = chatArea.scrollHeight;
                        }
                        this.isSpinner = false;
                        this.messageText = '';
                    });
            } else if (lastPlatform == 'FaceBook') {
                sendTextMessageToFaceBook({
                    messageContent: this.messageText,
                    toSenderId: this.phone
                }).then((result) => {
                    result.CreatedDate = this.formatDate(result.CreatedDate);
                    this.messages.push(result);
                })
                    .catch((errors) => {
                        console.log('errors', JSON.stringify(errors));
                        this.errorDetails = errors;
                    })
                    .finally(() => {
                        let chatArea = this.template.querySelector('.chatArea');
                        if (chatArea) {
                            chatArea.scrollTop = chatArea.scrollHeight;
                        }
                        this.isSpinner = false;
                        this.messageText = '';
                    });
            } else if (lastPlatform == 'Instagram') {
                sendTextMessageToInstagram({
                    messageContent: this.messageText,
                    toSenderId: this.phone
                }).then((result) => {
                    result.CreatedDate = this.formatDate(result.CreatedDate);
                    this.messages.push(result);
                })
                    .catch((errors) => {
                        console.log('errors', JSON.stringify(errors));
                        this.errorDetails = errors;
                    })
                    .finally(() => {
                        let chatArea = this.template.querySelector('.chatArea');
                        if (chatArea) {
                            chatArea.scrollTop = chatArea.scrollHeight;
                        }
                        this.isSpinner = false;
                        this.messageText = '';
                    });
            }
            this.messages = [...this.messages];
        }
    }

    handleChange(event) {
        event.preventDefault();
        this.messageText = event.target.value;
    }

    handleAnotherChat() {
        this.messageText = '';
        this.showMessages = false;
        this.messages = undefined;
    }

    handleValidate() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const options = {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        };
        return new Intl.DateTimeFormat('en-US', options).format(date);
    }
}