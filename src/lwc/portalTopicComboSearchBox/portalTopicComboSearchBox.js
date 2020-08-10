import { LightningElement,api,track } from 'lwc';
 
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_Contacts_NoResults_text1 from '@salesforce/label/c.CSP_Contacts_NoResults_text1';
import CSP_Topic_Recent_Label from '@salesforce/label/c.CSP_Topic_Recent_Label';
import CSP_Topic_All_Label from '@salesforce/label/c.CSP_Topic_All_Label';
import CSP_Select_Topic_Placeholder from '@salesforce/label/c.CSP_Select_Topic_Placeholder';

export default class portalTopicComboSearchBox extends LightningElement {

    @api
        get topicList(){
            return this.currentTopicList;
        }
        set topicList(val){
            this._topicList=val;
            this.currentTopicList=val;
            if(this.selectedValue.value!==undefined){
                let item =this._topicList.filter(obj => {return obj.value === val})[0];
                this.selectedValue=item;
                this.inputValue=item.label; 
            }

        }
    @track currentTopicList=[];
    @track _topicList=[];
    @track label={
        CSP_Contacts_NoResults_text1,
        CSP_Topic_Recent_Label,
        CSP_Topic_All_Label,
        CSP_Select_Topic_Placeholder
    }
    

    @api
        get recentTopicList(){
            return this._recentTopicList;
        }
        set recentTopicList(val){
            this._recentTopicList=val;
        }

     @api
        get selectValue(){
            return this.selectedValue;
        }
        set selectValue(val){
            if(this.topicList.length>0){
                let item =this.topicList.filter(obj => {return obj.value === val})[0];
                this.selectedValue=item;
                this.inputValue=item.label; 
            }else{
                this.selectedValue={value:val};
            }
        } 

    @track _recentTopicList=[];
    @track selectedValue={};
    @track inputValue='';
    @track searchMode=false;
    

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';


    expandList(){
        this.inputValue='';
        this.template.querySelector('[role="combobox"]').classList.add('slds-is-open');
    }

    get showRecentTopics(){
        return !this.searchMode;
    } 

    get showTopicList(){
        return this.currentTopicList.length>0;
    } 

    colapseList(){

        this.inputValue=this.selectedValue.label!==undefined?this.selectedValue.label:'' ;
        
        this.searchMode=false;
        this.currentTopicList=this._topicList;
        this.template.querySelector('[role="combobox"]').classList.remove('slds-is-open');
    }

    handleSelectedOption(event){
        
        
        this.selectedValue={label:event.target.dataset.label, value: event.target.dataset.value}
        this.inputValue = this.selectedValue.label;
        this.colapseList();
        let val = event.target.dataset.value;
              
        this.dispatchEvent(new CustomEvent("change", {detail : {value:val} }));
        this.searchMode=false;
        this.currentTopicList=this._topicList;
    }

    handleKeyUp(event){
        let searchText= event.target.value;
        
        clearTimeout(this.timeout);

        this.timeout = setTimeout(() => {
        this.inputValue=searchText;
        searchText=searchText.trim();
        this.searchMode=searchText.length>0;

            if(searchText.length>=3){

                let keywordList= searchText.toLowerCase().split(' ').filter(function(el) {return el != ' '});
                let tpList = this._topicList.filter(item =>{return keywordList.some(elem => item.label.toLowerCase().includes(elem)) })
                this.currentTopicList=tpList;
            }else if(searchText.length==0){
                this.currentTopicList=this._topicList;
            }
        }, 500, this);
        console.log(searchText)
    }

}