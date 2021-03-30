import { LightningElement, wire, track } from 'lwc';
import { util, resources } from 'c/igUtility';
import { label } from 'c/igLabels';
import getProcedureCompliances from '@salesforce/apex/IGOMComplianceReviewPartUtil.getVariations';
import getStations from '@salesforce/apex/IGOMStationUtil.getStationsData';
import getAllPublishedGapAnalyses from '@salesforce/apex/IGOMComplianceReviewUtil.getAllPublishedGapAnalyses';
import stationSummaries from '@salesforce/apex/IGOMDashboardDataUtil.getStationSummary';

export default class IgVariationReport extends LightningElement {
	@track label = label;
	resources = resources;

	// -------------- Page toggling --------------
	renderAnalysisVariations = true;
	gotoStationList() {
		this.renderAnalysisVariations = false;
		this.procedureCompliancesGrouped = undefined;
		this.chapterList = undefined;
		this.selectedComplianceReviewId = undefined;
	}
	gotoAnalysisVariations(ev) {
		const stationId = ev.detail.linkData;
		this.selectedStation = this.stationList.find(el => el.id === stationId);
		this.renderAnalysisVariations = true;
	}

	// -------------- Station list page --------------
	@track stationList;
	_selectedStation;
	@track selectedAccountRoleDetailId;
	get selectedStation() {
		return this._selectedStation;
	};
	set selectedStation(value) {
		this._selectedStation = value;
		this.selectedAccountRoleDetailId = value.id;
		this.variationList = null;
	}

	@track selectAccountRoleId;

	tableConfig = {
		logo: {
			type: 'image',
			hideHeader: true
		},
		name: {
			sortable: true,
			searchable: true
		},
		type: {
            centerContent: true
        },
		country: {
			sortable: true,
			searchable: true
		},
		city: {
			sortable: true,
			searchable: true
		},
		lastRevision: {
			centerContent: true
		},
		variations: {
			centerContent: true
		},
		acknowledgements: {
			centerContent: true,
			label: 'Acks'
		},
		goToReport: {
			type: 'link',
			hideHeader: true,
			centerContent: true
		},
		accountId: {
            ignore: true
        },
        accountRoleId: {
            ignore: true
        },
		publishesTemplates: {
			ignore: true
		}
	};

	@wire(getStations, { forPage: 'Variations' })
	getStationLists({data, error}) {
		if (error) {
			console.error(error);
			return;
		}
		if (data) {
			let stations = JSON.parse(JSON.stringify(data));
			for (let station of stations) {
				station.goToReport = station.id;
			}
			if (stations.length === 1) {
				this.renderAnalysisVariations = true;
				this.selectedStation = stations[0];
			} else {
				this.renderAnalysisVariations = false;
			}
			this.stationList = stations;
		}
	};

	// -------------- IGOM variation list page --------------
	selectedComplianceReviewId;

	get showChangeStation() {
		return this.stationList && this.stationList.length > 0;
	}

	procedureCompliancesGrouped;
	stationListAccountRoleIds;
	@track chapterList;

	@wire(getAllPublishedGapAnalyses, { stationId: '$selectedAccountRoleDetailId' })
	actualGapAnalyses;

	@wire(getProcedureCompliances, { complianceReviewId: '$selectedComplianceReviewId' })
	getProcedureCompliances({ data, error }) {
		if (data && data.some(el => el.index === undefined)) {
			util.debug.error('Some of the indexes were not calculated, probably because some of the Procedure Compliances have differing ids or because there are different manuals in the related objects.');
		}
		if (data) {
			let chapters = util.array.group(
				data, 
				el => el.index.chapterId, 
				el => el.index.chapterName
			);
			for (const chapter of chapters) {
				chapter.sections = util.array.group(
					chapter.list, 
					el => el.index.sectionId, 
					el => el.index.sectionName
				);
				chapter.list = chapter.list.filter(proc => !proc.index.sectionId);
			}
			this.procedureCompliancesGrouped = chapters;
			this.chapterList = chapters.map(el => ({ id: el.id, name: el.name, href: '#'+el.id, class: '' }));
			if (this.chapterList.length > 0) {
				this.chapterList[0].class = 'selected';
			}
		}
	};

	@wire(stationSummaries, { stationIds: '$stationListAccountRoleIds'})
    statusSummariesWired({ data, error}) {
        if (data) {
            for (const accountRoleId of Object.keys(data)) {
                const stationData = this.stationList.find(station => station.accountRoleId === accountRoleId);
                if (stationData) {
                    stationData.lastRevision = data[accountRoleId].lastGapAnalysisDate;
                    stationData.variations = data[accountRoleId].lastGapAnalysisVariations;
                    if (data[accountRoleId].readAcknowledgements) {
                        stationData.acknowledgements = data[accountRoleId].readAcknowledgements + '/' + data[accountRoleId].totalAcknowledgements;
                    }
                }
            }
            this.stationList = [...this.stationList];
        }
    }

	get noVariations() {
		return this.procedureCompliancesGrouped && this.procedureCompliancesGrouped.length === 0;
	}
	get someVariations() {
		return this.procedureCompliancesGrouped && this.procedureCompliancesGrouped.length > 0;
	}

	throttledScroll = util.throttle(() => {
		// Get the containers scroll quantity
		let containerTop = this.template.querySelector('.variation-list').scrollTop;
		// Get each headers distance to top
		let headers = Array.from(this.template.querySelectorAll('.variation-list h2'));
		let distances = headers.map(el => ({
			top: (containerTop+headers[0].offsetTop) - el.offsetTop,
			elem: el
		}));
		// Get the minimum that is still positive
		let distancesFiltered = distances.filter(el => el.top >= 0);
		let currentElem = distancesFiltered.reduce((prev, curr) => prev.top < curr.top ? prev : curr).elem;
		// Mark it as active
		this.chapterList.forEach(el => el.id === currentElem.dataset.id ? el.class = 'selected' : el.class = '');
	}, 100);

	renderedCallback() {
		if (this.template.querySelector('.variation-list')) {
			this.template.querySelector('.variation-list').addEventListener('scroll', this.throttledScroll);
		}
	}

	gapAnalaysisChangeHandler(event) {
		const gapAnalysisId = event.detail.gapAnalysisId;
		this.procedureCompliancesGrouped = undefined;
		this.chapterList = undefined;
		this.selectedComplianceReviewId = gapAnalysisId;
	}

	changedShownStationIds(event) {
        const shownIds = event.detail.shownIds;
        if (shownIds && shownIds.length > 0) {
            this.stationListAccountRoleIds = this.stationList.filter(station => shownIds.includes(station.id)).map(station => station.accountRoleId);
        }
    }
}