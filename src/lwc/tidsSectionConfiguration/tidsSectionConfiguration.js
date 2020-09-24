import { LightningElement, track } from 'lwc';
// Sections and Configurations values
import { getForms, createSectionsAndFieldsModalValues, createNewMenu } from './tidsSectionConfigurationHelper';
import saveTidsConfiguration from '@salesforce/apex/TIDSUtil.saveTidsConfiguration';
import getTidsConfiguration from '@salesforce/apex/TIDSUtil.getTidsConfiguration';

export default class TidsSectionConfiguration extends LightningElement {
	@track forms = [];
	@track sectionsAndFields = null;
	@track loadingSpinner = false;
	@track formType = null;
	@track formAPI = null;
	@track formSelected = null;
	// Modal
	@track openModal = false;
	@track sections;

	connectedCallback() {
		 this.init();
	}
	
	rowEdit(event){
		event.preventDefault();
		let id = event.target.id;
		id= '$'+id.split('$')[1]+'$';
		this.sections.forEach(section => {
			section.fields.forEach( field => {
				if(field.id === id) {
						field.isEdit=true;
				}
			});
		});
	}
	hideRowFields(event){
		event.preventDefault();
		let id = event.target.id;
		id = '$'+id.split('$')[1]+'$';
		this.sections.forEach(section => {
			section.fields.forEach( field => {
				if(field.id === id) {
						field.isEdit=false;
				}
			});
		});
	}
	

	init() {
		this.isEdit=false;
		this.loadingSpinner = true;
		getTidsConfiguration({service:'TIDS'})
			.then(response => {
				if(response === null) {
					alert('You need to upload your configuration file under the TIDS service portal record.')
				} else {
					this.sectionsAndFields = JSON.parse(response);
					this.extractlistofapplicationforms();
				}
				this.loadingSpinner = false;
			})
			.catch(error => {
				console.log(error);
			})
	}
	extractlistofapplicationforms(){
		let newforms=[];
		this.sectionsAndFields.forEach(function(item){
			 newforms.push({label:item.name, value:item.apiName});
		});
		this.forms=newforms;
		//"name":"New Application - Head Office (HO)","apiName":"new-applicant-ho"
	}
	handleChangeFormSectionDisplay(event) {
		event.preventDefault();
		let apiSectionName = event.target.name;
		this.sections.find(section => {
			if(section.apiSectionName === apiSectionName) {
				section.display = !section.display;
			}
		});
	}

	handleFieldOnChange(event) {
		event.preventDefault();
		let id = event.target.id;
		id= '$'+id.split('$')[1]+'$';
		let optionSelected = event.target.name;
		let value=event.target.value;
		this.sections.forEach(section => {
			section.fields.forEach( field => {
				if(field.id===id ) {
					switch(optionSelected) {
						case 'visible':
							field.visible = !field.visible;
							break;
						case 'disabled':
							field.disabled = !field.disabled;
							break;
						case 'required':
							field.required = !field.required;
							break;
						case 'regex':
								field.regex = value;
								break;
						case 'english':
								field.translation_english = value;
								break;
						case 'japanese':
							field.translation_japanese = value;
							break;
						case 'portuguese':
							field.translation_portuguese = value;
							break;
						case 'french':
							field.translation_french = value;
							break;
						case 'spanish':
								field.translation_spanish = value;
								break;
						case 'chinese':
								field.translation_chinese = value;
								break;
						case 'name':
								field.name = value;
								break;  
							default: break;
					}
				}
			});
		});
	}

	// Open the modal and bring the Section and Fields information
	handleModifyConfiguration(event) {
		event.preventDefault();
		this.sections = [];
		let formApiName = event.target.dataset.formApiName;
		this.formType = event.target.dataset.formType;
		this.formSelected = this.getForm(formApiName);
		this.formAPI = formApiName;
		if(this.formSelected === undefined) {
			let formValues = this.forms.find(form => form.value === formApiName);
			this.formSelected = createNewMenu(formValues);
			this.sectionsAndFields.push(this.formSelected);
		}

		let result=[];
		let id=0;
		if(this.formType === 'client') {
			result = JSON.parse(JSON.stringify(this.formSelected.options.client));
			result.forEach(function(section){
				section.fields.forEach(function(field){
				field.isEdit=false;
				if (field.regex===undefined){
						field.regex='';
				}
				if (field.translation_english===undefined){
					field.translation_english='';
				}
				if (field.translation_japanese===undefined){
					field.translation_japanese='';
				}
				if (field.translation_spanish===undefined){
					field.translation_spanish='';
				}
				if (field.translation_portuguese===undefined){
					field.translation_portuguese='';
				}
				if (field.translation_french===undefined){
					field.translation_french='';
				}
				if (field.translation_chinese===undefined){
					field.translation_chinese='';
				}
				field.id = '$'+id+'$';
				id++;
				});
			});
			this.sections =result;
		} else if(this.formType === 'vetting') {
			 
			result= JSON.parse(JSON.stringify(this.formSelected.options.vetting));
			result.forEach(function(section){
				section.fields.forEach(function(field){
					field.isEdit=false;
					if (field.regex===undefined){
						 field.regex='';
					}
					if (field.translation_english===undefined){
						field.translation_english='';
					}
					if (field.translation_japanese===undefined){
						field.translation_japanese='';
					}
					if (field.translation_spanish===undefined){
						field.translation_spanish='';
					}
					if (field.translation_portuguese===undefined){
						field.translation_portuguese='';
					}
					if (field.translation_french===undefined){
						field.translation_french='';
					}
					if (field.translation_chinese===undefined){
						field.translation_chinese='';
					}
					field.id = '$'+id+'$';
					id++;
				});
			});
			this.sections =result;
		}

		this.openModal = true;
	}

	getForm(formApiName) {
		let result = this.sectionsAndFields.find(section => section.apiName === formApiName);
		return result;
	}

	handleSave(event) {
		event.preventDefault();
		this.openModal = false;
		this.loadingSpinner = true;
 
		// Update Sections and Fields on Form Selected
		if(this.formType === 'client'){
			this.formSelected.options.client = this.sections;
		} else if(this.formType === 'vetting'){
			this.formSelected.options.vetting = this.sections;
		}

		// Replace the Form Configuration with the new values
		let index = this.sectionsAndFields.findIndex(section => section.apiName === this.formSelected.apiName);
		this.sectionsAndFields.splice(index,1,this.formSelected);
		// Save in Salesforce
		saveTidsConfiguration({
			service:'TIDS',
			payload: JSON.stringify(this.sectionsAndFields)
		})
		.then(response => {
			this.loadingSpinner = false;
		})
		.catch(error => {
			console.log('Error',error);
		});

	}

	handleClose(event) {
		event.preventDefault();
		this.openModal = false;
	}

}