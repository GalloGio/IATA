import { api } from 'lwc';
import RecordCollection from 'c/recordCollection';

export default class RecordTable extends RecordCollection {

	@api resizable = false;
	@api sortable = false;
	@api scrollable = false; /* TODO: implement the logic to remove the scrollbar when it is not scrollable */ 
	@api clickableRows = false;
	@api bordered = false;
	@api borderedCols = false;
	@api borderTop = false;
	@api wrapHeader = false;
	@api fixedHeader = false;
	@api fixedFirstColumn = false;
	@api fixedScrollbar = false;
	@api highlightFirstColumn = false;
	@api showTotalLabel = false;
	@api highlightTotals = false;
	@api defaultColumnWidth = '10rem';

	tableWidth = '100%';

	sortingField = null;
	sortingDirection = null;
	
	@api
	initialize() {
		this.defaultSortingDirection();
		this.defaultSortingField();
		this.sortData();
	}

	connectedCallback() {
		super.connectedCallback();
		this.initialize();
	}

	renderedCallback() {
		this.tableWidth = this.template.querySelector('.slds-table').offsetWidth + 'px';
	}

	get fixedWidth() {
		return `width:${this.defaultColumnWidth};`;
	}

	get footerWidth() {
		return `width:${this.tableWidth};`
	}

	get mainContainerClass() {
		return 'tableScroll wrap';
	}

	get tableClass() {
		return 'slds-table slds-table_fixed-layout slds-scrollable_x slds-var-m-bottom_small ' +
				(this.bordered ? 'slds-table_bordered ' : '') +
				(this.borderedCols ? 'slds-table_col-bordered ' : '') +
				(this.borderTop ? 'border-top ' : '') +
				(this.resizable ? 'slds-table_resizable-cols ' : '') +
				(this.highlightFirstColumn ? 'hightlight-first-column ' : '') +
				(this.highlightTotals ? 'highlight-totals ' : '') +
				(this.clickableRows ? 'clickable-rows ' : '');
	}

	get headerContainerClass() {
		return 'header-container ' + 
			(this.fixedHeader ? 'fixed-header syncscroll ' : '') +
			(this.fixedFirstColumn ? 'fixed-first-column ' : '');
	}

	get headerClass() {
		return '' + 
			(this.resizable ? 'slds-is-resizable dv-dynamic-width slds-table_resizable-cols ' : '') +  
			(this.sortable ? 'slds-is-sortable ' : '') +
			(this.wrapHeader ? 'slds-cell-wrap ' : '');
	}

	get bodyContainerClass() {
		return 'slds-scrollable_x tableViewInnerDiv body-container ' +
			(this.fixedHeader ? 'fixed-header syncscroll ' : '') +
			(this.fixedFirstColumn ? 'fixed-first-column ' : '') + 
			(this.fixedScrollbar ? 'fixed-scrollbar ' : '');
	}

	get footerContainerClass() {
		return 'footer-container ' + 
			(this.scrollable && this.fixedScrollbar ? 'fixed-scrollbar ' : '');
	}

	@api get fields() {
		let fieldsCopy = JSON.parse(JSON.stringify(super.fields));
		fieldsCopy.forEach((field, index) => {
			field['_isFirstCol'] = index === 0;
			field['_isShowTotalLabel'] = field._isFirstCol && this.showTotalLabel;
			field['_headerClass'] = this.headerClass + (this.sortingField === field.targetField ? ' slds-is-sorted slds-is-sorted_' + this.sortingDirection : '');
			field['_headerLabelClass'] = !this.wrapHeader ? 'slds-truncate' : '';
			field['info'] = super.fields[index].info ? super.fields[index].info : null; 
		});

		return fieldsCopy;
	}

	set fields(f) {
		super.fields = f;
	}

	handleClickRow(e) {
		let targetElement = e.target;
		while (targetElement.tagName !== 'TR') {
			targetElement = targetElement.parentNode;
		}
		let rowIndex = targetElement.dataset.index;
		//console.log('clicking row', rowIndex)
		let record = JSON.parse(JSON.stringify(this.records[rowIndex]));

		this.dispatchEvent(
			new CustomEvent('clickrow',
			{
				detail: {
					row: record,
					index: rowIndex
				}
			}));
	}

	handleTooltipOver(e) {
		let left = e.target.offsetLeft - e.target.scrollLeft;
		let top = e.target.offsetTop + e.target.offsetHeight;
		let currentElement = e.target;
		while(currentElement.parentElement !== undefined && currentElement.parentElement !== null) {
			currentElement = currentElement.parentElement;
			left += currentElement.offsetLeft  - currentElement.scrollLeft;
			top += currentElement.offsetTop;
		}
		e.detail.top === undefined ?
			e.detail.top = '+ 0px' :
			e.detail.top.indexOf('-') < 0 ?
				'+ ' + e.detail.top :
				e.detail.top;
		e.detail.left === undefined ?
			e.detail.left = '+ 0px' :
			e.detail.left.indexOf('-') < 0 ?
				'+ ' + e.detail.left :
				e.detail.left;
		
		e.detail.top = `calc(${top}px ${e.detail.top})`;
		e.detail.left = `calc(${left}px ${e.detail.left})`;
		e.detail.width = e.detail.width;
		this.template.querySelector("c-advanced-helptext[role=display]").show(e);
	}

	handleTooltipOut(e) {
		this.template.querySelector("c-advanced-helptext[role=display]").hide();
	}

	/** Handling table sorting */
	handleclickcolumn(e) {
		let columnHeader = e.target;
		while (columnHeader.tagName !== "TH") {
            columnHeader = columnHeader.parentNode;
		}
		let newSortingField = columnHeader.dataset.field;
		if(newSortingField === this.sortingField) {
			this.inverseSortingDirection();
		}
		else {
			this.defaultSortingDirection();
			this.sortingField = newSortingField;
		}

		this.sortData();
	}

	inverseSortingDirection() {
		if(this.sortingDirection === 'desc') {
			this.sortingDirection = 'asc';
		}
		else {
			this.sortingDirection = 'desc';
		}
	}

	defaultSortingDirection() {
		this.sortingDirection = 'asc';
	}

	defaultSortingField() {
		this.sortingField = this.fields !== undefined &&
							this.fields !== null &&
							this.fields.length > 0 ?
								this.fields[0].targetField : 
								'';
	}

	sortData() {
		//this.updateHeaderClass();

		let localDataSet = JSON.parse(JSON.stringify(this.records));
		localDataSet.sort(this.dynamicSort("" + (this.sortingDirection === 'desc' ? "-" : "") + this.sortingField));
		this.records = localDataSet;
	}

	dynamicSort(property) {
		var sortOrder = 1;
		if(property[0] === "-") {
			sortOrder = -1;
			property = property.substr(1);
		}
		return function (a,b) {
			/* next line works with strings and numbers, 
			 * and you may want to customize it to your needs
			 */
			var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
			return result * sortOrder;
		}
	}

    //FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }
 
    tableScrolled(event) {
		this.template.querySelector(".header-container").scrollLeft = event.target.scrollLeft;
		if(this.fixedScrollbar){
			this.template.querySelector(".body-container").scrollLeft = event.target.scrollLeft;
		}
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }
 
    //#region ***************** RESIZABLE COLUMNS *************************************/
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }
 
    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }
 
        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
			this._tableThColumn = this._tableThColumn.parentNode;
		}

		//Get the column from body section (not the headers)
		let tableColumnName = this._tableThColumn.dataset.field;
		this._tableThColumn = this.template.querySelector(".body-container table thead th[data-field='"+tableColumnName+"'");

		this._tableThInnerDiv = this._tableThColumn.querySelector("div.slds-has-flexi-truncate");
		
        this._pageX = e.pageX;
 
        this._padding = this.paddingDiff(this._tableThColumn);
 
        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    }
 
    handlemousemove(e) {
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;
 
            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';
 
            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;
 
			let headerThs = this.template.querySelectorAll(".header-container table thead .dv-dynamic-width");
            let tableThs = this.template.querySelectorAll(".body-container table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll(".body-container table tbody tr");
			let tableBodyTds = this.template.querySelectorAll(".body-container table tbody .dv-dynamic-width");
			tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
				rowTds.forEach((td, ind) => { 
					rowTds[ind].style.width = tableThs[ind].style.width;
                });
			});
			let lastTh = this.template.querySelector("table thead th:last-child");
			if(lastTh.offsetWidth === 0){
				lastTh.style.width = "1px";
			}
			else {
				lastTh.style.width = null;
			}

			//Also update column width on headers section
			headerThs.forEach((th, ind) => {
				th.style.width = tableThs[ind].style.width;
			})
			this.tableWidth = this.template.querySelector('.slds-table').offsetWidth + 'px';
        }
    }
 
    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector("div.slds-has-flexi-truncate").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
		});
		this.tableWidth = this.template.querySelector('.slds-table').offsetWidth + 'px';
    }
 
    paddingDiff(col) {
 
        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }
 
        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));
 
	}
	
	@api get displayedData(){
		let ret = [];
		this.template.querySelectorAll("c-record-field").forEach(
			elem => {
				let record = ret[elem.recordIndex];
				if(record === undefined || null){
					record = {};
					ret[elem.recordIndex] = record;
				}
				record[elem.properties.targetField] = elem.value;
			}
		);
		if(ret.length > 0) {
			ret[ret.length-1][this.fields[0].targetField] = 'Sum';
		}
		return ret;
	}
 
	get totalRowIndex() {
		return this.records.length;
	}

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
	}

}