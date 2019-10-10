import { LightningElement, track } from 'lwc';

import getProficiencyReport from '@salesforce/apex/portalIftpHistoryManagement.getProficiencyReport';
import getUserInfo from '@salesforce/apex/PortalIftpUtils.getUserInfo';
import getAllITP from '@salesforce/apex/PortalIftpUtils.getAllITP';
import isCommunity from '@salesforce/apex/PortalIftpUtils.isCommunity';

export default class portalIftpProficiencyReports extends LightningElement {

    @track dataRecords = false;
    @track loading = true;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columns;
    @track sortedBy;
    @track sortedDirection;
    @track selectedRows;
    fieldLabels = [
        'uniqueRowId','certificationId','account_contact_role_Id','firstName', 'lastName', 'companyNumber', 'trainingName', 'itpName', 'expirationDate', 'proficiency', 'station', 'setProficiency'
    ];

    @track showSearch = false;
    @track itpValue;
    @track monthValue;
    @track yearValue;
    
    @track itpOptions;
    
    @track showDatatableButtons = false;
           userInfo; 

    get monthOptions() {
        return [
            { label: 'January', value: '1' },
            { label: 'February', value: '2' },
            { label: 'March', value: '3' },
            { label: 'April', value: '4' },
            { label: 'May', value: '5' },
            { label: 'June', value: '6' },
            { label: 'July', value: '7' },
            { label: 'August', value: '8' },
            { label: 'September', value: '9' },
            { label: 'October', value: '10' },
            { label: 'Novemver', value: '11' },
            { label: 'December', value: '12' }
        ];
    }

    get yearOptions() {
        let today = new Date();
        let yearToday = today.getFullYear();
        let options = [];

        for(let i = yearToday; i >= 2000; i--){
            options.push({label: ''+i,value: ''+i});
        }

        return options;
    }
    

    get dataRecords() {
        return this.dataRecords;
    } 

    connectedCallback() {

        let today = new Date();
        let yearToday = today.getFullYear();
        let monthToday = today.getMonth()+1;
        
        this.yearValue = ''+yearToday; //Set picklist to current year
        this.monthValue = ''+monthToday; //Set picklist to current year

        isCommunity()
            .then(result =>{
                let myResult = JSON.parse(JSON.stringify(result));
                if(myResult){
                    
                    getUserInfo()
                        .then(result2 =>{
                            let myResult2 = JSON.parse(JSON.stringify(result2));
                            if(myResult2){
                                this.userInfo = myResult2;
                     
                                if(this.userInfo.profile === 'ISS Portal (Partner)' || this.userInfo.profile === 'ISS Portal Delegated Admin User'){
                                    this.itpOptions =  [
                                            { label:  this.userInfo.accountName, value:  this.userInfo.accountName }
                                        ];
                                }
                                this.itpValue = this.userInfo.accountName;
                            }
                        })
                        .catch(error => {
                            console.error('portalIftpProficiencyReports - getUserInfo - Error : ' + error);
                            this.mainErrorMessage = error;
                            this.error = error;
                        });  
        
                        this.columns = [
                            {label: 'ITP', fieldName: 'ITP_name', type: 'text', sortable: true},
                            // {label: 'Account Id', fieldName: 'accountId', type: 'text', sortable: true},
                            {label: 'Modules', fieldName: 'numberModules', type: 'text', sortable: true},
                            {label: 'Employees', fieldName: 'numberEmployees', type: 'text', sortable: true},
                            {label: 'Month', fieldName: 'reqMonth', type: 'text', sortable: true},
                            {label: 'Year', fieldName: 'reqYear', type: 'text', sortable: true}
                        ];

                }else{
                    getAllITP()
                        .then(result2 => {
                            let myResult2 = JSON.parse(JSON.stringify(result2));
        
                            let myTopicOptions = [];
        
                            myTopicOptions.push({ label:'-- All ITP --', value:'All'});

                            Object.keys(myResult2).forEach(function (el) {
                                myTopicOptions.push({ label:myResult2[el].Name, value:myResult2[el].Name});
                            });
                            this.itpOptions = this.sortData('label', 'asc', myTopicOptions);
                            this.cleanErrors();
                        })
                        .catch(error => {
                            console.error('portalIftpProficiencyReports - getAllITP - Error : ' + error);
                            this.mainErrorMessage = error;
                            this.error = error;
                        });  

                        this.columns = [
                            {label: 'ITP', fieldName: 'ITP_name', type: 'text', sortable: true},
                            {label: 'Account Id', fieldName: 'accountId', type: 'text', sortable: true},
                            {label: 'Modules', fieldName: 'numberModules', type: 'text', sortable: true},
                            {label: 'Employees', fieldName: 'numberEmployees', type: 'text', sortable: true},
                            {label: 'Month', fieldName: 'reqMonth', type: 'text', sortable: true},
                            {label: 'Year', fieldName: 'reqYear', type: 'text', sortable: true}
                        ];
                }
            })
            .catch(error => {
                console.error('portalIftpProficiencyReports - getAllITP - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  
        
    }

    handleChangeMonth(event) {
        this.monthValue = event.detail.value;
    }
    handleChangeYear(event) {
        this.yearValue = event.detail.value;
    }

    handleChangeITP(event) {
        this.itpValue = event.detail.value;
    }
    
    handleSearchButtonClick(){
       

            this.showSearch = true;
            this.handleSearch();
       
    }


    handleResetButtonClick(){
        this.showSearch = false;
        this.data = null;
        this.itpValue = null;
        this.monthValue = null;
        this.yearValue = null;
        this.error = '';
        this.mainErrorMessage = '';
    }

    handleCancel(){
        this.handleResetButtonClick();
    }



    handleSearch(){
        
        this.loading = true;

        if(this.itpValue !== 'All'){
        
            getProficiencyReport({itpName: this.itpValue, monthValue: this.monthValue, yearValue: this.yearValue})
            .then(results => {
                if(results && results.length > 0) {
                    
                    this.data = results;
                    this.dataRecords = true;
                    this.loading = false;
                
                }  else {
                    this.dataRecords = false;
                    this.loading = false;
                }   
                this.cleanErrors();
            })
            .catch(error => {
                console.error('getProficiencyReport - Error : ', error);
                this.mainErrorMessage = error;
                this.error = error;
                this.loading = false;
                this.dataRecords = false;
            });  

        }else{
            let itps = JSON.parse(JSON.stringify(this.itpOptions));

            let itpsResults = [];
          
            for(let i = 0 ; i < itps.length; i++){
                
                if(itps[i].value !== 'All'){
                    getProficiencyReport({itpName: itps[i].value, monthValue: this.monthValue, yearValue: this.yearValue})
                        .then(results => {
                            if(results && results.length > 0){

                                if(this.data){
                                    itpsResults = JSON.parse(JSON.stringify(this.data));
                                }
                                if(itpsResults.length > 0){
                                    for(let i = 0; i < results.length; i++){
                                        itpsResults.push( results[i] );
                                    };
                                }else{
                                    itpsResults = results;
                                }
                             
                            }   

                            if(itpsResults.length > 0){
                                    this.data = itpsResults;
                                    this.dataRecords = true;
                                    this.loading = false;
                            }else{
                                this.dataRecords = false;
                            }

                            this.cleanErrors();
                        })
                        .catch(error => {
                            console.error('getProficiencyReport - Error : ', error);
                            this.mainErrorMessage = error;
                            this.error = error;
                            this.loading = false;
                            this.dataRecords = false;
                        });  
                }
            }
            
        }
        
    }
    cleanErrors(){
        this.error = '';
        this.mainErrorMessage = '';
    }


    /*******************************************************************************
    *                                                                              *
    *  Sorting Methods                                                             *
    *                                                                              *
    * ******************************************************************************/
    // The method onsort event handler
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        let auxdata = JSON.parse(JSON.stringify(this.data));
        this.data = this.sortData(fieldName, sortDirection, auxdata);
    }

    sortData(fieldName, sortDirection, auxdata) {
        let reverse = sortDirection !== 'asc';
        auxdata = Object.assign([],auxdata.sort(this.sortBy(fieldName, reverse ? -1 : 1)));
        return auxdata;
    }

    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa')} :
            function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'aaa'};
     
        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        }
    }

    /*******************************************************************************
    *                                                                              *
    *  Methods to handle data export                                               *
    *                                                                              *
    * ******************************************************************************/

    handleExportToCsv(){
        let columns = JSON.parse(JSON.stringify(this.columns));
        let data = JSON.parse(JSON.stringify(this.data));
        this.template.querySelector('c-portal-iftp-export-data').exportDataToCsv(columns, data, "TrainingRecordsDetailSearchResults.csv");
    }

    handleExportToExcel(){
        let columns = JSON.parse(JSON.stringify(this.columns));
        let data = JSON.parse(JSON.stringify(this.data));
        this.template.querySelector('c-portal-iftp-export-data').exportDataToExcel(columns, data, "EmployeesSearchResults.xls");
    }
}