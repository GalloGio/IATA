import { LightningElement,track,wire,api } from 'lwc';


import getDocumentSubscribers from '@salesforce/apex/subscriberListCtrl.getDocumentSubscribers';

 
export default class SubscriberList extends LightningElement {

    @api recordId;

    @track loading=true;
    @track recordList=[];
    @track totalNrRecs=0;
    @track hasResults=false;
    @track sortedBy='userUrl';
    @track sortDirection='asc';
    @track defaultSortDirection='asc';

    @track eventLoading={};

    searchObj={
        sortField:'Name',
        sortDirection:'asc',
        requestedPage:1
    };
    @track searchObjStr=JSON.stringify(this.searchObj);

    columns = [   
        { label: 'Name', 
        fieldName: 'userUrl',
        type: 'url',
        sortable:true,
        sortfldName:'Name',
        typeAttributes: { label : {fieldName: 'Name'},target:'_workspaceTab'}},
        { label: 'Title',  sortfldName:'Contact.Title',fieldName: 'title',sortable:true},
        { label: 'Category',sortfldName:'Contact.Account.Category__C', fieldName: 'category',sortable:true},       
        { label: 'Country', sortfldName:'Contact.Account.IATA_ISO_Country__r.Name',fieldName: 'country',sortable:true},
        { label: 'Language', fieldName: 'language',sortfldName:'LanguageLocaleKey',sortable:true},
        { label: 'Portal Status',  sortfldName:'Contact.User_Portal_Status__c',fieldName: 'pstatus',sortable:true}
    ];

    @wire(getDocumentSubscribers, { docId: '$recordId',searchDtl:'$searchObjStr'})
    subsData(result){
       
        if(result.data){
            this.hasResults=result.data.records.length>0;
            let data =JSON.parse(JSON.stringify(result.data));
            this.totalNrRecs=this.searchObj.requestedPage==1?data.totalItemCount: this.totalNrRecs;
            this.recordList=data.records;
            this.recordList.forEach(el=>{
                el.Name=el.Contact?el.Contact.Name:el.Name;
                el.userUrl='/'+(el.Contact?el.Contact.Id:el.Id);
                
                if(el.Contact){
                    el.accountName=el.Contact.Account.Name;
                    el.accountUrl='/'+el.Contact.AccountId;
                    el.category=el.Contact.Account.Category__c;
                    el.country=el.Contact.Account.IATA_ISO_Country__r.Name;
                    el.pstatus=el.Contact.User_Portal_Status__c;
                    el.title=el.Contact.Title;
                  }
            });


            if (data.records.length >= this.totalNrRecs) {
                this.eventLoading.enableInfiniteLoading = false;
            }

           this.eventLoading.isLoading = false;
        }
        this.loading=false;
    }

    onHandleSort(event) {
        this.loading=true;
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy=sortedBy;
        this.sortDirection=sortDirection;

        let fldName=this.columns.find(el=>el.fieldName==sortedBy).sortfldName;
        this.searchObj.sortField=fldName;
        this.searchObj.sortDirection=sortDirection;
        this.searchObjStr=JSON.stringify(this.searchObj);
       
    }

    loadMoreData(event) {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        this.eventLoading=event.target;

        this.searchObj.requestedPage+=1;
        this.searchObjStr=JSON.stringify(this.searchObj);
    }
    get CardTitle(){
        return 'Subscribers '+(this.totalNrRecs>=0?'('+this.totalNrRecs+')':'');
    }

    


}