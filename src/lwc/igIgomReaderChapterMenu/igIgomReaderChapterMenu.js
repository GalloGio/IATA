import { LightningElement, api } from 'lwc';

export default class IgIGOMDocumentDescriptionChapterMenu extends LightningElement {
    @api igom;
    selectedChapter;

    chapterClickHandler(ev) {
        let chapterId = ev.target.closest('a').dataset.id;
        this.dispatchEvent(new CustomEvent('chapterchange', {
            detail: chapterId
        }));
    }

    sectionClickHandler(ev) {
        let sectionId = ev.target.closest('a').dataset.id;
        this.dispatchEvent(new CustomEvent('sectionchange', {
            detail: sectionId
        }));
    }
}