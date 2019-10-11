import { LightningElement, track } from 'lwc';
import getResults from '@salesforce/apex/CW_SearchEngine.getInfo';
export default class CwResultsPageContainer extends LightningElement {

    MAX_QUERY_LOCAL_STORAGE = 10;
    initialized = false;
    lastQueryEncodedString;
    @track results;
    @track searchList;
    @track initialSearch;


    renderedCallback() {
        if (!this.initialized) {
            this.initialized = true;
            let urlParams = this.getQueryParameters();
            if (urlParams.q) {
                this.lastQueryEncodedString = urlParams.q;
                if (this.lastQueryEncodedString) {
                    this.saveInLocalStorage('q', this.lastQueryEncodedString);
                    this.getRecordsFromEngine(null);
                    this.initialSearch = this.searchList;

                }
            }

        }
    }

    getRecordsFromEngine(event) {
        if (!event) {
            if (this.lastQueryEncodedString) {
                try {
                    this.searchList = JSON.parse(decodeURI(atob(this.lastQueryEncodedString)));
                } catch (error) {
                    console.error(error);
                }
            }
        } else {
            this.searchList = event.detail;
            this.setLastQueryEncodedString(this.searchList);
        }

        if (this.searchList) {
            const searchWrapper = this.manageDataSent(this.searchList);

            getResults({ attributes: JSON.stringify(searchWrapper) })
                .then(result => {
                    this.results = result ? JSON.parse(result) : null;
                })
                .catch(error => {
                    //this.error = error;
                    console.log('error', error);

                });
        }
    }
    manageDataSent() {


        let lstLocat = [];
        let lstCertis = [];
        let lstCoName = [];
        for (let i = 0; i < this.searchList.length; i++) {
            switch (this.searchList[i].field) {
                case 'City__c':
                    this.searchList[i].fields = ['Nearest_Airport__c', 'Country__c', 'City__c'];
                    lstLocat.push(this.searchList[i]);
                    break;
                case 'Account_Role__r.Account__r.Name':
                    this.searchList[i].fields = [this.searchList[i].field];
                    lstCertis.push(this.searchList[i]);
                case 'Certification__r.Name':
                    this.searchList[i].fields = [this.searchList[i].field];
                    lstCertis.push(this.searchList[i]);
                default:

            }
        }

        let searchWrapper = [];
        if (lstLocat && lstLocat.length) {
            searchWrapper.push(this.mergueListInRow(lstLocat));
        }
        if (lstCoName && lstCoName.length) {
            searchWrapper.push(this.mergueListInRow(lstCoName));
        }
        if (lstCertis && lstCertis.length) {
            searchWrapper.push(this.mergueListInRow(lstCertis));
        }
        return searchWrapper;
    }
    mergueListInRow(lstRows) {
        let singleRow = lstRows[0];
        if (lstRows.length > 1) {
            for (var i = 1; i < lstRows.length; i++) {
                singleRow.value += ';' + lstRows[i].value;
            }
        }
        return singleRow;
    }

    setLastQueryEncodedString(srch) {
        try {
            this.lastQueryEncodedString = btoa(encodeURI(JSON.stringify(srch))).replace('=', '');
            this.saveInLocalStorage('q', this.lastQueryEncodedString);
            this.setUrlSearchParam();
        } catch (error) {
            console.log(error);
        }

    }
    saveInLocalStorage(key, value) {
        if (key === 'q') {
            //move all already saved queries 1 position
            for (let i = this.MAX_QUERY_LOCAL_STORAGE; i > 1; i--) {

                if (window.localStorage.getItem('q' + (i - 1).toString())) {
                    window.localStorage.setItem('q' + i.toString(), window.localStorage.getItem('q' + (i - 1).toString()));
                    window.localStorage.removeItem('q' + (i - 1).toString());
                }
            }
            for (let i = 1; i <= this.MAX_QUERY_LOCAL_STORAGE; i++) {
                if (key === 'q' && !window.localStorage.getItem('q' + i.toString())) key = 'q' + i.toString();
            }
        }
        window.localStorage.setItem(key, value);
    }
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            if (search.substring(search.length - 1) === "=") {
                search = search.substring(0, search.length - 1);
            }
            try {
                params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                    return key === "" ? value : decodeURIComponent(value)
                });
            } catch (error) {
                console.error(error);
            }
        }

        return params;
    }

    setUrlSearchParam() {
        if (window.history.pushState) {
            let currentUrl = location.href;
            let newUrl;
            let params = this.getQueryParameters();
            if (params.q) {
                newUrl = currentUrl.replace(params.q, this.lastQueryEncodedString.replace('=', ''));
            } else if (Object.keys(params).length > 0 && this.lastQueryEncodedString) {
                newUrl = currentUrl + '&q=' + this.lastQueryEncodedString.replace('=', '');
            } else if (this.lastQueryEncodedString) {
                newUrl = currentUrl + '?q=' + this.lastQueryEncodedString.replace('=', '');
            }
            window.history.pushState({}, null, newUrl);
        }


    }

}