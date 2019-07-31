import { LightningElement, api,track } from 'lwc';
import CurrencyCenter_def_Spot_Change from '@salesforce/label/c.CurrencyCenter_def_Spot_Change';

export default class Paginator extends LightningElement {
    @api pageNumber;
    @api pageSize;
    @api totalItemCount;
    @api 
    get totalPages(){
        return this._totalPages;
    };
    set totalPages(val){
        this._totalPages=val;
    }
    @api pageList;
    @track currentPage=1;
    @track _totalPages=0;


    get renderSliders(){
        return this.totalPages>1;
    }

    handlePrevious() {
        if(this.pageNumber > 1) {
            this.dispatchEvent(new CustomEvent('previous'));
            this.selectPage(this.currentPage-1);
            
        }
    }

    handleNext() {
        if(this.pageNumber < this.totalPages) {
            this.dispatchEvent(new CustomEvent('next'));
            this.selectPage(this.currentPage+1);
        }
    }

    handleFirstPage() {
        if(this.pageNumber !== 1) {
            this.dispatchEvent(new CustomEvent('first'));
            this.selectPage(1);
        }
    }

    handleLastPage() {
        if(this.pageNumber !== this.totalPages) {
            this.dispatchEvent(new CustomEvent('last'));
            this.selectPage(this.totalPages);
        }
    }

    handleSelected(event) {
        let page = parseInt(event.target.name);        
        if(this.pageNumber !== page) {
            const selectedPage = new CustomEvent('selected', {
                detail: page
            });
            this.dispatchEvent(selectedPage);
            this.selectPage(page);
        }
    }

    selectPage(pageNr){
        this.currentPage=pageNr;
        this.template.querySelectorAll('[data-page]').forEach(elem=>{
            if(elem.name==pageNr)
                elem.classList.add('selected');
            else
                elem.classList.remove('selected');
        });
    }
    get hasPages(){
        return this._totalPages>0; 
    }
    get isFirstPage() {
        return this.pageNumber === 1 ? 'inactiveNavButton' : 'activeNavButton';
    }

    get isLastPage() {
        return this.pageNumber === this.totalPages ? 'inactiveNavButton' : 'activeNavButton';
    }    

    get rerenderFirstPages() {
        return (this.pageNumber > 5);
    }

    get rerenderLastPages() {
        return (this.totalPages > 3 && !this.pageList.includes(this.totalPages - 1));
    }

    get multiplePages() {
        return this.totalPages !== 1;
    }
}