import { LightningElement, api, track } from 'lwc';
import { util } from 'c/igUtility';

const camelCaseToSentenceCase = (text) => {
    let upperCase = text.replace( /([A-Z])/g, " $1" );
    return upperCase.charAt(0).toUpperCase() + upperCase.slice(1);
};

const throttle = (func, limit) => {
    let lastFunc;
    let lastRan;
    return function() {
        const context = this;
        const args = arguments;
        if (!lastRan) {
            func.apply(context, args);
            lastRan = Date.now();
        } else {
            clearTimeout(lastFunc);
            lastFunc = setTimeout(function() {
                if ((Date.now() - lastRan) >= limit) {
                    func.apply(context, args);
                    lastRan = Date.now();
                }
            }, limit - (Date.now() - lastRan));
        }
    }
}

const styleClass = {
    column : {
        base : 'faux-column slds-col',
        center: 'faux-column slds-col slds-text-align_center'
    },
    cell : {
        text: {
            base: 'faux-data',
            highlighted: 'faux-data highlighted'
        },
        image: {
            base: 'faux-data',
            highlighted: 'faux-data highlighted'
        },
        link: {
            base: 'faux-data clickable link',
            highlighted: 'faux-data clickable link highlighted',
            unclickable: 'faux-data',
        }
    }
};

const type = {
    text: 'text',
    image: 'image',
    link: 'link'
};

export default class IgAdaptableTable extends LightningElement {
    _data = [];

    _selectable = false;
    _selectedId = null;
    @api 
    set selectable(value) {
        this._selectable = value;
    }
    get selectable() {
        return this._selectable;
    }

    @api
    set pageSize(value) {
        this._pageSize = value;
    }
    get pageSize() {
        return this._pageSize;
    }
    _pageSize = 3;
    _currentPage = 1;
    _totalElements = 1;
    get _totalPages() {
        return Math.ceil(this._totalElements / this._pageSize);
    }
    get _isMonoPage() {
        return !(this._totalPages > 1);
    }
    get _firstElement() {
        return ((this._currentPage-1) * this._pageSize);
    }
    get _lastElement() {
        return (this._pageSize-1) + ((this._currentPage-1) * this._pageSize);
    }
    get _displayedElements() {
        return this._adaptedData[0].values.length;
    }
    get _displayableFirstElement() {
        return this._firstElement + 1;
    }
    get _displayableLastElement() {
        return this._displayableFirstElement + this._displayedElements - 1;
    }
    goToNextPage() {
        if (this._currentPage < this._totalPages) {
            ++this._currentPage;
            this.adaptData();
        }
    }
    goToPreviousPage() {
        if (this._currentPage > 1) {
            --this._currentPage;
            this.adaptData();
        }
    }

    _lastShownIds;
    get lastShownIds() {
        return this._lastShownIds;
    }
    set lastShownIds(value) {
        if (this._isRendered) {
            this.dispatchEvent(new CustomEvent('changedshownids', {
                detail: {
                    shownIds: value
                }
            }));
        }
        this._lastShownIds = value;
    }

    @api
    tableClass = '';

    get mainTableClass() {
        return 'faux-table' + (this.tableClass ? ' ' + this.tableClass : '');
    }

    _isRendered = false;

    @track
    _adaptedData;
    
    _tableConfig = {
        logo : {
            type: 'image',
            hideMobile: true,
            hideHeader: true,
            centerContent: true
        },
        airline : {
            sortable: true,
            searchable: true
        },
        city : {
            searchable: true
        },
        variations : {
            sortable: true
        },
        gotoLink : {
            hideHeader: true,
            type: 'link'
        }
    };

    _searchBar = false;
    _searchFun = null;

    
    _searchChange = throttle((text) => {
        if (text) {
            const searchText = text.toLowerCase();
            this._searchFun = row => 
                Object.keys(this._tableConfig).filter(col => this._tableConfig[col].searchable)
                .some(col => row[col] && row[col].toLowerCase().includes(searchText));
        } else {
            this._searchFun = row => true;
        }
        this.adaptData();
    }, 500);

    searchChange(ev) {
        const text = ev.target.value || (ev.originalTarget ? ev.originalTarget.value : undefined);
        console.log('searchChange', text);
        this._searchChange(text);
    }

    applyConfig() {
        this._searchBar = Object.keys(this._tableConfig).some(col => this._tableConfig[col].searchable);
    }

    adaptData() {
        // Get all columns in the objects
        let objectCols = new Set();
        this._data.forEach((el) => Object.keys(el).forEach(col => objectCols.add(col)));
        objectCols.delete('id');
        // Get all columns in the configuration
        let configCols = Object.keys(this._tableConfig);
        // Get cols in column in order, the rest from the object
        // configCols = configCols.filter(el => objectCols.has(el)); // only show column for existent fields?
        let configColsSet = new Set(configCols);
        objectCols = Array.from(objectCols).filter(el => !configColsSet.has(el));
        const colsOrdered = configCols.concat(objectCols);
        // Remove every column ignored
        const cols = colsOrdered.filter(col => this._tableConfig[col] ? !this._tableConfig[col].ignore : true);
        // Adapt all the data so it can be displayed
        const filteredData = this._data.filter(el => (this._searchBar && this._searchFun) ? (this._searchFun(el)) : true);
        this._adaptedData = cols.map(col => {
            this._totalElements = filteredData.length;
            const colType = (this._tableConfig[col] && this._tableConfig[col].type) ? this._tableConfig[col].type : type.text;
            return {
                name: (this._tableConfig[col] && this._tableConfig[col].label) ? this._tableConfig[col].label : camelCaseToSentenceCase(col),
                id: col,
                values: filteredData
                    .map(el => ({ 
                        val: (el[col] === undefined || el[col] === '') ? '-' : el[col], 
                        key: `${el.id}:${col}`,
                        class: (this._selectable && el.id === this._selectedId) ? styleClass.cell[colType].highlighted : 
                        (el[col] === undefined || el[col] === null) && colType === type.link ? styleClass.cell[colType].unclickable : styleClass.cell[colType].base,
                        hidden: (el[col] === undefined || el[col] === null) ? true : false
                    }))
                    .slice(this._firstElement, this._lastElement+1),
                isImage: colType === type.image,
                isLink: colType === type.link,
                isText: colType === type.text,
                isSortable: this._tableConfig[col] ? this._tableConfig[col].sortable : false,
                isHiddenMobile: this._tableConfig[col] ? this._tableConfig[col].hideMobile : false,
                isHiddenHeader: this._tableConfig[col] ? this._tableConfig[col].hideHeader : false,
                isSortedAsc: this._orderAscendent[col] ? true : false,
                columnClass: this._tableConfig[col] && this._tableConfig[col].centerContent ? styleClass.column.center : styleClass.column.base,
                customStyle: (this._tableConfig[col] && this._tableConfig[col].width) ? 'width: ' + this._tableConfig[col].width : ''
            }
        });
        // Check if needed to notify items shown change
        const shownIds = filteredData.slice(this._firstElement, this._lastElement+1).map(el => el.id);
        if (JSON.stringify(this.lastShownIds) != JSON.stringify(shownIds)) {
            this.lastShownIds = shownIds;
        }
    }

    @api
    set tableData(value) {
        if (value) {
            this._data = JSON.parse(JSON.stringify(value));
            if (value[0] && !Object.keys(value[0]).includes('id')) {
                util.debug.error('Table data does not contain "id" as a column. Data = ', this._data);
            }
            this.adaptData();
        }
    }

    get tableData() {
        return this._adaptedData;
    }

    @api
    set tableConfig(value) {
        this._tableConfig = value;
        this.applyConfig();
        this.adaptData();
    }

    get tableConfig() {
        return this._tableConfig;
    }
    
    @api
    get shownItemIds() {
        return ;
    }

    _orderAscendent = {};

    orderColumn(ev) {
        const colName = ev.target.closest('.faux-header').dataset.column;
        if (this._orderAscendent[colName]) {
            this._data = this._data.sort((a, b) => a[colName] < b[colName]);
            this._orderAscendent[colName] = false;
        } else {
            this._data = this._data.sort((a, b) => a[colName] > b[colName]);
            this._orderAscendent[colName] = true;
        }
        this.adaptData();
    }

    tableClickHandler(ev) {
         // Link-type data cells
        const linkDataCell = ev.target.closest('.faux-data.link');
        if (linkDataCell) {
            const columnName = ev.target.closest('.faux-column').dataset.column;
            this.dispatchEvent(new CustomEvent('linkclick', {
                detail: {
                    linkData: linkDataCell.dataset.link,
                    column: columnName
                }
            }));
            return;
        }
        // Sortable column headers
        const sortableHeader = ev.target.closest('.faux-header.sortable');
        if (sortableHeader) {
            const colName = sortableHeader.dataset.column;
            if (this._orderAscendent[colName]) {
                this._data = this._data.sort((a, b) => a[colName] < b[colName]);
                this._orderAscendent[colName] = false;
            } else {
                this._data = this._data.sort((a, b) => a[colName] > b[colName]);
                this._orderAscendent[colName] = true;
            }
            this.adaptData();
            return;
        }
        // Any other data cell if selection is allowed
        if (this._selectable) {
            const dataCell = ev.target.closest('.faux-data');
            const column = ev.target.closest('.faux-column');
            const indexClicked = [...column.querySelectorAll('.faux-data')].indexOf(dataCell);
            const elementClicked = this._data[this._firstElement+indexClicked];
            this._selectedId = elementClicked.id;
            this.dispatchEvent(new CustomEvent('rowselected', {
                detail: {
                    row: elementClicked
                }
            }));
            this.adaptData();
            //debugger;
        }
    }

    constructor() {
        super();
        if (this._data) {
            this.tableData = this._data;
        }
        if (this._tableConfig) {
            this.tableConfig = this._tableConfig;
        }
    }

    renderedCallback() {
        if (!this._isRendered) {
            this.dispatchEvent(new CustomEvent('changedshownids', {
                detail: {
                    shownIds: this.lastShownIds
                }
            }));
        }
        this._isRendered = true;
    }
}