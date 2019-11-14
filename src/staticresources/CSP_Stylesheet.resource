body {
    background-color: #f0f2f5;
    /*font-weight: 300;*/
}

.customLightShadow {
    border-radius: 1px;
    box-shadow: 0 8px 18px 0 rgba(0, 0, 0, 0.08), 0 1px 4px 0 rgba(0, 0, 0, 0.04);
}

.slds-col--padded, .comm-layout-column, .siteforceContentArea {
    padding: 0px !important;
}

.mainSearchClass label{
    display: none !important;
}

.maxPageWidth {
	max-width: 1440px;
}

/* Service card box */
.customCardWhiteService{
    border-radius: 1px;
  	box-shadow: 0 8px 18px 0 rgba(0, 0, 0, 0.08), 0 1px 4px 0 rgba(0, 0, 0, 0.04);
  	background-color: #ffffff;
}
.customCardLightGrayService{
    border-radius: 1px;
  	background-color: #f7f8fa;
}

/*used to display the cards for the portal with opaque background */
.customCard{
    box-shadow: 5px 5px 20px #e2e2e2;
    border-radius: 1px;
    border: solid 1px #e2e2e2;
    background-color: rgba(255, 255, 255, 0.4);
}

.customCard::after {
    border-color: transparent transparent #f0f2f5 transparent;
}

.customBorderlessCardWhite .customCard::after,
.resultsContentDiv .customCard::after {
    border-color: transparent transparent #fff transparent;
}

/*used to display the cards for the portal with white background */
.customCardWhite{
    box-shadow: 5px 5px 20px #e2e2e2;
    border-radius: 1px;
    border: solid 1px #e2e2e2;
    background-color: #FFFFFF;
}

/*used to display the cards for the portal with white background and white border*/
.customBorderlessCardWhite{
    box-shadow: 5px 5px 20px #e2e2e2;
    border-radius: 1px;
    border: solid 1px #FFFFFF;
    background-color: #FFFFFF;
}

.customBorderlessCardGray{
    box-shadow: 5px 5px 20px #e2e2e2;
    border-radius: 1px;
    border: solid 1px #f7f8fa;
    background-color: #FFFFFF;
}

/* custom card title box */
.customCardTitleBox{
    background-color: #FFFFFF;
    font-size: 18px;
  	font-weight: 500;
  	font-style: normal;
  	font-stretch: normal;
  	line-height: 1.56;
  	letter-spacing: normal;
  	color: #333333;
}

/* custom background */
.customWhiteBackground {
    background-color: #FFFFFF;
}

.customBlueTitle {
    background-color:#1e32fa;
    font-size: 18px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.56;
    letter-spacing: normal;
    color: #ffffff;
    border-radius: 1px;
}

.customTextInput input{
    box-shadow: none;
    border-color: lightgray;
    border-radius: 0px;
    height: 52px;
    font-size: 16px;
}

.customTextInput .slds-input:focus{
    box-shadow: none;
    border-color: lightgray;
    border-radius: 0px;
    height: 52px;
    font-size: 16px;
}

.customTextArea textarea{
    box-shadow: none;
    border-color: lightgray;
    border-radius: 0px;
    height: 12.2rem;
    font-size: 16px;
}

.customTextArea .slds-textarea:focus{
    box-shadow: none;
    border-color: lightgray;
    border-radius: 0px;
    height: 12.2rem;
    font-size: 16px;
}

/* creates a triangle for the card title */
.triangleRight {
    width: 20px;
    height: 20px;
    border-top: 20px solid transparent;
    border-left: 20px solid #f04632;
    border-bottom: 20px solid transparent;

}

/* Icon colors */
.darkBlueIcon svg {
    fill: #1e32fa;
}

.blackIcon svg {
  fill: black;
}

.orangeIcon svg {
  fill: #ed7756;
}

.greenIcon svg {
  fill: #289632;
}

.redIcon svg {
  fill: red;
}

.whiteIcon svg {
    fill: #FFFFFF;
}

.superlightBlueIcon svg {
    fill: #a5adfd;
}

/*Used to hide label by adding this class to input tag */
.hideInputLabel label{
    display: none !important;
}

/* Input with no borders */
.borderlessInput input {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}
.borderlessInput input:focus {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}

.borderStyle {
    border-bottom-style: solid;
    border-bottom-color: #e6e6e6;
    border-bottom-width: 1px;
}

.cardStyle {
    background-color: #f7f8fa;
}

.grayInputPlaceholder input::placeholder {
  	color: #999999;
}

.grayInputBackground input{
    background-color: #f0f2f5;
}

.grayInputBackground input:focus{
    background-color: #f0f2f5;
}

.searchInputPlaceHolder input::placeholder{
    font-size: 22px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.45;
    letter-spacing: normal;
    color: #cccccc;
}

.searchInputPlaceHolder input{
    font-size: 22px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.45;
    letter-spacing: normal;
    color: #333333;
    caret-color: #1e32fa;
}

/* Spinner container */
.spinnerContainer{
    position: relative;
    display: inline-block;
    width: 100%;
    vertical-align: middle;
    white-space: nowrap;
    height:250px;
}

/* ############################################## */
/* Classes for cases messaging system */

/* Used for case messages send arrow */
.darkBlueSendButton {
    cursor: pointer;
}
.darkBlueSendButton svg {
    fill:#3333ff;
}

/* Used for case messages send arrow */
.lightBlueSendButton svg {
    fill:#a5adfd;
}

.caseMessagesSelfBubble{
    background-color: #525252;
    color:#FFFFFF;
    border-radius: 1px;
    font-size: 14px;
  	font-weight: normal;
  	font-style: normal;
  	font-stretch: normal;
  	line-height: 1.43;
  	letter-spacing: normal;
}
.caseMessagesOtherBubble{
    border-radius: 1px;
  	background-color: #ffffff;
    font-size: 14px;
  	font-weight: normal;
  	font-style: normal;
  	font-stretch: normal;
  	line-height: 1.43;
  	letter-spacing: normal;
  	color: #525252;
}
.caseMessagesMyselfTimestamp{
    font-size: 12px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.67;
    letter-spacing: normal;
    text-align: right;
    color: #999999;
}
.caseMessagesOtherTimestamp{
    font-size: 12px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.67;
    letter-spacing: normal;
    color: #999999;
}
/* ############################################## */


/* ############################################## */
/* Casses for light gray border */
.aroundLightGrayBorder {
    border: solid 1px #e2e2e2;
    border-radius: 1px;
}
.topLightGrayBorder {
    border-top: solid 1px #e2e2e2;
}
.leftLightGrayBorder {
    border-left: solid 1px #e2e2e2;
}
.bottomLightGrayBorder {
    border-bottom: solid 1px #e2e2e2;
}
.rightLightGrayBorder {
    border-right: solid 1px #e2e2e2;
}

.aroundLinkBlueBorder {
    border: solid 1px #1e32fa;
    border-radius: 1px;
}
.topLinkBlueBorder {
    border-top: solid 1px #1e32fa;
}
.leftLinkBlueBorder {
    border-left: solid 1px #1e32fa;
}
.bottomLinkBlueBorder {
    border-bottom: solid 1px #1e32fa;
}
.rightLinkBlueBorder {
    border-right: solid 1px #1e32fa;
}
/* ############################################## */


/* ############################################## */
/* Cursor classes */
.cursorPointer {
    cursor: pointer;
}

.noPointerEvents{
    pointer-events: none;
}

.cursorPointerComboBox input{
    cursor: pointer;
}
/* ############################################## */


/* ############################################## */
/* Table header */
lightning-datatable .slds-th__action {
  text-transform: capitalize;
  font-size: 14px;
}

/* Cases table status styles */

.Pendingcustomer lightning-primitive-cell-wrapper lightning-formatted-text, .ClosedRejected lightning-primitive-cell-wrapper lightning-formatted-text, 
.ClosedDisapproved lightning-primitive-cell-wrapper lightning-formatted-text, .ClosedWithdrawn lightning-primitive-cell-wrapper lightning-formatted-text, 
.AcceptedPendingBG lightning-primitive-cell-wrapper lightning-formatted-text, .AcceptedPendingDocs lightning-primitive-cell-wrapper lightning-formatted-text, 
.AcceptedPendingAgreement lightning-primitive-cell-wrapper lightning-formatted-text, .Returnapplicationtocustomer lightning-primitive-cell-wrapper lightning-formatted-text,
.Pendingcustomer span, .ClosedRejected span, .ClosedDisapproved span, .ClosedWithdrawn span, .AcceptedPendingBG span,
.AcceptedPendingDocs span, .AcceptedPendingAgreement span, .Returnapplicationtocustomer span {
    background-color: #ffa499;
    padding: 4px 6px 2px 6px;
    border-radius: 1px;
    text-transform: uppercase;
    font-size: 11px;
    font-weight: 500;
    color: #525252;
    display: flex;
    align-items: center;
    vertical-align: middle;
}

.Open lightning-primitive-cell-wrapper lightning-formatted-text, .InProgress lightning-primitive-cell-wrapper lightning-formatted-text, .Inprogress lightning-primitive-cell-wrapper lightning-formatted-text,
.Escalated lightning-primitive-cell-wrapper lightning-formatted-text, .EscalatedInternally lightning-primitive-cell-wrapper lightning-formatted-text, 
.EscalatedExternally lightning-primitive-cell-wrapper lightning-formatted-text, .ForReviewandAcceptance lightning-primitive-cell-wrapper lightning-formatted-text, 
.OnHoldExternal lightning-primitive-cell-wrapper lightning-formatted-text, .OnHoldInternal lightning-primitive-cell-wrapper lightning-formatted-text, 
.Reopen lightning-primitive-cell-wrapper lightning-formatted-text, .ClosedNotAccepted lightning-primitive-cell-wrapper lightning-formatted-text, 
.InputRequested lightning-primitive-cell-wrapper lightning-formatted-text, .PendingReconsideration lightning-primitive-cell-wrapper lightning-formatted-text,
.ActionNeeded lightning-primitive-cell-wrapper lightning-formatted-text, .ActionNeeded span, .Open span, .InProgress span, .Escalated span,
.EscalatedInternally span, .EscalatedExternally span, .ForReviewandAcceptance span, .OnHoldExternal span, .OnHoldInternal span,
.Reopen span, .ClosedNotAccepted span, .InputRequested span, .PendingReconsideration span, .Inprogress span{
    background-color: #fac832;
    padding: 4px 6px 2px 6px;
    border-radius: 1px;
    text-transform: uppercase;
    font-size: 11px;
    font-weight: 500;
    color: #525252;
    display: flex;
    align-items: center;
    vertical-align: middle;
}

.Closed lightning-primitive-cell-wrapper lightning-formatted-text, .AcceptedFutureDate lightning-primitive-cell-wrapper lightning-formatted-text, 
.Submitted lightning-primitive-cell-wrapper lightning-formatted-text,
.Closed span, .AcceptedFutureDate span, .Submitted span {
    background-color: #b1e8b5;
    padding: 4px 6px 2px 6px;
    border-radius: 1px;
    text-transform: uppercase;
    font-size: 11px;
    font-weight: 500;
    color: #525252;
    display: flex;
    align-items: center;
    vertical-align: middle;
}

.Draft lightning-primitive-cell-wrapper lightning-formatted-text, .OpenEDMC lightning-primitive-cell-wrapper lightning-formatted-text,
.Draft span, .OpenEDMC span{
    background-color: #f0f2f5;
    padding: 4px 6px 2px 6px;
    border-radius: 1px;
    text-transform: uppercase;
    font-size: 11px;
    font-weight: 500;
    color: #525252;
    display: flex;
    align-items: center;
    vertical-align: middle;
}
/* ############################################## */
@media only screen and (max-device-width: 480px){
  td.cellHidden{
    display: none;
  }
  .casesListWrapper .slds-scrollable_y{
    width: unset !important;
  }

  .casesListWrapper table{
    width: 100% !important;
  }
}

/* ############################################## */

/* ############################################## */
/* Casses for the popups */

.modal {
  position: fixed; /* Stay in place */
  z-index: 2; /* Sit on top */
  padding-top: 100px; /* Location of the box */
  padding-bottom: 50px;
  left: 0;
  top: 0;
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  overflow: auto; /* Enable scroll if needed */
  background-color: rgb(0,0,0); /* Fallback color */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */

}

.customPopupInteriorHalfScreenCentered {
    background-color: #F7F8FA;
    width: 35%;
    margin: auto;
    box-shadow: 5px 5px 20px #808080;
    border-radius: 1px;
    border: solid 1px #e2e2e2;
}

@media only screen and (max-width: 1000px) {
    .customPopupInteriorHalfScreenCentered {
        width: 80%;
    }
}

@media only screen and (max-width: 600px) {
    .customPopupInteriorHalfScreenCentered {
        width: 90%;
    }
}

/* ############################################## */

/* ############################################## */
/* Classes for the buttons */
.twoLines button[type=button],
button.twoLines {
    min-height: 3rem!important;
}
.containedButtonSmaller, 
.containedButtonSmaller button {
  -webkit-transition-duration: 0.4s; /* Safari */
  transition-duration: 0.4s;
  border-radius: 1px;
  box-shadow: 0 6px 16px 0 rgba(56, 86, 235, 0.24),
    0 1px 2px 0 rgba(56, 86, 235, 0.16);
  background-color: #3333ff;
  font-size: 16px;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.5;
  letter-spacing: normal;
  text-align: center;
  color: #ffffff;
  min-height: 50px;
  width: 200px;
  word-break: break-word;
  border: none;
  display: inline-block;
}

.containedButton, .containedButton button, .containedButton button:active, .containedButton button:visited, .containedButton button:focus {
    -webkit-transition-duration: 0.4s; /* Safari */
  	transition-duration: 0.4s;
    border-radius: 1px;
  	box-shadow: 0 6px 16px 0 rgba(56, 86, 235, 0.24), 0 1px 2px 0 rgba(56, 86, 235, 0.16);
  	background-color: #3333ff;
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #ffffff;
    min-height: 40px;
    width: 220px;
    word-break: break-word;
    border: none;
    display: inline-block;
}
.containedButton button:hover {
	border-radius: 1px;
    box-shadow: 0 6px 16px 0 rgba(56, 86, 235, 0.24), 0 1px 2px 0 rgba(56, 86, 235, 0.16);
    background-color: #1e32fa;
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #ffffff;
    min-height: 40px;
    width: 220px;
    word-break: break-word;
    border: none;
}

.containedButton button:disabled, .containedButton button:disabled:hover, .containedButton:disabled, .containedButton.disabledButton {
    background-color: #f7f8fa;
    color: #999999;
    box-shadow: none;
}
@media screen and (max-width: 400px){
  .reachusButton.containedButton button{
    width: unset;
  }
}

.containedButtonSlim, .containedButtonSlim button, .containedButtonSlim button:active, .containedButtonSlim button:visited, .containedButtonSlim button:focus {
    -webkit-transition-duration: 0.4s; /* Safari */
  	transition-duration: 0.4s;
    border-radius: 1px;
  	box-shadow: 0 6px 16px 0 rgba(56, 86, 235, 0.24), 0 1px 2px 0 rgba(56, 86, 235, 0.16);
  	background-color: #3333ff;
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #ffffff;
    min-height: 40px;
    word-break: break-word;
    border: none;
}
.containedButtonSlim button:hover {
	border-radius: 1px;
    box-shadow: 0 6px 16px 0 rgba(56, 86, 235, 0.24), 0 1px 2px 0 rgba(56, 86, 235, 0.16);
    background-color: #1e32fa;
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #ffffff;
    min-height: 40px;
    word-break: break-word;
    border: none;
}

.containedButtonAlt {
    -webkit-transition-duration: 0.4s;
    /* Safari */
    transition-duration: 0.4s;
    border: 1px #33f solid;
    box-shadow: none;
    background-color: white;
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #33f;
    min-height: 40px;
    height: 56px;
    width: 220px;
    word-break: break-word; 
}

.containedButton-size {
    height: 56px;
    width: 200px;
}

.filterButton,
.filterButton button,
.filterButton button:active {
  background-color: #d0d6fa;
  transition-duration: 0.4s;
  border-radius: 1px;
  font-size: 16px;
  font-weight: 500;
  font-style: normal;
  font-stretch: normal;
  line-height: 1.5;
  letter-spacing: normal;
  text-align: center;
  color: #3333ff;
  min-height: 40px;
  width: 220px;
  word-break: break-word;
  border: none;
}

.fullWidth, .fullWidth button, .fullWidth button:active, .fullWidth button:visited, .fullWidth button:focus, .fullWidth button:hover {
    width: 100%;
}

.outlinedButton, .outlinedButton button, .outlinedButton button:active, .outlinedButton button:visited, .outlinedButton button:focus{
    -webkit-transition-duration: 0.4s; /* Safari */
  	transition-duration: 0.4s;
    min-height: 48px;
    word-break: break-word;
    border-radius: 1px;
  	border: solid 1px #1e32fa;
  	background-color: #ffffff;
    font-size: 16px;
  	font-weight: 400;
  	font-style: normal;
  	font-stretch: normal;
  	line-height: 1.5;
  	letter-spacing: normal;
  	text-align: center;
  	color: #3333ff;
}
.outlinedButton button:hover {
	-webkit-transition-duration: 0.4s; /* Safari */
  	transition-duration: 0.4s;
    min-height: 48px;
    word-break: break-word;
    border-radius: 1px;
  	border: solid 1px rgba(0, 0, 0, 0.08);
  	background-color: #ffffff;
    font-size: 16px;
  	font-weight: 400;
  	font-style: normal;
  	font-stretch: normal;
  	line-height: 1.5;
  	letter-spacing: normal;
  	text-align: center;
  	color: #3333ff;
}

.blueCustomButtonLink, .blueCustomButtonLink button, .blueCustomButtonLink button:active, .blueCustomButtonLink button:visited, .blueCustomButtonLink button:focus {
	color: #3333ff;
    fill: #3333ff;
    border: none;
  font-weight: 500;
  font-size: 14px;
}

.blueCustomButtonLink button:hover {
	color: #3333ff;
    fill: #3333ff;
    border: none;
  font-weight: 500;
  font-size: 14px;
}

.buttonInfo {
    background-color: rgba(255, 255, 255, 0.15);
    border: 1px rgba(255, 255, 255, 0.15) solid;
    font-size: 16px;
    font-weight: 500;
    color: #33f;
}

.heigthInfo {
    height: 70px;
}

.slds-button_icon-bare {
  display: none;
}

.slds-hint-parent {
  height: 66px;
}

.rowHeight .slds-hint-parent {
  height: 30px;
}

.rowHeight .slds-table_header-fixed_container.slds-scrollable_x {
  overflow: unset;
}

.text-black lightning-formatted-url a {
    color: #000000;
}

/* ############################################## */
/* Text Sizing */

.text-xlarge{
    font-size: 40px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.35;
    letter-spacing: normal;
}

.text-large{
    font-size: 32px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.25;
    letter-spacing: normal;
}

.text-medium{
    font-size: 22px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.45;
    letter-spacing: normal;
}

.text-small{
    font-size: 18px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.33;
    letter-spacing: normal;
}

.text-xsmall{
    font-size: 16px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
}

.text-xxsmall{
    font-size: 14px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.43;
    letter-spacing: normal;
}

.text-xxxsmall{
    font-size: 12px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.43;
    letter-spacing: normal;
}

.text-bold{
    font-weight: 500;
}

/* ############################################## */
/* Text Colors */

.text-blue{
    color: #3333ff;
}

.text-white{
    color: #FFFFFF;
}

.text-black{
    color: #000000;
}

.text-darkGray{
    color: #333333;
}

.text-gray{
    color: #525252;
}

.text-lightGray{
    color: #999999;
}

.text-linkBlue{
    color: #1e32fa;
}

.text-transparent{
    color: rgba(255, 255, 255, 0.6);

}

/* ############################################## */
/* Background Colors */

.background-blue{
    background-color: #3333ff;
}

.background-white{
    background-color: #FFFFFF;
}

.background-black{
    background-color: #000000;
}

.background-darkGray{
    background-color: #333333;
}

.brackground-silverGray{
    background-color: #e2e4e8;
}

.background-gray{
    background-color: #525252;
}

.background-lightGray{
    background-color: #999999;
}

.background-superLightGray{
    background-color: #f0f2f5;
}

.background-anotherGray{
    background-color: #f7f8fa;
}

.background-linkBlue{
    background-color: #1e32fa;
}

.background-transparent{
    background-color: rgba(255, 255, 255, 0.6);

}

/* ############################################## */
/* Combobox */

.slds-combobox_container input[role="textbox"] {
	height: 52px;
    border-radius: 1px;
    cursor: pointer;
}

.slds-combobox_container input[role="textbox"]:not(:placeholder-shown) {
    background-color: #f7f8fa;
}
.slds-combobox_container .slds-input__icon_right lightning-primitive-icon svg{
    opacity: 0;
}

.slds-combobox_container .slds-input__icon_right lightning-primitive-icon {
    position: relative;
}

.slds-combobox_container .slds-input__icon_right lightning-primitive-icon:before{
    content: '';
    position: absolute;
    border-top: 6px solid #1e32fa;
    border-bottom: 0;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    top: 5px;
    left: 0px;
}
.slds-combobox_container .slds-is-open .slds-input__icon_right lightning-primitive-icon:before{
    content: '';
    position: absolute;
    border-top: 0;
    border-bottom: 6px solid #1e32fa;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    top: 5px;
    left: 0px;
}
.slds-combobox_container .slds-input__icon_right lightning-primitive-icon:after{
    content: "";
    position: absolute;
    border-top: 6px solid #fff;
    border-bottom: 0;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    top: 2px;
    left: 0px;
}
.slds-combobox_container .slds-is-open .slds-input__icon_right lightning-primitive-icon:after{
    content: "";
    position: absolute;
    border-top: 0;
    border-bottom: 6px solid #fff;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    top: 8px;
    left: 0px;
}

.languageSelection .slds-combobox_container
  .slds-input__icon_right
  lightning-primitive-icon:after {
    content: "";
    position: absolute;
    border-top: 0;
    border-bottom: 6px solid transparent;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    top: 8px;
    left: 0px;
  }

.languageSelection .slds-combobox_container
  .slds-is-open
  .slds-input__icon_right
  lightning-primitive-icon:after {
    content: "";
    position: absolute;
    border-top: 0;
    border-bottom: 6px solid transparent;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    top: 8px;
    left: 0px;
  }

.languageSelection .slds-combobox_container input[role="textbox"]{
    border:none;
    background-color: transparent;
}

.languageSelection .slds-combobox_container input[role="textbox"]:not(:placeholder-shown) {
    background-color: transparent;
}

.languageSelection .slds-combobox_container input[role="textbox"] {
    height: 32px;
    color: #3333ff;
    font-size: 14px;
    font-weight: 500;
    text-align: center;
}

.slds-combobox_container lightning-base-combobox-item:hover,
.slds-combobox_container lightning-base-combobox-item[aria-selected="true"] {
    background-color: #f7f8fa !important;
}

.borderlessCombobox input {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}
.borderlessCombobox input:focus {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}

.borderlessCombobox [role="combobox"] input[readonly]:focus {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}
.customCombobox-noArrow svg {
    display: none;
}

.customCombobox-noLabel label {
    display: none;
}

.customCombobox input {
    height: 3.2rem;
}

.innerHeaderCss .slds-button .slds-button__icon_right,
.innerHeaderCss .slds-button .slds-button__icon--right {
  margin-left: 10px;
  display: block;
}
.innerHeaderCss .blueCustomButtonLink .slds-button {
  line-height: .875rem;
}
/* ############################################## */
/* Text Area */

.borderlessTextArea textarea {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
    display: flex;
}

.borderlessTextArea textarea:focus {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}

.borderlessTextArea textarea:active {
  	border: none;
    outline: none;
    outline-style:none;
	box-shadow:none;
	border-color:transparent;
}

.height5LinesTextArea textarea{
    height: 7rem;
}

/* TAB AREA */

.tabNotificationCenter .slds-tabs_default__content {
    overflow-y: auto;
    max-height: 432px;
    padding: 0px;
    min-width: 340px;
}

/* REMOVE BOTTOM BORDER*/
.tabNotificationCenter .slds-tabs_default__nav {
    border-bottom: none;
    margin-left: 26px;
}

/* BOTTOM BORDER WHEN OVER / FOCUS */
.tabNotificationCenter .slds-tabs_default__item:hover:after, .tabNotificationCenter .slds-tabs--default__item:hover:after, .tabNotificationCenter .slds-tabs_default__item.slds-has-focus:after {
    background-color: rgb(194, 57, 52);
    height: 2px;
}

/* BOTTOM BORDER*/
.tabNotificationCenter .slds-tabs_default__item.slds-active:after, .tabNotificationCenter .slds-tabs_default__item.slds-is-active:after {
    background-color: rgb(194, 57, 52);
    height: 4px;
}

/* TEXT COLOR */
.tabNotificationCenter .slds-tabs_default__item.slds-is-active, .tabNotificationCenter .slds-tabs_default__item {
    color: #525252;
    font-size: 14px;
}

/* REMOVE TEXT UNDERLINE */
.tabNotificationCenter .slds-tabs_default__item.slds-is-active.slds-has-focus a {
    text-decoration: none;
}

/******************************/
/**Case Attachment List **/

/* Table Header*/
.attlist .slds-cell-fixed{

  	color: #999999;
  	font-size: 14px;
    height: 20px;
  	line-height: 1.43;
  	letter-spacing: normal;
    text-transform: none;
    background-color: #f6f7f9;
}
.attlist .slds-cell-fixed:hover,.attlist .slds-th__action:focus, .attlist .slds-th__action:hover{
    background-color: #f6f7f9;
}


/*       New Documents Button Overrides*/
.newattlist .slds-cell-fixed,.newattlist .slds-has-button-menu{
     text-transform: none;
}
.newattlist button{
    border:0;
    background-color: #00000000;
}
.newattlist button:hover,.newattlist button:active {
    border: 0;
    color: #3333ff;
    background-color: #00000000;
    font-weight: 600;
    box-shadow: none;
    cursor: pointer;
}

.newattlist tr{
	background: rgba(30, 50, 250, 0.03)
}

.attlist .slds-table_header-fixed_container,.attlist .slds-has-focus{
   background-color: #00000000;
   overflow-x: hidden;
}
.attlist .slds-has-button-menu:hover{
  	background: #f6f7f9;
}

.attlist .slds-has-button-menu{
   background: #f6f7f9;
}
.attlist .slds-button_neutral{
    border :	0;
   	color: #3333ff;
    background-color:rgba(217, 219, 221, 0);
}
.attlist .slds-button_neutral:hover,.attlist .slds-button_neutral:focus{
    background-color:rgba(217, 219, 221, 0);
    font-size:600;
}
.attlist .view_attachment_link a{
    color: #3333ff;
    font-weight: 600;
    text-align: center;
}

.attlist .view_attachment_link a:active, .attlist .view_attachment_link a:hover{
    color: #3333ff;
    font-weight: 600;
  }
  .attlist .view_attachment_link {
    font-size: 14px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.71;
    letter-spacing: normal;
    color: #4a4d61;
  }
  
  .attlist .slds-scrollable_y {
    min-height: 200px;
    max-height: 500px;
	overflow-x:hidden;
}


.attButtonCls .slds-button:hover{
    background-color:rgba(217, 219, 221, 0);
    font-size:600;
}

.attButtonCls .slds-button:hover,.attButtonCls .slds-button:active{
    border: 0;
    color: #3333ff;
    background-color: #00000000;
    font-weight: 600;
    box-shadow: none;
    cursor: pointer;
}

.attButtonCls button{
    border:0;
    background-color: #00000000;
}

.greybox-noborder {
    width: 200px;
    border: 0px;
}

.recipientInput {
    height: 52px;
    width: 415px;
}

.whiteButtonBlueBorder{
    background-color: #ffffff;
    border-radius: 1px;
    border: solid 1px #1e32fa;
  }
  .whiteButtonBlueBorder button {
    
    /*Overide button*/
    background: inherit;
    border: 0px;
    text-shadow: none;
    box-shadow: none;
}
.whiteButtonBlueBorder button,.whiteButtonBlueBorder button:hover{
  background: inherit;
  border: 0px;
  box-shadow: none;
  text-shadow: none;

}


/* Extends drop file area*/
.uploadFileArea lightning-primitive-file-droppable-zone{
    width:100%;
}


.uploadFileArea lightning-primitive-file-droppable-zone > slot{
	width: 95%;
	display: flex;
	align-items: center;
	justify-content: center;
	height: 100px;
}

/* Overrides button in upload area*/
.uploadFileArea .slds-file-selector__button{
    border: 0;
    color: #3333ff;
    padding: 0px;
    cursor: pointer;
    font-weight: 600;
}


.uploadFileArea .slds-file-selector_files{
    width: 100%;
}

/* Override Icon color on paginator*/
.inactiveNavButton svg{
    fill:#cccccc;
}
.activeNavButton svg{
    fill:#666666;;
}

/* Override upload file progress bar*/
.slds-progress-bar__value{
   background: #1e32fa;
}

/* Override the height of the spinner in support reach us*/
.viewHeight {
  height: 250vh;
}

/* Base CMP overrides for Profile sections */

.labelValue .slds-form-element__label {
    font-size: 14px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.43;
    letter-spacing: normal;
    color: #525252;
    padding-top: 5%;
	display: contents;
}

.labelValue .slds-checkbox .slds-form-element__label {
    display:none;
}

.textValue .slds-checkbox_standalone {
  cursor: pointer;
}

.textValue input[type="checkbox"] {
  box-sizing: border-box;
  padding: 0;
}

.textValue .slds-checkbox_standalone input{
  font-size: 1rem;
  opacity: 0;
  position: absolute;
}

.textValue .slds-checkbox_faux {
	border-radius:0;
    position: relative;
    display: inline-block;
    width: 20px;
    height: 20px;
    right: 2px;
    top: -4px;
    vertical-align: middle;
    background-color: inherit;
    color: blue;
    border: 1px solid blue;
}

.textValue .slds-checkbox_standalone input:checked + .slds-checkbox_faux:after{
  content: "";
  display: block;
  position: absolute;
  top: 2px;
  left: 2px;
  width: 14px;
  height: 14px;
  background-color: blue;
  transform:none;
}

.textValue .slds-checkbox_standalone input:checked + .slds-checkbox_faux{
  border-color: blue;
}

.textValue .slds-checkbox_faux{
  transform: scale(0.75);
}

.textValue .slds-form-element__static {
  	font-size: 18px;
  	font-weight: normal;
  	font-style: normal;
  	font-stretch: normal;
  	line-height: 1.63;
  	letter-spacing: normal;
  	color: #333333;
	white-space: normal;
}

.textValue input{
    background-color: #f7f8fa !important;
    border-radius: 1px !important;
    border: solid 1px #e6e6e6 !important;
    color:#333333 !important;
    height: 52px;
}

.borderedValue .slds-form-element__static {
 background-color: #f7f8fa !important;
    border-radius: 1px !important;
    border: solid 1px #e6e6e6 !important;
    color:#333333 !important;
    height: 52px;
}

.textValue textarea{
	height: 52px;
    background-color: rgb(247, 248, 250) !important;
    border-radius: 1px !important;
    border: 1px solid rgb(230, 230, 230) !important;
    color: rgb(51, 51, 51) !important;
    margin-top: 0px;
    margin-bottom: 0px;
}

.whiteBackgroundInput input, .whiteBackgroundInput textarea{
	background-color:white !important;
	cursor:default;
}

.textValue input:disabled,.textValue textarea:disabled {
  background-color: #f7f8fa;
  color: #999999 !important;
  cursor:default;
}

.disabledValue input{
    color:#999999 !important;
    cursor:default;
}

.invalidValue input, .invalidValue textArea{
    background-color: rgb(255, 255, 255);
    border-color: rgb(194, 57, 52) !important;
    box-shadow: rgb(194, 57, 52) 0 0 0 1px inset  !important;
    background-clip: padding-box  !important;
}


.disabledValue .slds-input__icon-group_right{
    display:none;
}

.textValue .slds-form-element__legend{
    display:none;
}

.textValue .slds-form-element__control{
	padding:0;
}

.textValue .slds-required, .textValue .slds-icon_container{
	display:none;
}

.searchInput, .searchInput input::placeholder{
    font-family: DaMaWebFont;
    font-size: 16px;
    font-weight: normal;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.63;
    letter-spacing: normal;
    color: #9a9eb0;
}

/* End of Profile section overrides*/

.toastMessage .slds-notify_toast {
  min-width:20rem;
}

.toastMessage .slds-notify_toast .slds-text-heading_small {
  font-size:16px;
}
  
.toastMessage .slds-notify_toast p {
  font-size:16px;
}

.containedButtonWhite {
    background-color: #ffffff;
    transition-duration: 0.4s;
    border-radius: 1px;
    box-shadow: 0 6px 16px 0 rgba(1, 1, 1, 0.24), 0 1px 2px 0 rgba(1, 1, 1, 0.16);
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #3333ff;
    min-height: 40px;
    width: 220px;
    word-break: break-word;
    border: none;
}

.containedButtonWhite button,
.containedButtonWhite button:hover {
    background-color: #ffffff;
    transition-duration: 0.4s;
    border-radius: 1px;
    font-size: 16px;
    font-weight: 500;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.5;
    letter-spacing: normal;
    text-align: center;
    color: #3333ff;
    min-height: 40px;
    width: 220px;
    word-break: break-word;
    border: none;
    display: inline-block;
    min-height: 40px;
}

/* Custom picklist Support Reach Us*/

.customPickList input {
    border: solid 1px #e6e6e6;
    border-radius: 1px;
    height: 52px;
}

.customPickList input:focus{
    border-color: #e6e6e6;
    box-shadow: none;
}

/* Date input */
.dateField input {
    background-color: #f7f8fa;
    border-radius: 1px;
    cursor: pointer;
    border-color: #d4d4d4;
}

/* Custom card sizing Support Reach Us*/
.cardSizing {
    width: 270px;
    height: 180px;
}

.currentSlideIcon svg {
    fill: #f04632;
}

.slideIcon svg {
    fill: #e2e2e2;
}

/* Footer select language styles */
.portalFooter .langSelect input[role="textbox"], .portalFooter .langSelect div[role="listbox"] {
    background-color: #333333;
    border-radius: 0;
}

.portalFooter .langSelect input[role="textbox"] {
    border: 0;
    cursor: pointer;
}

.portalFooter .langSelect div[role="listbox"] {
    max-width: unset;
    width: 140px;
}

.portalFooter .changingLangSpinner .slds-spinner_container {
   position: fixed;
}

.portalFooter .langSelect .slds-form-element__label {
   display: none;
}

.portalFooter .slds-combobox_container lightning-base-combobox-item:hover,
.portalFooter .slds-combobox_container lightning-base-combobox-item[aria-selected="true"] {
    color: #333 !important;
}

.portalFooter .slds-combobox_container .slds-input__icon_right lightning-primitive-icon:before{
    border-top: 6px solid #fff;
    border-bottom: 0;
}
.portalFooter .slds-combobox_container .slds-is-open .slds-input__icon_right lightning-primitive-icon:before{
    border-bottom: 6px solid #fff;
    border-top: 0;
}
.portalFooter .slds-combobox_container .slds-input__icon_right lightning-primitive-icon:after{
    border-top: 6px solid #333;
    border-bottom: 0;
}
.portalFooter .slds-combobox_container .slds-is-open .slds-input__icon_right lightning-primitive-icon:after{
    border-bottom: 6px solid #333;
    border-top: 0;
}

.portalFooter .slds-combobox_container input[role="textbox"] {
	height: 32px;
}

.portalFooter .slds-combobox_container .slds-input__icon_right lightning-primitive-icon svg{
    fill: #fff;
}

.portalFooter .iataPages>div {
    width: 100%;
}

.serviceContactList .slds-dropdown{
    border-radius: 0;
}
.serviceContactList svg{
visibility: hidden;
}

.serviceContactList button{
    border: 0;
    background-image: url(/csportal/s/CSPortal/Images/Icons/more.svg);
}

.removeArrowFromButtonMenu button > :nth-child(2) {
  display: none;
}

.introMessage span a {
    color: #3333ff;
}

/*Used to limit the height of the dropdownlist*/
.customDropDownMaxHeight .slds-dropdown_length-with-icon-10 {
    max-height: calc(10rem);
}

/* USER INACTIVE POPUP */
.siteforcePanelsContainer>div{
    z-index: 5000 !important;
}

.headerContainerShadow {
    position: relative;
    display: flex;
}

.headerContainerShadow > div {
    z-index: 1;
}

.headerContainerShadow::after {
    content: "";
    position: absolute;
    width: calc(100vw/2);
    height: 125px;
    left: calc((-100vw + 100%) / 2);
    top: -10px;
    border-radius: 150px 0 0 0;
    z-index: 0;
    opacity: 0.1;
    background-image: linear-gradient(256deg, rgba(0, 0, 0, 0), #000000);
}

/* Mobile side menu select language styles */

.sideBar .langSelect,
.sideBar .langSelect input[role="textbox"],
.sideBar .langSelect div[role="listbox"] {
    background-color: #1e32fa;
    border-radius: 0;
}

.sideBar .langSelect input[role="textbox"] {
    border: 0;
    cursor: pointer;
    width: 140px;
    text-align: center;
}

.sideBar .langSelect div[role="listbox"] {
    max-width: unset;
    width: 140px;
}

.sideBar .changingLangSpinner .slds-spinner_container {
   position: fixed;
}

.sideBar .langSelect .slds-form-element__label {
   display: none;
}

.sideBar .slds-combobox_container lightning-base-combobox-item:hover,
.sideBar .slds-combobox_container lightning-base-combobox-item[aria-selected="true"] {
    color: #1e32fa;
}

.sideBar .slds-combobox_container .slds-input__icon_right lightning-primitive-icon:before {
    border-top: 6px solid #fff;
    border-bottom: 0;
}
.sideBar .slds-combobox_container .slds-is-open .slds-input__icon_right lightning-primitive-icon:before {
    border-bottom: 6px solid #fff;
    border-top: 0;
}
.sideBar .slds-combobox_container .slds-input__icon_right lightning-primitive-icon:after {
    border-top: 6px solid #1e32fa;
    border-bottom: 0;
}
.sideBar .slds-combobox_container .slds-is-open .slds-input__icon_right lightning-primitive-icon:after {
    border-bottom: 6px solid #1e32fa;
    border-top: 0;
}

.sideBar .slds-combobox_container input[role="textbox"] {
	height: 32px;
}

.sideBar .slds-combobox_container .slds-input__icon_right lightning-primitive-icon svg {
    fill: #fff;
}

.button_no_margin button{
    margin: -10px !important;
}

.blueLink a {
	color: #1e32fa;
}

/*-- Hides search icons from inputs in Edge and IE --*/
.searchBarBar input[type="text"]::-ms-clear {
    display: none;
}
  
