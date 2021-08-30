import { LightningElement, api, track } from 'lwc';

export default class CwPagination extends LightningElement {
    @api recordsPerPage;
    totalPagesToShow = 20;
    @track pagNumArray = [];
    _totalPages;
    @api 
    get totalPages () {
        return this._totalPages;
    }
    set totalPages (value){
        this._totalPages = value;
        this.bindPages();
    }
    @api 
     get pageNumbers(){
        return this.pagNumArray;
    }

    bindPages(){
        if (this.totalPages && this.selectedPage){
            this.pagNumArray = [];
            for (let i = Number(this.selectedPage); i > 0 && (this.totalPagesToShow / 2) > this.pagNumArray.length; i--) {
                this.pagNumArray.push(i);
            }
            for (let i = Number(this.selectedPage) + 1; i <= this.totalPages && this.totalPagesToShow > this.pagNumArray.length; i++) {
                this.pagNumArray.push(i);
            }

            this.pagNumArray.sort((a, b) => {
                if (a < b) { return -1; }
                if (a > b) { return 1; }
                return 0;
            });
        }
    }

    renderedCallback() {
        this.alignSelectedPage();
    }

    _selectedPage;
    @api 
    get selectedPage(){
        return this._selectedPage;
    }
    set selectedPage(value){
        this._selectedPage = value;
        this.bindPages();
    }

    @api isLoading;

    get showFirstPage(){
        return (this.totalPages > 1) ? this.pagNumArray.indexOf(1) == -1 : false;
    }

	get showLastPage(){
        return (this.totalPages > 1) ? this.pagNumArray.indexOf(this.totalPages) == -1 : false;
	}

    get showPrevious(){
        return this.selectedPage && this.selectedPage > 1;
    }

    get showNext(){
        return this.pageNumbers && (!this.selectedPage || this.selectedPage < this.pageNumbers.length);
    }
    next(){
        if(this.isLoading) return;
        this.dispatchEvent( new CustomEvent('next'));
    }
    previous(){
        if(this.isLoading) return;
        this.dispatchEvent( new CustomEvent('previous'));
    }
    goToPage(event){
        if(this.isLoading) return;
        let page = event.currentTarget.dataset.page;
        this.dispatchEvent( new CustomEvent('gotopage',{detail: page}));
    }
    fisrt(event){
        this.dispatchEvent( new CustomEvent('gotopage',{detail: 1}));
    }
    last(event){
        this.dispatchEvent( new CustomEvent('gotopage',{detail: this.totalPages}));
    }

    alignSelectedPage(){
        this.template.querySelectorAll('.pagenumber').forEach(elem => {
            elem.classList.remove('selected');
        });

        let num = this.template.querySelector('[data-page="' + (this.selectedPage || 1) + '"]');
        if (num) {
            num.classList.add('selected');
        }
    }
}