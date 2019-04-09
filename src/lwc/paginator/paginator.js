import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    @api pageNumber;
    @api pageSize;
    @api totalItemCount;
    @api totalPages;
    @api pageList;

    handlePrevious() {
        if(this.pageNumber > 1) {
            this.dispatchEvent(new CustomEvent('previous'));
        }
    }

    handleNext() {
        if(this.pageNumber < this.totalPages) {
            this.dispatchEvent(new CustomEvent('next'));
        }
    }

    handleFirstPage() {
        if(this.pageNumber !== 1) {
            this.dispatchEvent(new CustomEvent('first'));
        }
    }

    handleLastPage() {
        if(this.pageNumber !== this.totalPages) {
            this.dispatchEvent(new CustomEvent('last'));
        }
    }

    handleSelected(event) {
        let page = parseInt(event.target.name);
        if(this.pageNumber !== page) {
            const selectedPage = new CustomEvent('selected', {
                detail: page
            });
            this.dispatchEvent(selectedPage);
        }
    }
    
    get isFirstPage() {
        return this.pageNumber === 1 ? 'selected' : '';
    }

    get isLastPage() {
        return this.pageNumber === this.totalPages ? 'selected' : '';
    }    

    get rerenderFirstPages() {
        return (this.pageNumber > 4);
    }

    get rerenderLastPages() {
        return (this.totalPages > 3 && !this.pageList.includes(this.totalPages - 1));
    }

    get multiplePages() {
        return this.totalPages !== 1;
    }
}