import { LightningElement, api, track } from 'lwc';

export default class CwPagination extends LightningElement {
    @api recordsPerPage;
    totalPagesToShow = 20;
    @track pagNumArray = [];
    @api totalPages;
    @api 
     get pageNumbers(){
        return this.pagNumArray;
    }

    bindPages(){
        if (this.totalPages && this.selectedPage){
            this.pagNumArray = [];
            let startValue = this.selectedPage;
    
            let countPage = 0;
            for (let i = startValue; i <= this.totalPages; i++){
                if (countPage < this.totalPagesToShow){
                    this.pagNumArray.push(i);
                    countPage++;
                }
            }

            while(countPage < this.totalPagesToShow){
                startValue--;
                if(startValue > 0){
                    this.pagNumArray.push(startValue);
                    countPage++;
                }
                else{
                    countPage = this.totalPagesToShow;
                }
            }

            this.pagNumArray = this.pagNumArray.sort();
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

    renderedCallback(){
        if(!this.initialized){
            this.bindPages();
            this.initialized = true;
        }
        
        if (this.selectedPage)
            this.alignSelectedPage(this.selectedPage);
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