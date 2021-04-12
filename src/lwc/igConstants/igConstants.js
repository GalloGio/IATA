import IG_RESOURCES from '@salesforce/resourceUrl/IG_Resources';

const permissions = {
    VIEW_ALL_DASHBOARD: 'IGOM_View_All_Dashboard',
    VIEW_OWN_DASHBOARD: 'IGOM_View_Own_Dashboard',
    CREATE_GAP: 'IGOM_GAP_Creation',
    EDIT_GAP: 'IGOM_GAP_Edition',
    DOCUMENT_GAP: 'IGOM_GAP_Documentation',
    NOTIFY_GAP: 'IGOM_GAP_Notify',
    VIEW_COMMENTS_GAP: 'IGOM_GAP_View_Comments',
    PUBLISH_GAP: 'IGOM_GAP_Publish',
    VIEW_LAST_MANUAL: 'IGOM_View_Last_Manual',
    VIEW_ALL_MANUALS: 'IGOM_View_All_Manuals',
    UPLOAD_MANUAL: 'IGOM_Upload_Manual',
    CHECK_NOTIFICATIONS: 'IGOM_Check_Notifications',
    VIEW_ALL_VARIATIONS: 'IGOM_View_All_Variations',
    VIEW_OWN_VARIATIONS: 'IGOM_View_Own_Variations',
    MANAGE_STATION: 'IGOM_Manage_Station',
};

const constants = {
    NOTIFICATION: {
        STATUS: { 
            VALUES: { 
                UNREAD: 'Unread',
                ACKNOWLEDGED: 'Acknowledged',
            }
        },
        SEVERITY: {
            VALUES: {
                ACTION_REQUIRED: 'Action Required',
                INFORMATIVE: 'Informative',
                MANUAL: 'Manual'
            }
        }
    },
    DOCUMENT: {
        ABBREVIATED_NAME: {
            NAME: 'Abbreviated_Name__c'
        },
        DOCUMENT_NAME: {
            NAME: 'Document_Name__c'
        },
        EDITION: {
            NAME: 'Edition__c'
        },
        EFFECTIVE_DATE: {
            NAME: 'Effective_Date__c'
        },
        LANGUAGE: { 
            NAME: 'Language__c'
        },
        ABBREVIATED_NAME: {
            NAME: 'Abbreviated_Name__c'
        },
        REVIEW_DATE: {
            NAME: 'Review_Date__c'
        },
        PUBLISHED_DATE: {
            NAME: 'Published_Date__c'
        },
        VERSION: {
            NAME: 'Version__c'
        },
        REVISION: {
            NAME: 'Revision__c'
        },
        ABBREVIATED_NAME: {
            NAME: 'Abbreviated_Name__c'
        },
        DOCUMENT_TYPE: {
            NAME: 'Document_Type__c',
            VALUES: {
                ONLINE_BASED: 'Online',
                SOFTWARE_BASED: 'Software',
                FILES_ON_SERVER: 'Files'
            }
        }
    },
    PROCEDURE_COMPLIANCE: {
        STATUS_VALUE: {
            VALUES: {
                OUT_OF_DATE: 'Out of Date',
                REVIEWED: 'Reviewed',
                EXPIRED: 'Expired'
            }
        },
        VARIATION_STATUS: {
            VALUES: {
                CONFORMITY: 'Conforms', 
                OUT_OF_SCOPE: 'Out of Scope',
                VARIATION: 'Varies'
            }
        }
    },
    COMPLIANCE_REVIEW: {
        PUBLISH_STATUS: {
            VALUES: {
                DRAFT: 'Draft',
                PUBLISHED: 'Published',
                TEMPLATE: 'Template'
            }
        }
    },
    CONTACT_ROLE_DETAIL: {
        ROLE: {
            VALUES: {
                ADMIN: 'IGOM Admin',
                EDITOR: 'Editor',
                ACKNOWLEDGER: 'Acknowledger',
                VIEWER: 'Viewer',
                IATA_PERSONNEL: 'IATA Personnel'
            }
        }
    },
    ACCOUNT_ROLE_RELATIONSHIP: {
        STATUS: {
            VALUES: {
                ACTIVE: 'Active',
                INACTIVE: 'Inactive',
                PENDING: 'Pending'
            }
        },
        TYPE: {
            VALUES: {
                PARENT: 'Parent',
                CHILD: 'Child',
                GROUP: 'Group'
            }
        }
    },
    COLORS: {
        CHART: {
            VALUES: {
                GRAY: 'rgb(201, 203, 207)',
                GREEN: 'rgb(75, 192, 192)',
                YELLOW: 'rgb(255, 205, 86)',
                RED: 'rgb(255, 99, 132)'
            }
        },
        GAP: {
            VALUES: {
                BLANK: 'Blank',
                RED : 'rgb(231, 48, 48)',
                ORANGE : 'rgb(246, 137, 22)',
                GRAY : 'rgb(184, 184, 184)',
                GREEN : 'rgb(40, 150, 50)'
            }
        }
    }
};

const resources = {
    example_igom: IG_RESOURCES + '/IGOM XML Example.xml',
    styles: {
        igomReader: IG_RESOURCES + '/styles/igomReader.css'
    },
    images: {
        svg: {
            logoWhite: IG_RESOURCES + '/img/logo-white.svg'
        }
    },
    icons: { 
        alert: IG_RESOURCES + '/icons/alert-icon.svg#alert',
        alert2: IG_RESOURCES + '/icons/alert2-icon.svg#alert2',
        attachment: IG_RESOURCES + '/icons/attachment-icon.svg#attachment',
        back: IG_RESOURCES + '/icons/ig-go-back.svg',
        cancel: IG_RESOURCES + '/icons/cancel-icon.svg#cancel',
        chevrondown: IG_RESOURCES + '/icons/chevrondown.svg',
        closeBlue: IG_RESOURCES + '/icons/ig-close-blue.svg',
        comment: IG_RESOURCES + '/icons/comment-icon.svg#comment',
        delete: IG_RESOURCES + '/icons/delete-icon.svg#delete',
        undelete: IG_RESOURCES + '/icons/undelete-icon.svg#undelete',
        doubleArrow: IG_RESOURCES + '/icons/double-arrow-icon.svg#doubleArrow',
        fold: IG_RESOURCES + '/icons/fold-icon.svg#fold',
        indicatorHeader: IG_RESOURCES + '/icons/indicator-header.svg',
        info: IG_RESOURCES + '/icons/info-icon.svg#info',
        lufthansaIcon: IG_RESOURCES + '/icons/ig-lufthansa-icon.svg',
        markAsReviewed: IG_RESOURCES + '/icons/published_with_changes-icon.svg#icon',
        notifications: IG_RESOURCES + '/icons/notifications.svg',
        plus: IG_RESOURCES + '/icons/plus-icon.svg#plus',
        read: IG_RESOURCES + '/icons/ig-notification-read.svg',
        unchecked: IG_RESOURCES + '/icons/ig-unchecked.svg',
        unfold: IG_RESOURCES + '/icons/unfold-icon.svg#unfold',
        unread: IG_RESOURCES + '/icons/ig-notification-unread.svg',
        user: IG_RESOURCES + '/icons/user-icon.svg',
        warning: IG_RESOURCES + '/icons/warning-icon.svg#warning',
        chapter: IG_RESOURCES + '/icons/chapter_{chapterNumber}.svg#Layer_1',
        png: {
            newFile: IG_RESOURCES + '/icons/ig-new-file.png',
            previousVersion: IG_RESOURCES + '/icons/ig-previous-version.png',
            continueDraft: IG_RESOURCES + '/icons/ig-continue-draft.png',
            warning: IG_RESOURCES + '/icons/ig-warning.png',
            checked: IG_RESOURCES + '/icons/ig-checked.png',
        }
    }
};

export { permissions, constants, resources }