import { LightningElement, api, track } from 'lwc';

export default class CwPagination extends LightningElement {
    @track pagNumArray = [];
    @api 
    get pageNumbers(){
        return this.pagNumArray;
    }
    set pageNumbers(value){
        this.pagNumArray = [];
        let val = Number(value);
        for (let i = 1; i <= val; i++){
            this.pagNumArray.push(i);
        }
    }
    @track _selectedPage;
    @api 
    get selectedPage(){
        return this._selectedPage;
    }
    set selectedPage(value){
        this.alignSelectedPage(value);        
    }

    @api isLoading;
    initialized = false;

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

    renderedCallback(){
        if(!this.initialized){
            this.alignSelectedPage(this.selectedPage);
            this.initialized = true;
        }
    }
    alignSelectedPage(value){
        this.template.querySelectorAll('.pagenumber').forEach(elem => {
            elem.classList.remove('selected');
        })
        if(value){
            this._selectedPage = Number(value);
            let num = this.template.querySelector('[data-page="'+this._selectedPage+'"]');
            if (num) num.classList.add('selected');
        }else{
            let num = this.template.querySelector('[data-page="'+1+'"]');
            if (num) num.classList.add('selected');
        }
    }
}