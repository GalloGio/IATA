import { LightningElement, api, track } from 'lwc';
import { resources } from 'c/igUtility';
import { label } from 'c/igLabels';

export default class IgSidebarMenuGapChapter extends LightningElement {
    @track label = label;

    // Exposed properties

    @api chapter;
    @api folded;

    @api expandedChapter;
    @api selectedChapter;
    @api selectedProcedure;

    // Imported properties

    resources = resources;

    // Main logic

    clickedSection(event) {
        event.stopPropagation();
        const clickedLi = event.target.closest('li.sidebar-sub-item');
        const selectedSectionId = clickedLi.dataset.section;
        this.dispatchEvent(new CustomEvent('sectionclicked', {
            detail: {
                selectedSectionId: selectedSectionId
            }
        }));
    }
    
    toggleChapter() {
        const chapterToggled = this.chapter.procedure.Id;
        this.dispatchEvent(new CustomEvent('chaptertoggled', {
            detail: {
                chapterId: chapterToggled
            }
        }));
    }

    // Logical properties

    get isChapterSelected() {
        return this.chapter.procedure.Id === this.selectedChapter;
    }
    get isChapterExpanded() {
        return this.chapter.procedure.Id === this.expandedChapter;
    }
    get showChapterExpanded() {
        // If the chapter is selected, show it always, if not, show it if its expanded
        return this.isChapterSelected ? true : this.isChapterExpanded;
    }
    get sectionList() {
        return this.chapter.subprocedures.map(section => ({ ...section, isSelected: this.selectedProcedure === section.procedure.Id }));
    }

    // Style properties

    get chapterIcon() {
        return resources.icons.chapter.replace('{chapterNumber}', this.chapter.procedure.Index__c);
    }

    get chapterNameClass() {
        let classes = ['gap-item','slds-wrap','chapter','ml-1'];
        if (this.folded) {
            classes.push('hidden');
        }
        if (this.isChapterSelected) {
            classes.push('active-item');
        }
        return classes.join(' ');
    }

    get subchapterNameClass() {
        let classes = ['gap-item','slds-wrap'];
        if (this.folded) {
            classes.push('hidden');
        }
        return classes.join(' ');
    }
    
    get subitemLiClass() {
        let classes = ['sidebar-sub-item','position-relative'];
        if (this.folded) {
            classes.push('pl-0');
        } else {
            classes.push('pl-2r');
            classes.push('shorten-text');
        }
        return classes.join(' ');
    }

    get subitemLiActiveClass() {
        return this.subitemLiClass + ' active-item';
    }

    get mainLiClass() {
        let classes = ['sidebar-item','slds-align-middle','background-dark-grey'];
        if (this.folded) {
            classes.push('padded-icons');
        }
        if (this.isChapterSelected) {
            classes.push('item-selected');
        }
        return classes.join(' ');
    }

    get sublistClass() {
        let classes = ['sub-list-unstyled'];
        if (this.isChapterSelected) {
            classes.push('active-item');
        }
        return classes.join(' ');
    }

    get chapterIconClass() {
        let classes = ['slds-text-align_center','position-relative'];
        if (this.folded) {
            classes.push('remove-left-margin');
        }
        return classes.join(' ');

    }

}