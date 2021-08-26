body, .slds-scope {
	font-family: var(--lwc-fontFamily, DaMaWebFont) !important;
}

.mfa-main-title {
    font-weight: 500;
    font-size: 24px;
    font-style: normal;
    font-stretch: normal;
    line-height: 1.45;
    letter-spacing: normal;
}

.mfa-main-body {
    text-align: justify;
    text-justify: inter-word;
    font-weight: 400;
    font-size: 16px;
}

.mfa-secondary-title {
    font-weight: 500;
    font-weight: bold;
    font-size: 20px;
    line-height: 26px;
}

.mfa-tertiary-title {
    font-size: 20px;
}

.mfa-tertiary-body {
    text-align: justify;
    text-justify: inter-word;
    font-weight: 400;
    font-size: 16px;
}


.mfa-login-tertiary-title {
    font-size: 16px;
}

.mfa-text-center {
    text-align: center;
}

.mfa-text-input-label {
    text-align: left;
    padding-top: 2.5rem;
    padding-bottom: .5rem;
    font-size: small;
}

.mfa-text-input {
    border-radius: 0px !important;
    border-color: #eaeaea;
    color: #525252;
    padding: 5px 8px;
    font-weight: 400;
    font-size: 18px;
}

.mfa-centered-btn:disabled {
    background: none;
    background-color:#f6f8fa;
    color:#999999 !important;
    border-radius: 1px;
}

.mfa-centered-btn {
    background: none;
    background-color: #3333ff;
    color: white !important;
    border: none;
    padding: 1rem 3rem;
    border-radius: 1px;
    font-weight: 500;
    font-size: 16px;
}

.mfa-centered-btn:hover {
    background-color: #1e32fa;
}

.mfa-centered-btn:hover:disabled {
    background-color:#f6f8fa;
}

.mfa-right-btn {
    background: none;
    background-color: #3333ff;
    color: white;
    border: none;
    padding: 6% 35%;
    border-radius: 1px;
    font-weight: 500;
    font-size: 16px;
}

.mfa-right-btn:disabled {
    background: none;	
    background-color:#f6f8fa;	
    color:#999999;
    border-radius: 1px;	
}

.mfa-right-btn:hover {
    background-color: #1e32fa;
}

.mfa-right-btn:hover:disabled {
    background-color:#f6f8fa;
}

.mfa-left-btn {
    background: none;
    border: none;
    color: #3333ff;
    font-weight: 500;
    font-size: 16px;
    padding: 6% 35%;
    border-radius: 1px;
    background-color: white;
}

.mfa-login-btn {
    background: none;
	background-color: #3333ff;
	color: white !important;
	border: none;
	padding: 1rem 3rem;
	border-radius: 1px;
	width: 100%;
	font-size: 16px;
	font-weight: 500;
    font-weight: 630;
}
.mfa-login-btn:disabled {
    background: none;
	background-color: #f7f8fa;
	color: #999999 !important;
    font-weight: 630;
    border-radius: 1px;
}

.mfa-login-btn:hover {
    background-color: #1e32fa;
}
.mfa-login-btn:hover:disabled {
	background-color: #f7f8fa;
}

.mfa-footer-border-top {
	border-top-style: solid;
	color: #d4d4d485;
}

.mfa-link {
    color: #3333ff !important;
    font-weight: 630 !important;
}

.mfa-troubleshoot-text {
    color: black;
}

.mfa-troubleshoot-btn {
    background: none;
    background-color: white !important;
    color: #3333ff !important;
    border-color: #3333ff;
    border: 1px solid;
    border-radius: 1px;
    padding: 0px 25px;
}

.mfa-troubleshoot-btn:hover {
    background-color: #1e32fa;
}

.mfa-security-question-vl {
    border-left: 1px solid #999999;
    height: 25px;
    margin-top: 6px;
}

.mfa-security-question-activated-lbl {
    color: #289632;
    font-size: 1rem;
    font-weight: bold;
    padding-top: 3px;
}

.mfa-security-question-not-activated-lbl {
    color: #999999;
    font-size: 1rem;
    padding-top: 3px;
}

.mfa-security-question-input-lbl {
    text-align: left;
    font-size: 14px;
}

.mfa-medium-txt {
    font-size: 16px;
}

.mfa-separator {
    border-top: solid 1px #e6e6e6;
}

.mfa-remove {
    color: #dd2217;
}

.mfa-custom-box-shadow {
    border-radius: 1px;
    box-shadow: 0 8px 18px 0 rgb(0 0 0 / 8%), 0 1px 4px 0 rgb(0 0 0 / 4%);
}
	
.mfa-red-txt {	
    color: red;	
}

.cursorPointer {	
    cursor: pointer;	
}

.footerlinks a{
    color:#111111;
    font-weight:normal;
}

.languageSelectWrapper .slds-combobox_container input[role="combobox"] {
    text-align: right !important;
    padding-top: 2px;
}

.languageSelection .slds-combobox_container input[role="combobox"] {
    border:none;
    background-color: transparent;
    height: 32px;
    color: #3333ff;
    font-size: 14px;
    font-weight: 500;
}

.borderlessCombobox, .slds-scope [role=combobox],
.slds-scope [role=combobox] input[readonly],
.slds-scope input[readonly][role=combobox]{
    border: none;
    outline: none;
    outline-style: none;
    box-shadow: none;
    border-color: transparent;
    cursor: pointer;
}

.slds-scope .slds-form-element__label{
    padding-top: 17px;
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

.slds-scope .slds-input__icon-group_right {
    top: 65%;
}

::placeholder {
    color: lightgray;
}

@media screen and (min-width:1600px){
    .settingsContainerWidth{
        width: 60%;
    }

    .settings2FAWidth{
        width: 52%;
    }
}

@media screen and (min-width:2400px){
    .settingsContainerWidth{
        width: 50%;
    }

    .settings2FAWidth{
        width: 42%;
    }
}