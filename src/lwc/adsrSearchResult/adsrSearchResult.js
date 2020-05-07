import { LightningElement, track, wire } from 'lwc';
import{ CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { TABLE_TYPE_GROUP, TABLE_TYPE_DETAIL,TABLE_GROUP_COLUMNS,
			TABLE_DETAIL_COLUMNS } from './adsrSearchResultConstants.js';
import getMarkets from '@salesforce/apex/ADSRController.getMarkets';
import getReport from '@salesforce/apex/ADSRController.getReport';

import PortalIcons from '@salesforce/resourceUrl/PortalIcons';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';

export default class AdsrSearchResult extends LightningElement {
	
	@wire(CurrentPageReference) pageRef;

	searchIcon = `${PortalIcons}#search_colored`;
	filterIcon = `${PortalIcons}#filter`;
	searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
	searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';
	label = {
		CSP_Search_NoResults_text1,
		CSP_Search_NoResults_text2
	};

	exportFilesPath = CSP_PortalPath.replace('s/', '');

	selectedOperation = 0;

	@track _tableType = TABLE_TYPE_GROUP;
	@track _tableData = [];
	@track starting = true;
	@track loading = true;
	@track error = false;
	@track success = false;
	@track airlineInfo = {};
	@track _operation = '';
	@track _errorMessage = null;

	@track searchParams = {
		type: null,
		region: null,
		agent: null
	};
	@track filterParams = {
		market: null,
		service: [],
		iataCode: null,
		markets: []
	}
	@track marketOptions = [];

	@track _displayBackButton = false;

	@track filterFields = [
		{
			type: "picklist",
			name: "region",
			label: "Region",
			options: [],
			disabled: true,
			padding: "around-small",
			class: "slds-text-body_regular text-small",
			dependent: [
				{
					dependency: "options",
					type: "multiselectpicklist",
					disabledOnEmptyOptions: true,
					pillFilters: true,
					displayVertical: true,
					name: "markets",
					label: "Country / Territory",
					options: [],
					padding: "around-small",
					class: "slds-text-body_regular text-small",
					scrollTopOnOpen: true
				},
				{
					dependency: "options",
					type: "multiselectpicklist",
					disabledOnEmptyOptions: true,
					picklist: false,
					displayVertical: false,
					name: "service",
					label: "Service",
					options: [],
					padding: "around-small",
					class: "slds-text-body_regular text-small",
				}
			]
		}
	];

	loadMarkets() {
		getMarkets({region: this.searchParams.region})
		.then(
			data => {
				if(data){
					this.marketOptions = data;
				}
				else {
					this.marketOptions = [];
				}
			}
		)
		.catch(
			error => {
				this.marketOptions = [];
			}
		)
		.finally(
			() => {
				let localFields = JSON.parse(JSON.stringify(this.filterFields));
				let serviceOptions = [];
				serviceOptions.push({
					label: "BSP",
					value: "BSP",
					masterValue: this.searchParams.region
				});
				serviceOptions.push({
					label: "CASS",
					value: "CASS",
					masterValue: this.searchParams.region
				});
				localFields[0].options = [{value: this.searchParams.region, label: this.searchParams.region, selected: true}];
				localFields[0].dependent[1].options = serviceOptions;
				localFields[0].dependent[0].options = this.marketOptions;
				this.filterFields = localFields;
			}
		)
	}

	get tableType() {
		return this._tableType;
	}

	set tableType(t) {
		this._tableType = (t === "agent"  || t === TABLE_TYPE_DETAIL ? "detail" : "group");
	}

	get detailTable() {
		return this.tableType === TABLE_TYPE_DETAIL;
	}

	get operation() {
		return this._tableData !== undefined && this._tableData !== undefined &&
				this._tableData.length > 0 ? 
					this._tableData[this.selectedOperation].operation : null;
	}

	get welcomeAreaTitle() {
		return this.searchParams.type === "agent" ?
			"Search for an IATA Code" :
			"Select for an Operation";
	}

	get welcomeAreaSubtitle() {
		return this.searchParams.type === "agent" ?
			"Please search for an IATA Code to see agent details" :
			"Please select a Region to see assotiated operations";
	}

	get title() {
		return "Airline Default Summary by " + this.searchTypeLabel +
			(this.searchTypeLabel.indexOf("Operation") > -1 && this.detailTable ?
				" " + this.operation :
				"");
	}

	get searchTypeLabel() {
		return this.searchParams.type === "market" ?
			(this.detailTable ?
				"Operation" :
				"Operation") :
			"Agent";
	}

	get tableData(){
		let reducer = (accumulator = [], currentValue) => [...accumulator, ...currentValue];
		if(this.hasResults && this.detailTable && this._tableData !== undefined && this._tableData.groups !== undefined &&
			this._tableData.groups.length > 0 ){
			this._operation = this._tableData.groups[this.selectedOperation].operation;
		}
		else {
			this._operation = '';
		}

		return this.hasResults ? 
			(TABLE_TYPE_GROUP === this.tableType ?
				this._tableData :
				this._tableData[this.selectedOperation].details ) : 
			[];
	}

	set tableData(data) {
		this._tableData = data;
		if(this.template.querySelector('c-record-table') !== null) this.template.querySelector('c-record-table').initialize();
	}

	set data(inputData) {
		if(inputData && inputData.groups) {
			this.tableData = inputData.groups;
		}
		else {
			this.tableData = [];
		}

		this.airlineInfo = {
			code: (inputData.airlineCode || ""),
			name: (inputData.airlineName || "")
		}
	}

	get tableColumns(){
		return TABLE_TYPE_GROUP === this.tableType ? 
			TABLE_GROUP_COLUMNS : 
			TABLE_DETAIL_COLUMNS;
	}

	get tableClickableRows() {
		return !this.detailTable;
	}

	get hasResults() {
		return !this.starting && !this.loading && this.success
				&& this._tableData !== undefined && this._tableData !== null
				&& this._tableData.length > 0;
	}

	get displayError() {
		return !this.loading && this.error;
	}

	get displayNoResults() {
		return !this.hasResults && !this.displayError;
	}

	get showingDetailedResults() {
		return this.hasResults && this.detailTable;
	}

	get displayChinaMarketWarningMessage() {
		return this.showingDetailedResults && this.operation !== null &&
				this.operation.toLowerCase().indexOf('china') > -1;
	}

	get displayOperationQuickFilter() {
		return this.hasResults && !this.detailTable;
	}

	get displayIATACodeQuickFilter() {
		return this.hasResults && this.detailTable && this.searchParams.type !== "agent";
	}

	get welcomeAreaClass() {
		return this.starting && !this.loading? 'slds-show' : 'slds-hide';
	}

	get spinnerClass() {
		return !this.loading ? 'slds-hide' : 'spinner-container slds-show';
	}

	get resultsClass() {
		return 'results-section ' + 
			(!this.starting && !this.loading ?
				'slds-show slds-var-m-top_medium slds-var-p-around_large' :
				'slds-hide');
	}

	get tableClass() {
		return !this.loading && this.success ? 'slds-show' : 'slds-hide';
	}

	get popupFilterLabel() {
		return this.filtered ? "Filtered" : "Filter"; 
	}

	get popupFilterClass() {
		return this.filtered ? "filtered" : "";
	}

	get filtered() {
		return (this.filterParams.markets !== null && this.filterParams.markets.length > 0) || (this.filterParams.service !== null && this.filterParams.service.length > 0);
	}

	connectedCallback(){
		
		registerListener('updateSearchFilters',
			this.handleUpdateSearchFilters, this);
		registerListener('clearResults',
			this.handleClearResultsArea, this);
		
	}
	

	disconnectedCallback() {
		unregisterAllListeners(this);
	}

	handleUpdateSearchFilters(filters) {
		this.searchParams.type = filters.type;
		this.searchParams.region = null;
		this.searchParams.agent = null;
		this.filterParams.market = null;
		this.filterParams.service = [];
		this.filterParams.markets = [];
		this.filterParams.iataCode = null;
		
		this.tableType = filters.type;
		this.selectedOperation = 0;
		if(this.searchParams.type === "market" && filters.region !== null && filters.region.length > 0) {
			this.searchParams.region = filters.region;
			this.loadMarkets();
			this.loadReport(filters);
		}
		if(this.searchParams.type === "agent" && filters.agent !== null && filters.agent.length > 0) {
			this.searchParams.agent = filters.agent;
			this.loadReport(filters);
		}
	}

	handleClearResultsArea(filters) {
		this.searchParams.type = filters.type;
		this.starting = true;
		this.loading = false;
		this._tableData = [];
		this.error = false;
		this.success = false;
	}

	loadReport(filters){
		if(this.starting){
			this.starting = false;
		}
		this.error = false;
		this.loading = true;
		getReport({region: filters.region, agent: filters.agent}).then(data => {
			this.data = data;
			this._errorMessage = null;
			this.success = true;
			this.error = false;
		}).catch( error => {
			this.data = {};
			this._errorMessage = error.body.message;
			this.error = true;
			this.success = false;
		}).finally( () => {
			this.loading = false;
		});
	}

	exportCSV() {
		this.exportFile(this.exportFilesPath + 'ADSRExportCSV', 'csv');
	}

    exportPDF() {
		this.exportFile(this.exportFilesPath + 'ADSRExportPDF', 'pdf');
	}

	exportFile(exportTarget, exportType) {
		let params = Object.assign(
			{
				detailTable: this.detailTable,
				selectedOperation: this.detailTable && this.searchParams.type !== "agent",
				operation: this.operation
			},
			this.searchParams
		);

		let exportForm = this.template.querySelector("form");
		exportForm.action = exportTarget;
		exportForm.querySelector("input[name='type']").value = exportType;
		exportForm.querySelector("input[name='params']").value = JSON.stringify(params);
		exportForm.querySelector("input[name='filters']").value = JSON.stringify(this.filterParams);
		exportForm.querySelector("input[name='data']").value = this.tableDataString;
		exportForm.querySelector("input[name='fields']").value = this.tableColumnsString;
		exportForm.submit();
	}
	
	get tableDataString() {
		let table = this.template.querySelector('c-record-table');
		let d = '';
		if(table !== null) {
			d = table.displayedData;
		}
		return JSON.stringify(d);
	}

	get tableColumnsString() {
		return JSON.stringify(this.tableColumns);
	}

	handleSearchTable(e) {
		if("market" === e.target.name) {
			this.filterParams.market = e.target.value; /** TODO: Can be removed when hiding the field on detail table */
		}
		else if("iataCode" === e.target.name) {
			this.filterParams.iataCode = e.target.value; /** TODO: Can be removed when hiding the field on detail table */
		}
		else if("filter" === e.target.name) {
			Object.assign(this.filterParams, e.target.value);
		}
		this.filterTable();
	}

	filterTable() {
		this.template.querySelector('c-record-table').filter(this.filterParams);
	}

	clearTableFilter(){
		this.filterParams.market = null;
		this.filterParams.iataCode = null;
		this.filterTable();
	}
	
	tableFilter = (elem, index, records, filters) => {
		return !filters || 
				( elem.operation && filters.market ?
					(filters.market === null || filters.market === '' || elem.operation.toLowerCase().indexOf(filters.market.toLowerCase()) >-1 ) :
					true) &&
				( elem.operation && filters.service ?
					(filters.service === null || filters.service.length === 0 || filters.service.map(s => {return s.toLowerCase();}).filter(s => { return elem.operation.toLowerCase().indexOf(s) > -1;}).length > 0 ) :
					true) &&
				( elem.operation && filters.markets ?
					(filters.markets === null || filters.markets.length === 0 || filters.markets.map(market => {return market.toLowerCase();}).filter(market => { return elem.operation.toLowerCase().indexOf(market) > -1;}).length > 0 ) :
					true) &&
				( elem.agentCode && filters.iataCode ?
					(filters.iataCode === null || filters.iataCode === '' || elem.agentCode.toLowerCase().indexOf(filters.iataCode.toLowerCase()) >-1 ) :
					true);
	}

	handleClickRow(e) {
		let clickedOperation = e.detail.row.operation;

		this._tableData.forEach( (r, i) => {
			if(!this.detailTable){
				if(r.operation === clickedOperation) {
					this.clearTableFilter();
					this.selectedOperation = i;
					this.tableType = TABLE_TYPE_DETAIL;
					this._displayBackButton = true;
				}
			}
		});
	}

	handleBack(e) {
		this.clearTableFilter();
		this.selectedOperation = 0;
		this.tableType = TABLE_TYPE_GROUP;
		this._displayBackButton = false;
	}

	get displayBackButton() {
		return this.hasResults && this._displayBackButton && this.detailTable && this.searchParams.type !== "agent";
	}

}