import { LightningElement, track, api } from 'lwc';

export default class RecordCollection extends LightningElement {
    @track _records = [];
    @api fields = [];
    @api keyName = 'id';
    @api addRowLabel = ' + Add new';
	@api addRowValidation;
	
	@api filterFunction;
	_filterParams;

	@api filter(params) {
		this._filterParams = params;
	}

    get addRowDisabled(){
        let canAdd = true;
        if(this.addRowValidation !== undefined){
            canAdd = this.addRowValidation(this.records);
        }
        return !canAdd;
    }

    @api get records(){
		if(this.filterFunction && typeof this.filterFunction === "function") {
			let _filter = this.filterFunction;
			let _params = this._filterParams;
			return this._records.filter(function(elem, index, arr) {
					return _filter(elem, index, arr, _params);
				}
			);
		}
        return this._records;
    }
    
    set records(r){
		let recordList = JSON.parse(JSON.stringify(r));

		recordList.forEach(record => {
			if(!record['_key']){
				record['_key'] = JSON.stringify(record).split('').reduce((a,b)=>{a=((a<<5)-a)+b.charCodeAt(0);return a&a},0);
			}
		});
        this._records = recordList;
	}

    connectedCallback(){
        //this.addEventListener('recordfieldupdate', this.onRecordFieldUpdate.bind(this));
	}

    onRecordFieldUpdate(e){
        let sourceEvent = e.detail;
        let localDataSet = JSON.parse(JSON.stringify(this.records));
        localDataSet[sourceEvent.recordIndex][sourceEvent.field.targetField] = sourceEvent.value;
        //this.records = localDataSet;
        if(sourceEvent.field.type === 'picklist'){
            localDataSet[sourceEvent.recordIndex][sourceEvent.field.labelField] = sourceEvent.label;
        }
        if(sourceEvent.field.onchange !== undefined){
            let record = sourceEvent.field.onchange(localDataSet[sourceEvent.recordIndex], sourceEvent.recordIndex, localDataSet);
            console.log('1', JSON.parse(JSON.stringify(record)));
            localDataSet[sourceEvent.recordIndex] = record;
        }
        console.log('2', JSON.parse(JSON.stringify(localDataSet)));
        this.records = localDataSet;
        this.notifyObservers('update', localDataSet[sourceEvent.recordIndex], e.detail);
    }

    addNewRow(){
        let record = {};
        this.fields.forEach(field => {
            //Not needed yet
            /*if(field.defaultValue !== undefined && field.defaultValue !== null){
                record[field.targetField] = field.defaultValue;
            }
            else if(["number", "percent", "currency"].indexOf(field.type) > -1){
                record[field.targetField] = 0;
            }
            else if("checkbox" === field.type){
                record[field.targetField] = false;
            }
            else{
                record[field.targetField] = null;
            }*/
            record[field.targetField] = null;
        });
        let localDataSet = this.records === undefined || this.record === null ? [] : JSON.parse(JSON.stringify(this.records));
        localDataSet.push(record);
        this.records = localDataSet;
        this.notifyObservers('insert', record);
    }

    deleteRow(e){
        let removeIndex = e.currentTarget.dataset.recordIndex;
        let localDataSet = JSON.parse(JSON.stringify(this.records));
        let affectedRecords = localDataSet.splice(removeIndex, 1);
        this.records = localDataSet;
        this.notifyObservers('delete', affectedRecords);
    }

    /**
     * 
     * @param {*} action - can be delete, insert, update
     * @param {*} affectedRecordSet - list of affected records
     */
    notifyObservers(actionPerformed, affectedRecordSet, sourceEvent = {}){
        this.dispatchEvent(
            new CustomEvent(
                'recordschange', 
                {
                    detail: {
                        action: actionPerformed,
                        affectedRows: affectedRecordSet,
                        data: JSON.parse(JSON.stringify(this.records)),
                        source: sourceEvent
                    }
                }
            )
        );
    }

    @api reportValidity(){
        let allFields = [...this.template.querySelectorAll('c-oss-record-field')];
        let allValid = allFields.reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

}