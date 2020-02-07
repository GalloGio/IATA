import { LightningElement, track } from 'lwc';
import {TABLE_TYPE_GROUP, TABLE_TYPE_DETAIL, TABLE_GROUP_COLUMNS, TABLE_DETAIL_COLUMNS} from './adsrSearchResultConstants.js';
import getReport from '@salesforce/apex/ADSRController.getReport';

export default class AdsrSearchResult extends LightningElement {
    
    @track _tableData;

    get tableData(){
        let reducer = (accumulator = [], currentValue) => [...accumulator, ...currentValue];
        console.log(JSON.parse(JSON.stringify(this._tableData.map(function(e){return [...e.details];}).reduce(reducer))) );
        return this.hasResults ? 
            (TABLE_TYPE_GROUP === this.tableType ?
                this._tableData :
                this._tableData.map(function(e){return [...e.details];}).reduce(reducer) ) :
            [];
    }

    //tableType can be group or detail
    @track tableType = 'detail';

    get tableColumns(){
        return TABLE_TYPE_GROUP === this.tableType ? 
                TABLE_GROUP_COLUMNS : 
                TABLE_DETAIL_COLUMNS;
    }

    connectedCallback(){
        console.log(TABLE_TYPE_GROUP)
        getReport().then(data => {
            console.log(data);
            this._tableData = data.groups;
        }).catch( error => {
            console.log(error);
        });
        
    }

    get hasResults(){
        return this._tableData !== undefined 
                && this._tableData !== null 
                && this._tableData.length > 0;
    }

}