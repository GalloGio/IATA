import { LightningElement, api, track } from 'lwc';
import getConflictCapabilities from "@salesforce/apex/CW_CapabilityConflictController.getConflictCapabilities";
import getCapabilitiesInternal from "@salesforce/apex/CW_FacilityCapabilitiesController.getCapabilitiesInternal"; 
import solveCapabilityConflicts from "@salesforce/apex/CW_CapabilityConflictController.solveCapabilityConflicts"; 
import resources from '@salesforce/resourceUrl/ICG_Resources';

const handleStatus = {
    STATUS_ADD: {label:'Add', value: 'STATUS_ADD'},
    STATUS_REMOVE: {label:'Remove', value: 'STATUS_REMOVE'},
    STATUS_REPLACE:{label:'Replace', value: 'STATUS_REPLACE'},
    STATUS_MAINTAIN:{label:'Maintain', value: 'STATUS_MAINTAIN'},
    STATUS_REPLACED_BY:{label:'Replaced By', value: 'STATUS_TO_BE_REPLACED_BY'}
}

export default class CwCapabilityConflictHandler extends LightningElement {
    CHECKED_IMAGE = resources +'/icons/ic-tic-green.svg';
    ERROR_IMAGE = resources +'/icons/error-icon.svg';

    @track isLoading = false;
    @track data = null;
    @track categories = []; 
    listNewCapabilitiesInConflicts;
    listAllCapabilitiesInConflicts;

    @track openConfirmSuccess; 
    @track openConfirm;
    @track modalImage = this.CHECKED_IMAGE;
    @track modalMessage;
    categoryToSave;

    @api preSelectedFacility;

    @api
    userManagedFacilities;
    @api label;
    @track selectedFacility;

    initialized = false;
    renderedCallback(){
        if(!this.initialized && this.preSelectedFacility){
            this.selectedFacility = this.preSelectedFacility;
            this.initialized = true;
            this.getConflictCapabilitiesFromDB();

        }
        else if(!this.initialized){
            this.initialized = true;
            this.isLoading = false;

            
        }
        this.template.querySelectorAll('[data-head="conflict_selector"]').forEach(elem => {
            elem.classList.add('second-column-head');
        });
        this.template.querySelectorAll('[data-cell="conflict_selector"]').forEach(elem => {
            elem.classList.add('second-column-cell');
        });

        //READY TO ADD data-hed and data-cell third column
        /*this.template.querySelectorAll('[data-head=""]').forEach(elem => {
            elem.classList.add('third-column-head');
        });
        this.template.querySelectorAll('[data-cell=""]').forEach(elem => {
            elem.classList.add('third-column-cell');
        });*/
    }

    getConflictCapabilitiesFromDB(){
        this.isLoading = true;
        if(this.selectedFacility){
            getConflictCapabilities({stationId: this.selectedFacility})
            .then(results => {
                this.prepareNewCapabilities(results);
                this.getCapabilitiesFromDB();
            }).catch(err => {
                console.error(err);
                this.isLoading = false;
            });
        }
        else{
            this.isLoading = false;
        }
    }

    getCapabilitiesFromDB(){
        let categoriesCopy = [];
        if(this.listAllCapabilitiesInConflicts.length > 0){
            getCapabilitiesInternal({id: this.selectedFacility, capabilitiesIdForConflicts: this.listAllCapabilitiesInConflicts})
            .then(data => {
                this.data = data;
				this.data.superCategories.forEach(superCategory => {
					superCategory.sections.forEach(section => {
                        section.capabilities.forEach(capability => {
                            capability.categories.forEach(category => {
                                if(category.hasRows){

                                    let categoryCopy = JSON.parse(JSON.stringify(category));
                                    for(let i = 0; i < categoryCopy.columns.length; i ++){
                                        const isLast = i === categoryCopy.columns.length - 1;
                                        let columnObj;
                                        if(isLast){
                                            columnObj = {
                                                colspan: 1,
                                                isformula: false,
                                                label: "Actions", 
                                                name: "conflict_selector"
                                            }
                                        }
                                        else{
                                            columnObj = {
                                                colspan: 1,
                                                isformula: false,
                                                label: "", 
                                                name: "conflict_selector"
                                            }
                                        }

                                        categoryCopy.columns[i].splice(1, 0, columnObj);
                                    }

                                    let rowCounter = 1;
                                    let newCounter = 1;
                                    let conflictLabel;
                                    if(categoryCopy.auxType === "standard_temperature_ranges" || categoryCopy.auxType === "custom_temperature_ranges"){
                                        conflictLabel = this.label.room;
                                    }
                                    else if(categoryCopy.auxType === "temperature_controlled_ground_service_eq"){
                                        conflictLabel = this.label.dolly_truck;
                                    }
                                    else{
                                        conflictLabel = categoryCopy.label;
                                    }

                                    categoryCopy.rows.forEach(row => {
                                        if(this.getNewCapabilities().includes(row.id)){
                                            row.isNew = true;
                                            row.conflictLabel = "New Record " + newCounter++;
                                        }
                                        else{
                                            if(conflictLabel){
                                                row.conflictLabel = conflictLabel + " " + rowCounter++;
                                            }
                                        }
                                        row.conflict_selector = "actions";
                                        row.categoryValue = categoryCopy.value;
                                        row.isInvolvedInConflictProcess = true;
                                    });

                                    categoryCopy.rows.sort((a, b) => (a.isNew === b.isNew) ? 0 : a.isNew ? -1 : 1);

                                    categoriesCopy.push(categoryCopy);
                                }
                            })
                        })
                    })
                })
                this.generateInConflictWith(categoriesCopy);
                this.generateConflictOptions(categoriesCopy);
                this.categories = categoriesCopy;
                this.isLoading = false;
            }).catch(err => {
                console.error(err);
                this.isLoading = false;
            });
        }
        else{
            this.isLoading = false;
            this.categories = [];
        }
    }

    generateInConflictWith(categoriesCopy){
        this.listNewCapabilitiesInConflicts.forEach(newCapability => {
            categoriesCopy.forEach(category => {
                category.rows.forEach(row => {
                    if(row.id === newCapability.Id){
                        row.conflictObjects = this.extractConflictObjects(newCapability.inConflictsWith, category);
                    }
                })
            });
        });
    }

    extractConflictObjects(inConflictsWith, category){
        let conflictObjects = [];

        category.rows.forEach(row => {
            if(inConflictsWith.includes(row.id)){
                conflictObjects.push(row);
            }
        })


        return conflictObjects;
    }

    calculateSelectedTargets(categoriesCopy){
        let alreadySelectedTargets = [];
        categoriesCopy.forEach(category => {
            category.rows.forEach(row => {
                if(row.selectedConflictTarget){
                    alreadySelectedTargets.push(row.selectedConflictTarget);
                }
            })
        })

        return alreadySelectedTargets;
    }

    generateConflictOptions(categoriesCopy){


        let alreadySelectedTargets = this.calculateSelectedTargets(categoriesCopy);

        categoriesCopy.forEach(category => {
            category.rows.forEach(row => {
                let options = [];

                if(row.isNew){
                    options = [handleStatus.STATUS_ADD];

                    row.conflictObjects.forEach(conflictObj => {
                        if(!alreadySelectedTargets.includes(conflictObj.id) || row.selectedConflictTarget === conflictObj.id){
                            let optionObj = {
                                label:'Replace ' + conflictObj.conflictLabel, 
                                value: handleStatus.STATUS_REPLACE.value + '_' + conflictObj.id
                            }
    
                            options.push(optionObj);
                        }
                    })
                }
                else{
                    if(!alreadySelectedTargets.includes(row.id)) {
                        options = [handleStatus.STATUS_MAINTAIN, handleStatus.STATUS_REMOVE];
                    }
                    else{
                        let optionObj = {
                            label:'Replaced by ' + row.selectedReplacedBy.conflictLabel, 
                            value: handleStatus.STATUS_REPLACED_BY.value + '_' + row.selectedReplacedBy.id
                        }

                        options.push(optionObj);
                    }
                    
                }
                row.options = options;
            });
        });




    }

    getNewCapabilities() {
        let newCapabilities = [];

        this.listNewCapabilitiesInConflicts.forEach(cap => {
            newCapabilities.push(cap.Id);
        })

        return newCapabilities;
    }

    prepareNewCapabilities(results){
        this.listNewCapabilitiesInConflicts = [];
        this.listAllCapabilitiesInConflicts = [];
        
        results.forEach(result => {
            let inConflictsWith = JSON.parse(result.In_Conflict_With__c);
            let newCapabilityId =  result.Account_Role_Detail_Capability__c;

            let newCapability = {
                Id: newCapabilityId,
                inConflictsWith: inConflictsWith
            }

            this.listNewCapabilitiesInConflicts.push(newCapability);
            this.listAllCapabilitiesInConflicts.push(newCapabilityId);
            inConflictsWith.forEach(conflictCap => {
                if(!this.listAllCapabilitiesInConflicts.includes(conflictCap)){
                    this.listAllCapabilitiesInConflicts.push(conflictCap);
                }
            });
        });
    }

    selectFacility(event) {
        if (this.checkFormFields()) {
            this.selectedFacility = event.detail.data;
            this.getConflictCapabilitiesFromDB();
        }
    }
    removeFacility() {
        this.selectedFacility = null;
    }

    checkFormFields() {
        const inputValid = [...this.template.querySelectorAll('input')]
            .reduce((validSoFar, inputCmp) => {
                if (validSoFar) inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const selectValid = [...this.template.querySelectorAll('select')]
            .reduce((validSoFar, inputCmp) => {
                if (validSoFar) inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return inputValid && selectValid;
    }
    handleConfirmClicked(event){
        this.categoryToSave = event.target.dataset.category;
        this.openConfirm = true;
    }

    handleCancel(){
        this.openConfirm = false;
        this.categoryToSave = null;
    }

    handleConfirmDialogYes(){
        this.isLoading = true;
        this.openConfirm = false;
        let updatedCapabilities = [];
        this.categories.forEach(category => {
            if(category.value === this.categoryToSave){
                category.rows.forEach(row => {
                    let obj = {
                        id: row.id,
                        action: row.selectedConflictAction.includes(handleStatus.STATUS_REPLACE.value) ? handleStatus.STATUS_REPLACE.value : row.selectedConflictAction,
                        target: row.selectedConflictTarget ? row.selectedConflictTarget : ""
                    }
    
                    updatedCapabilities.push(obj);
                })
                
            }

        });
        solveCapabilityConflicts({handledCapabilitiesJSON: JSON.stringify(updatedCapabilities)})
        .then(data => {
            let results = JSON.parse(data);

            if(results.success){
                this.openConfirmSuccess = true;
                this.modalMessage = results.message;
                this.modalImage = this.CHECKED_IMAGE;
            }
            this.isLoading = false;
        }).catch(err => {
            console.error(err);
            this.isLoading = false;
            this.openConfirmSuccess = true;
            this.modalMessage = err.body.message;
            this.modalImage = this.ERROR_IMAGE;
        });
    }

    closeModal(){
        this.openConfirmSuccess = false;
        this.getConflictCapabilitiesFromDB();            
    }

    get dataInformed() {
		return this.data != null ? true : false;
    }
    
    handleConflictAction(event){
        let itemUpdated = event.detail.data;

        let oldTargetsToBeCleaned = [];

        let categoriesCopy = JSON.parse(JSON.stringify(this.categories));
        categoriesCopy.forEach(category => {
            let rowIndexToUpdate = -1;
            if(category.value === itemUpdated.categoryValue){
                for(let i = 0; i < category.rows.length; i++){
                    let row = category.rows[i];

                    if(row.id === itemUpdated.id){
                        rowIndexToUpdate = i;
                    }

                    if(row.id === itemUpdated.selectedConflictTarget){
                        row.selectedReplacedBy = itemUpdated;
                        row.selectedConflictAction = handleStatus.STATUS_REPLACED_BY.value;
                    }

                    if(!itemUpdated.selectedConflictTarget && itemUpdated.oldTarget){
                        oldTargetsToBeCleaned.push(itemUpdated.oldTarget);
                        itemUpdated.oldTarget = null;
                    }
                }

                category.rows.forEach(row => {
                    if(oldTargetsToBeCleaned.includes(row.id)){
                        row.selectedReplacedBy = null;
                        row.selectedConflictAction = null;
                    }
                })
            }

            if(rowIndexToUpdate > -1){
                category.rows.splice(rowIndexToUpdate, 1, itemUpdated);
            }
        });
        this.generateConflictOptions(categoriesCopy);
        this.categories = JSON.parse(JSON.stringify(categoriesCopy));
        this.handleBtnCss(itemUpdated.categoryValue);
    }

    handleBtnCss(categoryValue){
        let baseClassList = "btn btn-primary link-button mt-1";
        const element = this.template.querySelector('[data-category="' + categoryValue + '"]');

        let categoryToCheck = this.getCategoryByValue(categoryValue);
        let shouldBeEnabled = this.checkCategoryConflicts(categoryToCheck);
        if(!shouldBeEnabled){
            baseClassList += " disabled";
        }
        element.classList = baseClassList;
    }

    checkCategoryConflicts(categoryToCheck){
        if(!categoryToCheck || !categoryToCheck.rows){
            return false;
        }

        const amountRows = categoryToCheck.rows.length;
        let counter = 0;

        categoryToCheck.rows.forEach(row => {
            if(row.selectedConflictAction){
                counter++;
            }
        });

        return amountRows === counter;
    }

    getCategoryByValue(categoryValue){
        let categoryToCheck;
        this.categories.forEach(category => {
            if(category.value === categoryValue){
                categoryToCheck = category;
            }
        })

        return categoryToCheck;
    }

    handleSetNoStation(event){
        this.selectedFacility = null;
    }

    get categoriesNotEmpty(){
        return this.categories && this.categories.length > 0;
    }
}