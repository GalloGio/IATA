import { LightningElement,api,track } from 'lwc';
 
export default class PortalSupportContactUsFooter extends LightningElement {

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

   
    get showGiveFeedback(){
        return this._topic!=null;
    }
    connectedCallback(){
        console.log('done');
    }



}