import { LightningElement,track,api } from 'lwc';


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_SearchFAQ from '@salesforce/label/c.CSP_SearchFAQ';
 
export default class PortalSearchBox extends LightningElement {

    @api 
        set nrChar(val){
            this._nchar=val;
        }

        get nrChar(){
            return this._nchar;
        }

    @track searchText='';
   
    @track _nchar=3;


    @track label = {
        CSP_SearchFAQ
    }


    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';




    onInputChange(event){
        let keyword=event.detail.value;
        this.triggerSearch(keyword);
        
    }

    triggerSearch(keyword){
        this.searchText=keyword;
        let nch= this.nrChar;
        clearTimeout(this.timeout);

        this.timeout = setTimeout(() => {
          
            if(this.searchText.length >=nch ||this.searchText === '') {
                this.dispatchEvent(new CustomEvent('searchword', { detail: { key: this.searchText } }));// sends to parent the nr of records
            }
        }, 1500, this);
    }
    
    removeTextSearch(){
        this.searchText='';
        this.dispatchEvent(new CustomEvent('searchword', { detail: { key: this.searchText } }));// sends to parent the nr of records
            
    }

    get showCross(){
        return this.searchText.length>0;
    }
}