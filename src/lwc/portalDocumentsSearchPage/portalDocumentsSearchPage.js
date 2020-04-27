import { LightningElement,track } from 'lwc';

import { getParamsFromPage } from'c/navigationUtils';
import CSP_DocumentsAll from '@salesforce/label/c.CSP_DocumentsAll'
import CSP_BookmarksTabLabel from '@salesforce/label/c.CSP_BookmarksTabLabel'
export default class PortalDocumentsSearchPage extends LightningElement {


	@track label={
		CSP_DocumentsAll,
		CSP_BookmarksTabLabel
	}
	
	refreshlist=false;

	renderedCallback(event){
		//Check param to render on selected tab, default all Documents
		let pageParams = getParamsFromPage();       
		switch(pageParams.tab) {
			case 'MyBookmarks':
				this.changeToTab('bookmarksTab');
				break;
			case 'AllDocuments':
			default:
				this.changeToTab('allTab');
		}

	}




	//captures any change in either of the tables to refresh on next tab switch/render
	requestRefreshList(event){
		event.preventDefault();
		this.refreshlist=true;
	}


	//Exposed method to navigate to specific tab
	navigateToTab(event){
	   
		this.template.querySelector('[data-tab='+event.detail.tab+']').click();
		let cat=event.detail.category;
		let prodcat=event.detail.prodCategory;
		if(cat){
			let ev={
				detail:{
					category:cat,
					prodCateg:prodcat
				}
	
			};

			this.template.querySelector('c-portal-document-all-documents').showCategory(ev);
		}
				
	}
	
	changetabs(event){
		let selectTab=event.target.dataset.key;
		this.changeToTab(selectTab);
	}

	changeToTab(seltab){      
	  
		this.template.querySelectorAll('.tab').forEach(elem=>{
			if(elem.classList.contains('selectedTab')){
				elem.classList.remove('selectedTab');
				this.template.querySelector('[data-section='+elem.dataset.key+']').classList.add('slds-hide');
			}
			if(elem.dataset.key==seltab){
				elem.classList.add('selectedTab');
				this.template.querySelector('[data-section='+elem.dataset.key+']').classList.remove('slds-hide');                
		   }
		});


		//refresh both lists if there was a change in one of them
		if(this.refreshlist ===true){
			this.refreshlist=false;
			this.template.querySelector('c-portal-document-all-documents').refreshList();
			this.template.querySelector('c-portal-documents-bookmark-list').refreshList();
		}
			
	}
}