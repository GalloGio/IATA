import { LightningElement,api,track } from 'lwc';

/* APEX METHODS */
import getISOCountries  from '@salesforce/apex/GCS_RegistrationController.getISOCountries';
import getCountryStates from '@salesforce/apex/GCS_AccountCreation.getStates';

/* LABELS*/
import CSP_L2_Country                   from '@salesforce/label/c.CSP_L2_Country';
import CSP_L2_Is_PO_Box_Address         from '@salesforce/label/c.CSP_L2_Is_PO_Box_Address';
import CSP_L2_State                     from '@salesforce/label/c.CSP_L2_State';
import CSP_L2_City                      from '@salesforce/label/c.CSP_L2_City';
import CSP_L2_Postal_Code               from '@salesforce/label/c.CSP_L2_Postal_Code';
import CSP_L2_PO_Box_Number             from '@salesforce/label/c.CSP_L2_PO_Box_Number';
import CSP_L2_Street                    from '@salesforce/label/c.CSP_L2_Street';
import CSP_L2_Find_Address              from '@salesforce/label/c.CSP_L2_Find_Address';
import CSP_L2_Search_Results            from '@salesforce/label/c.CSP_L2_Search_Results';
import CSP_L2_Select_Address_Message    from '@salesforce/label/c.CSP_L2_Select_Address_Message';
import CSP_L2_Select                    from '@salesforce/label/c.CSP_L2_Select';
import CSP_L2_No_Matching_Results       from '@salesforce/label/c.CSP_L2_No_Matching_Results';
import CSP_L2_Address_Not_Found_Message from '@salesforce/label/c.CSP_L2_Address_Not_Found_Message';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';


export default class PortalAddressFormLMS extends LightningElement {
	/* Images */
	alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';
	arrowFirst = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-first.png';
	arrowFirstLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-first-lightgrey.png';
	arrowPrevious = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-prev.png';
	arrowPreviousLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-prev-lightgrey.png';
	arrowNext = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-next.png';
	arrowNextLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-next-lightgrey.png';
	arrowLast = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-last.png';
	arrowLastLightgrey = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-last-lightgrey.png';

	/* Passed address information */
	@api countryId;
	@api address;
	@api isIE;
	
	/* Local address information

		address.validationStatus values
		0 : not validated
		1 : a single address found
		2 : multiple address found
		3 : no address found
		4 : check cannot be performed (ISO Cities invalid input)
	*/
	@track localAddress;

	/* Address data*/
	countryData;
	stateData;

	/* Select options */
	@track countryOptions;
	@track stateOptions;
	@track cityOptions;

	// city suggestions
	@track citySuggestions = [];

	// address doctor suggestions
	@api addressSuggestions;

	@track resultsToDisplay;
	resultsPerPage = 10;
	@track currentPage = 1;
	@track pageNumbersBeforeCurrent;
	@track pageNumbersAfterCurrent;

	// flags
	@track provinceAndCitiesEnabled;

	get isStateRequired(){
		return this.provinceAndCitiesEnabled;
	}

	get displayStateComboBox(){
		return this.provinceAndCitiesEnabled;
	}

	@track citiesListbox = false;

	get isValidationButtonDisabled(){
		return  this.localAddress.cityName === ''
				|| this.localAddress.street.length < 3
				|| (this.localAddress.stateName === '' && this.isStateRequired)
				|| !this.localAddress.inputModified;
	}

	get hasSuggestions(){
		return this.localAddress.addressSuggestions.length > 0;
	}

	/* labels */
	_labels = {
		CSP_L2_Country,
		CSP_L2_Is_PO_Box_Address,
		CSP_L2_State,
		CSP_L2_City,
		CSP_L2_Postal_Code,
		CSP_L2_PO_Box_Number,
		CSP_L2_Street,
		CSP_L2_Find_Address,
		CSP_L2_Search_Results,
		CSP_L2_Select_Address_Message,
		CSP_L2_Select,
		CSP_L2_No_Matching_Results,
		CSP_L2_Address_Not_Found_Message
	}

	get labels() {
		return this._labels;
	}

	set labels(value) {
		this._labels = value;
	}

	performingSearch = false;

	renderedCallback(){
		if(this.performingSearch){
			let scrollobjective = this.template.querySelector('[data-name="searchDiv"]');
			scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
			this.performingSearch = false;
		}
	}

	connectedCallback(){
		var address = JSON.parse(JSON.stringify(this.address));
		this.localAddress = address;
		this.generateResultsToDisplay(true);

		if(this.localAddress.countryId === ''){
			this.localAddress.countryId = this.countryId;
		}

		getISOCountries().then(result=>{
			let countryList = JSON.parse(JSON.stringify(result.countryList));
			let optionList = this.buildOptions(countryList,true);

			this.countryData = result;
			this.countryOptions = optionList;

			if(this.localAddress.countryId !== undefined && this.localAddress.countryId.length > 0){
				this.handleCountryChange(this.localAddress.countryId,false);

				// ensure that localAddress.inputModified has the original value
				this.localAddress.inputModified = address.inputModified;
				this.setValidationStatus(this.localAddress.validationStatus);
			}
		});
	}

	/* Build option list */
	buildOptions(dataList, includeEmpty){
		let optionList = [];

		if(includeEmpty){
			optionList.push({ 'label': '', 'value': '' });
		}

		dataList.forEach(function (data) {
			optionList.push({ 'label': data.Name, 'value': data.Id });
		});

		return optionList;
	}

	handleFieldChange(event){
		let value = event.target.value;
		let fieldname = event.target.dataset.fieldname;

		this.localAddress.inputModified = true;
		this.setValidationStatus(this.localAddress.validationStatus);

		switch(fieldname){
			case 'IsPoBox':
				this.localAddress.isPoBox = event.target.checked;
				this.localAddress.cityName = '';
				this.localAddress.cityId = '';
				this.localAddress.zip = '';
				this.localAddress.street = '';
				this.localAddress.street2 = '';
				break;
			case 'Country':
				this.handleCountryChange(value,true);
				break;
			case 'StateId':
				this.handleStateChange(value,true);
				break;
			case 'StateName':
				this.localAddress.stateName = value;
				break;
			case 'Street':
				if(this.localAddress.isPoBox){
					this.localAddress.PO_Box_Address__c = value;
				}else{
					this.localAddress.street = value;
				}
				break;
			case 'Street2':
				this.localAddress.street2 = value;
				break;
			case 'City':
				this.localAddress.cityName = value;
				break;
			case 'Zip':
				this.localAddress.zip = value;
				break;
		}
	}

	/* Handle form changes */
	handleCountryChange(countryId,clearInputs){
		if(countryId === undefined || countryId.length === 0){
			this.localAddress.countryId = '';
			this.localAddress.countryCode = '';
			this.localAddress.countryName = '';
			this.provinceAndCitiesEnabled = false;
			return;
		}

		let country = this.countryData.countryMap[countryId];

		this.localAddress.countryId = country.Id;
		this.localAddress.countryCode = country.ISO_Code__c;
		this.localAddress.countryName = country.Name;

		if(country === undefined || country.Region_Province_and_Cities_Enabled__c === false ){
			this.stateOptions = [];
			this.provinceAndCitiesEnabled = false;

			// maybe we need to reset the state and all other fields

			let state = '';
			if(!clearInputs){
				if(this.localAddress.stateId !== ''){
					state = this.localAddress.stateId;
				}
				else{
					state = this.localAddress.stateName;
				}
			}

			this.handleStateChange(state,clearInputs);

			return;
		}

		this.provinceAndCitiesEnabled = true;

		getCountryStates({"country":country.Name}).then(result =>{
			let states = JSON.parse(JSON.stringify(result.states));

			let optionList = this.buildOptions(states,true);

			this.stateData = result;
			this.stateOptions = optionList;

			let state = '';
			if(!clearInputs){
				if(this.localAddress.stateId != ''){
					state = this.localAddress.stateId;
				}
				else{
					state = this.localAddress.stateName;
				}
			}

			this.handleStateChange(state,clearInputs);
		});
	}

	handleStateChange(stateValue, clearInputs){
		if(this.provinceAndCitiesEnabled){
			let state = this.stateData.states.find(function (state2) {
				return state2.Id === stateValue || state2.Name === stateValue;
			});
			this.localAddress.stateName = state !== undefined ? state.Name : '';
			this.localAddress.stateId = state !== undefined ? state.Id : '';
		}
		else{
			this.localAddress.stateName = stateValue;
			this.localAddress.stateId = '';
		}

		if(clearInputs){
			this.localAddress.cityName = '';
			this.localAddress.cityId = '';
			this.localAddress.street = '';
			this.localAddress.street2 = '';
			this.localAddress.zip = '';
		}

	}

	/* called when user selects a city in the suggestions list */
	handleCityChange(event){
		let value = event.target.dataset.value;
		let name = event.target.dataset.name;
		let stateid = event.target.dataset.stateid;

		this.citiesListbox = false;
		this.localAddress.cityId = value;
		this.localAddress.cityName = name;


		this.localAddress.inputModified = true;
		this.setValidationStatus(this.localAddress.validationStatus);
		this.handleStateChange(stateid,false);
	}

	/* called when user types some text in the city input. Useful only for geoname countries */
	handleCityKey(event){
		let stateData = this.stateData;
		let value = event.target.value;
		let selectedState = this.localAddress.stateId;

		this.localAddress.cityId = '';
		this.localAddress.cityName = value;
		this.localAddress.inputModified = true;

		let isPoBox = this.localAddress.isPoBox;

		if(value === undefined || value.length === 0){
			this.citySuggestions = [];
			this.citiesListbox = false;
			return;
		}

		let state;

		if(stateData !== undefined && stateData.states !== undefined){
			if(selectedState){

				state = this.stateData.states.find(function (currentState) {
					return currentState.Id === selectedState;
				});

				stateData = {'states':[state]};
			}

			let suggestionList = [];

			stateData.states.forEach(function (state) {
				if(state.IATA_ISO_Cities__r !== undefined){

					state.IATA_ISO_Cities__r.forEach(function (city) {
						if(city.GeonameAlternateNames__c != null){
						}
						if(city.Name !== undefined
							&& (city.Name.toLowerCase().indexOf(value.toLowerCase()) > -1
								|| (city.GeonameAlternateNames__c != null && city.GeonameAlternateNames__c.toLowerCase().indexOf(value.toLowerCase()) > -1))
							&& (isPoBox || !city.Is_PO_Box_City__c)){
							suggestionList.push({
								'label': city.GeonameHierarchy_label__c,
								'value': city.Id,
								'stateid':city.IATA_ISO_State__c,
								'name':city.Name
							});
						}
					});
				}
			});

			if(suggestionList.length > 0){
				this.citiesListbox = true;
			}else{
				this.citiesListbox = false;
			}

			this.citySuggestions = suggestionList;
		}
	}

	/* Control */

	hideCities(){
		this.citiesListbox = false;
	}

	/* getters */
	get isValidationStatus0(){
		return this.localAddress.validationStatus === 0;
	}

	get isValidationStatus1(){
		return this.localAddress.validationStatus === 1;
	}

	get isValidationStatus2(){
		return this.localAddress.validationStatus === 2;
	}

	get isValidationStatus3(){
		return this.localAddress.validationStatus === 3;
	}

	get isValidationStatus4(){
		return this.localAddress.validationStatus === 4;
	}

	changeSelectedAddress(event){
		var index = parseInt(event.target.getAttribute('data-id'));

		for(var i = 0 ; i < this.localAddress.addressSuggestions.length; i++){
			this.localAddress.addressSuggestions[i].isSelected = (i === index);
		}

		this.setValidationStatus(this.localAddress.validationStatus);
	}


	/* Condition getters*/

	get hasStateOptions(){
		return this.stateOptions === undefined || this.stateOptions.length === 0;
	}

	get hasCityOptions(){
		return this.cityOptions === undefined || this.cityOptions.length === 0;
	}

	get hasCitySuggestion(){
		return this.citySuggestions !== undefined && this.citySuggestions.length > 0;
	}

	get showCitySuggestions(){
		return this.hasCitySuggestion && this.citiesListbox;
	}

	setValidationStatus(validationStatus){
		this.localAddress.validationStatus = validationStatus;

		// we should send
		// - true if:
		//     - address has been verified (validation status != 0) & input wasn't changed
		//     - or if an address has been selected
		// - false otherwise
		// so this method must be called if any of the following changes
		// - localAddress.validationStatus
		// - localAddress.inputModified
		// - a suggested address is selected

		let addressSelected = false;
		for(var i = 0 ; i < this.localAddress.addressSuggestions.length; i++){
			if(this.localAddress.addressSuggestions[i].isSelected){
				addressSelected = true;
				break;
			}
		}

		let status = (this.localAddress.validationStatus !== 0 && !this.localAddress.inputModified)
								|| addressSelected;

		this.dispatchEvent(new CustomEvent('setvalidationstatus', {detail:status}));
	}

	/* Pagination methods and flags */
	get numberOfPages(){
		let rest = this.localAddress.addressSuggestions.length % this.resultsPerPage;

		if(rest === 0){
			return this.localAddress.addressSuggestions.length / this.resultsPerPage;
		}
		else{
			return 1 + (this.localAddress.addressSuggestions.length - rest) / this.resultsPerPage;
		}
	}

	goToFirstPage(){
		this.currentPage = 1;
		this.generateResultsToDisplay(false);
		this.performingSearch = true;
	}

	goToPreviousPage(){
		this.currentPage = this.currentPage - 1;
		this.generateResultsToDisplay(false);
		this.performingSearch = true;
	}

	get isFirstPage(){
		return this.currentPage === 1;
	}

	goToPage(event){
		var pageNumber = event.target.getAttribute('data-id');

		if(pageNumber === '...'){
			return;
		}

		this.currentPage = parseInt(pageNumber);
		this.generateResultsToDisplay(false);
		this.performingSearch = true;
	}

	goToNextPage(){
		this.currentPage = Math.min(this.currentPage + 1, this.numberOfPages);
		this.generateResultsToDisplay(false);
		this.performingSearch = true;
	}

	goToLastPage(){
		this.currentPage = this.numberOfPages;
		this.generateResultsToDisplay(false);
		this.performingSearch = true;
	}

	get isLastPage(){
		return this.currentPage === this.numberOfPages;
	}


	unshiftSelectedAddress(){
		let suggestions = this.localAddress.addressSuggestions;
		let reorderedSuggestions = [];
		for(let i = 0; i < suggestions.length; i++){
			if(suggestions[i].isSelected){
				reorderedSuggestions.unshift(suggestions[i]);
			}
			else{
				reorderedSuggestions.push(suggestions[i]);
			}
		}

		this.localAddress.addressSuggestions = reorderedSuggestions;
	}

	generateResultsToDisplay(unshiftSelectedAddress){
		if(unshiftSelectedAddress){
			this.unshiftSelectedAddress();
		}

		var results = [];

		var startIndex = (this.currentPage - 1) * this.resultsPerPage;
		var stopIndex = Math.min(startIndex + this.resultsPerPage, this.localAddress.addressSuggestions.length) ;

		for(let i = startIndex; i < stopIndex; i++){
			results.push(this.localAddress.addressSuggestions[i]);
		}
		this.resultsToDisplay =  results;

		let pageNumbersBefore= [];
		let pageNumbersAfter= [];

		if(this.numberOfPages < 9){
			for(let i = 1; i <= this.numberOfPages; i++){
				if(i < this.currentPage){
					pageNumbersBefore.push(i);
				}
				else if(i > this.currentPage){
					pageNumbersAfter.push(i);
				}
			}
		}
		else{
			if(this.currentPage > 1){
				pageNumbersBefore.push(1);
			}

			if(this.currentPage - 2 > 2){
				pageNumbersBefore.push('...');
			}

			let start;
			if(this.currentPage + 5 < this.numberOfPages){
				start = Math.max(this.currentPage - 2, 2);
			}
			else{
				start = Math.min(this.currentPage - 2, this.numberOfPages - 5);
			}

			for(let i = start; i < start + 5; i++){
				if(i < this.currentPage){
					pageNumbersBefore.push(i);
				}
				else if(i > this.currentPage){
					pageNumbersAfter.push(i);
				}
			}

			if(this.currentPage + 2 < this.numberOfPages - 1){
				pageNumbersAfter.push('...');
			}

			if(this.currentPage < this.numberOfPages){
				pageNumbersAfter.push(this.numberOfPages);
			}
		}

		this.pageNumbersBeforeCurrent = pageNumbersBefore;
		this.pageNumbersAfterCurrent = pageNumbersAfter;
	}

	@api
	getAddressInformation(){
		return this.localAddress;
	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}
}