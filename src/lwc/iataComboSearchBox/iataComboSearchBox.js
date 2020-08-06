import { LightningElement,api,track } from 'lwc';
 
export default class IataComboSearchBox extends LightningElement {

    @api
        get topicList(){
            return this.currentTopicList;
        }
        set topicList(val){
            this._topicList=val;
            this.currentTopicList=val;
        }
    @track currentTopicList=[];
    @track _topicList=[];

    @api
        get recentTopicList(){
            return this._recentTopicList;
        }
        set recentTopicList(val){
            this._recentTopicList=val;
        }
    @track _recentTopicList=[];
    @track selectedValue='';
    @track inputValue='';
    @track searchMode=false;

    expandList(){

        this.template.querySelector('[role="combobox"]').classList.add('slds-is-open');
    }

    get showRecentTopics(){
        return !this.searchMode;
    } 

    colapseList(){
        this.inputValue=this.selectedValue;
        
        this.searchMode=false;
        this.currentTopicList=this._topicList;
        this.template.querySelector('[role="combobox"]').classList.remove('slds-is-open');
    }

    handleSelectedOption(event){
        this.selectedValue = event.target.dataset.label;
        this.inputValue = event.target.dataset.label;
        this.colapseList();
        let val = event.target.dataset.value;
              
        this.dispatchEvent(new CustomEvent("change", {detail : {value:val} }));
        this.searchMode=false;
        this.currentTopicList=this._topicList;
    }

    handleKeyUp(event){
        let searchText= event.target.value.trim();
        
        clearTimeout(this.timeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
        this.inputValue=searchText;
        this.searchMode=searchText.length>0;

            if(searchText.length>=3){

                let keywordList= searchText.toLowerCase().split(' ').filter(function(el) {return el != ' '});
                let tpList = this._topicList.filter(item =>{return keywordList.some(elem => item.label.toLowerCase().includes(elem)) })
                this.currentTopicList=tpList;
            }
        }, 500, this);
        console.log(searchText)
    }

}