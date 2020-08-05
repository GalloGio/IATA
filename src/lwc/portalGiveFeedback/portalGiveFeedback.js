import { LightningElement,track,api } from 'lwc';

import CSP_Give_Feedback_Message from '@salesforce/label/c.CSP_Give_Feedback_Message';
import CSP_Give_Feedback_Title from '@salesforce/label/c.CSP_Give_Feedback_Title';
import CSP_Give_Feedback_ButtonLabel from '@salesforce/label/c.CSP_Give_Feedback_ButtonLabel';
export default class PortalGiveFeedback extends LightningElement {

    @track label={
        CSP_Give_Feedback_Message,
        CSP_Give_Feedback_Title,
        CSP_Give_Feedback_ButtonLabel
    };
    @track isExpanded=false;


    @track _topic;
    @track _countryValue;
    @track _isFirstLevelUser;
    @track _topicEN;
    @track _userInfo;

    @api 
    get topic(){
        return this._topic;
    }
    set topic(val){
        this._topic=val;
    }
    @api 
    get countryValue(){
        return this._countryValue;
    }
    set countryValue(val){
        this._countryValue=val;
    }
    @api 
    get isFirstLevelUser(){
        return this._isFirstLevelUser;
    }
    set isFirstLevelUser(val){
        this._isFirstLevelUser=val;
    }
    @api 
    get topicEn(){
        return this._topicEn;
    }
    set topicEn(val){
        this._topicEn=val;
    }
    @api 
    get userInfo(){
        return this._userInfo;
    }
    set userInfo(val){
        this._userInfo=val;
    }


    expandCmp(){
        this.isExpanded=true;
    }
}