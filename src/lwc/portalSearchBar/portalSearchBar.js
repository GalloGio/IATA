import { LightningElement, track, api} from 'lwc';

export default class PortalSearchBar extends LightningElement {

    @track showHoverResults = false;

    @track showBackdrop = false;

    timeout = null;

    @api placeholder;
    
    @track searchText = "";

    //clone of the filtering object passed from the parent
    @track filteringObject;

    //these are the filters passed from the search
    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        this.filteringObject = value;
    }

    connectedCallback() {
        //nothing to do here... yet
    }

    closeSearch(){
        this.searchText = "";
        this.showHoverResults = false;
        this.showBackdrop = false;
    }

    onkeyupSearchInput(event){
        let keyEntered = event.keyCode;
        //console.log(keyEntered);

        //if enter
        if(keyEntered === 13){
            //go somewhere...
        } 

        //if escape
        if(keyEntered === 27){
            this.closeSearch();
        }
    }

    onclickSearchInput(){
        this.showBackdrop = true;
    }
    onchangeSearchInput(event){
        this.searchText = event.target.value;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

            if(this.searchText.length > 0){
                this.showHoverResults = true;
                let objAux = JSON.parse(JSON.stringify(this.filteringObject));

                objAux.searchText = this.searchText + "";
                objAux.showAllComponents = true;
                this.filteringObject = objAux;
                //console.log(objAux);
            }else{
                this.showHoverResults = false;
            }


        }, 1500, this);

    }

}