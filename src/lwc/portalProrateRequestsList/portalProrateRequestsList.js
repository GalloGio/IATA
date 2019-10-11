import { LightningElement, track } from 'lwc';

/**
 * Apex classes imports
 */
import getListViewNameList from '@salesforce/apex/ISSP_Baggage_Proration.getListViewNameList';
import getRequests from '@salesforce/apex/ISSP_Baggage_Proration.getRequests'

export default class PortalProrateRequestsList extends LightningElement {

    /**
     * Combobox variables
     */
    @track portalStatus = ''; //Selected value of the combobox
    @track portalStatusOptionsmap;
    @track portalStatusOptions; //List of options for the combobox
    @track checkNavigation;

    /**
     * Data table variables
     */
    @track data; //data to show in the data table
    @track columns; //Columns to show in the data table
    @track sortedBy;
    @track sortedDirection;

    /**
     * Logical variables
     */
    @track dataRecords = false;
    @track loading = true; //Handles the loading of the page
    @track error = false; //Handles the error
    @track showForm = false;
    @track IdPIRForm; //Id to handle the form data

    @track isActionEdit = false;
    @track isActionView = false;

    /**
     * Executed on component opening
     */
    connectedCallback() {
        console.log('[PortalProrateRequestsList] connectedCallback : INIT');
        this.buildDataTableColumns();
        this.fetchPortalStatusOptions();
    }

    onCheckNavigation(){
        this.checkNavigation = !this.checkNavigation ;
    }
    removeButtonSave(){
        console.log("removeButtonSave")
        this.loading = false;
        this.isActionEdit = false ;
    }

    /**
     * Get's all the options available for the combobox
     */
    fetchPortalStatusOptions() {
        this.loading = true;
        getListViewNameList()
            .then(results => {
                var returnedValues = results;
                if (returnedValues != null && returnedValues.listViewValues.length > 0) {
                    this.portalStatusOptions = this.formatComboboxValues(returnedValues.listViewValues);
                    this.portalStatusOptionsmap = returnedValues.mapListView;
                    this.portalStatus = this.portalStatusOptions[0].label;
                    this.fetchRequests(this.portalStatus, this.portalStatusOptionsmap);
                }
            })
            .catch(error => {
                this.error = true;
                console.log('handleSearch - Error : ', error);
            });
    }

    handleBackClick() {
        console.log('handleBackClick');
        this.showForm = false;
    }
    /**
     * Get's all the data for the data table
     * @param {*} filter 
     */
    fetchRequests(filter, listViewMap, sortExpression, sortDirection) {
        getRequests({
                selectedValue: filter,
                mapListView: listViewMap,
                sortExpression: sortExpression,
                sortDirection: sortDirection
            })
            .then(results => {
                // let returnedValues = results;
                let returnedValues = JSON.parse(JSON.stringify(results));;
                
                if (returnedValues && returnedValues.length > 0) {

                    returnedValues = returnedValues.map(
                        record => Object.assign(
                            { "PIR_Total_Prorated_Amount_Due__c": '0' },
                            record
                        )
                    );
                    for(let i = 0; i < returnedValues.length; i++){
                        
                        console.log('returnedValues[i]: ',i);
                        console.log('returnedValues[i].Days_to_Go_vs_60_Day_Limit__c: ',returnedValues[i].Days_to_Go_vs_60_Day_Limit__c);
                        console.log('returnedValues[i].Days_to_Go_vs_60_Day_Limit__c.toString(): ',returnedValues[i].Days_to_Go_vs_60_Day_Limit__c.toString());
                        console.log('returnedValues[i].PIR_Total_Prorated_Amount_Due__c: ',returnedValues[i].PIR_Total_Prorated_Amount_Due__c);
                        console.log('returnedValues[i].PIR_Total_Prorated_Amount_Due__c.toString(): ',returnedValues[i].PIR_Total_Prorated_Amount_Due__c.toString());

                        returnedValues[i].Days_to_Go_vs_60_Day_Limit__c = returnedValues[i].Days_to_Go_vs_60_Day_Limit__c == null ? '0':returnedValues[i].Days_to_Go_vs_60_Day_Limit__c.toString();
                        returnedValues[i].PIR_Total_Prorated_Amount_Due__c = returnedValues[i].PIR_Total_Prorated_Amount_Due__c == null || typeof(returnedValues[i].PIR_Total_Prorated_Amount_Due__c) == 'undefined' ? '0':returnedValues[i].PIR_Total_Prorated_Amount_Due__c.toString();
                        
                        

                    }
                    
                    console.log('returnedValues: ',returnedValues);

                    this.data = returnedValues;
                    this.dataRecords = true;
                } else {
                    this.dataRecords = false;
                }
                this.loading = false;
            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                console.log('handleSearch - Error : ', error);
            });
    }

    /**
     * Transforms a list of strings in a object for the combobox
     * @param {*} stringList 
     */
    formatComboboxValues(stringList) {
        var object = [];

        for (var i = 0; i < stringList.length; i++) {
            object = [...object, { value: stringList[i], label: stringList[i] }];
        }

        return object;
    }

    /**
     * Builds the columns for the data table
     */
    buildDataTableColumns() {
        this.columns = [{
                label: '',
                type: 'button-icon',
                initialWidth: 10,
                typeAttributes: {
                    iconName: 'action:preview',
                    title: 'View',
                    name: 'view',
                    variant: 'border-filled',
                    alternativeText: 'View'
                }
            },
            {
                label: '',
                type: 'button-icon',
                initialWidth: 10,
                typeAttributes: {
                    iconName: 'action:edit',
                    title: 'Edit',
                    name: 'edit',
                    variant: 'border-filled',
                    alternativeText: 'Edit'
                }
            },
            { label: 'Request Nº', fieldName: 'Name', type: 'text', sortable: true },
            { label: 'PIR File Ref.', fieldName: 'PIR_File_Ref__c', type: 'text', sortable: true },
            { label: 'Airline issuing', fieldName: 'Airline_issuing__c', type: 'text', sortable: true },
            { label: 'Airline receiving', fieldName: 'Airline_receiving_formula__c', type: 'text', sortable: true },
            { label: 'Passenger\'s First Name', fieldName: 'Passenger_s_First_Name__c', type: 'text', sortable: true },
            { label: 'Passenger\'s Last  Name', fieldName: 'Passenger_s_Last_Name__c', type: 'text', sortable: true },
            { label: 'Days to Go vs 60-Day-Limit', fieldName: 'Days_to_Go_vs_60_Day_Limit__c', type: 'text', sortable: true },
            { label: 'Request Sent Date', fieldName: 'Request_Sent_Date_Formated__c', type: 'text', sortable: true },
            { label: 'Total Prorated Amount', fieldName: 'PIR_Total_Prorated_Amount_Due__c', type: 'amount', sortable: true },
            { label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true }
        ];
    }

    /**
     * Handles the onchange event for the combobox
     * @param {*} event 
     */
    handlePortalStatusChange(event) {
        this.portalStatus = event.detail.value;
        this.fetchRequests(this.portalStatus, this.portalStatusOptionsmap);
    }

    /**
     * Handles the sorting of the columns in the data table
     * @param {*} event 
     */
    handleColumnSorting(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.fetchRequests(this.portalStatus, this.portalStatusOptionsmap, this.sortedBy, this.sortedDirection);
    }

    /**
     * Handles the row actions in the data table
     * @param {*} event 
     */
    handleRowActiontabs(event) {
        console.log("handleRowAction");
        const row = JSON.parse(JSON.stringify(event.detail.row));
        const { Id } = row;
        this.IdPIRForm = Id;
        this.showForm = true;
        const actionName = event.detail.action.name;

        switch (actionName) {
            case 'edit':
                this.isActionEdit = true;
                break;
            case 'view':
                this.isActionEdit = false;
                break;
            default:
        }
    }
    handleSaveChldClick() {
        this.loading = true;
        this.template.querySelector('c-portal-prorate-requests-form').fetchUpdateClaim();
    }
    handleCancelChldClick(){
        this.isActionEdit = false;
        this.template.querySelector('c-portal-prorate-requests-form').reloadAgainNotEdit();

    }    
    handleEditChldClick(){
        this.template.querySelector('c-portal-prorate-requests-form').reloadAgainEdit();
        this.isActionEdit = true;
    }        
    onRemoveLoading(){
        this.loading = false;
    }

}