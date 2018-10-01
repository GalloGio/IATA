.cHeaderPanel {
	width:100%;
	background-color:white;
	height:140px;
	position:absolute;
}

@font-face {
    font-family:'iataIcons';
    src: url('/identity/s/OneIdResources/fonts/iataIcons.woff') format('woff'),
		 url('/identity/s/OneIdResources/fonts/iataIcons.ttf') format('truetype'),
		 url('/identity/s/OneIdResources/fonts/iataIcons.svg') format('svg');
    font-weight:normal;
    font-style:normal
}
.icon {
    font-family:'iataIcons'!important;
    speak:none;
    font-style:normal;
    font-weight:normal;
    font-variant:normal;
    text-transform:none;
    line-height:1;
    -webkit-font-smoothing:antialiased;
    -moz-osx-font-smoothing:grayscale
}

.icon-cns {
    display:block;
    background-image:url(/identity/s/OneIdResources/images/logocns.png);
    background-repeat:no-repeat;
    width:100%;
    height:90px;
    margin-left:5px
}

.icon.icon-menuDownArrow {
    line-height:1;
    font-size:.45rem;
    margin:0 10px 0 5px
}
.icon.icon-setupCog {
    font-size:1rem
}
.icon-minimenu:before {
    content:"\e927"
}
.icon-community:before {
    content:"\e900"
}
.icon-tick:before {
    content:"\e901"
}
.icon-questionMark:before {
    content:"\e902"
}
.icon-setupCog:before {
    content:"\e903"
}
.icon-arrowDown:before {
    content:"\e904"
}
.icon-menuDownArrow:before {
    content:"\e905"
}
.icon-magnifier:before {
    content:"\e928"
}
.icon-arrow:before {
    content:"\e929"
}
.icon-arrowLeft:before {
    content:"\e996"
}
.icon-navArrowLeft:before {
    content:"\e946"
}
.icon-navArrowRight:before {
    content:"\e95c"
}
.icon-navArrowDown:before {
    content:"\e948"
}
.icon-info:before {
    content:"\e965"
}
.icon-course:before {
    content:"\e966"
}
.icon-distance:before {
    content:"\e967"
}
.icon-factory_s:before {
    content:"\e947"
}
.icon-walkingPassenger_s:before {
    content:"\e949"
}
.icon-radar_s:before {
    content:"\e953"
}
.icon-airport_s:before {
    content:"\e954"
}
.icon-plane_s:before {
    content:"\e955"
}
.icon-groundman_s:before {
    content:"\e956"
}
.icon-speaker2:before {
    content:"\e957"
}
.icon-boxes_s:before {
    content:"\e958"
}
.icon-handshake_s:before {
    content:"\e959"
}
.icon-building_s:before {
    content:"\e95a"
}
.icon-passenger_s:before {
    content:"\e95b"
}
.icon-authority:before {
    content:"\e968"
}
.icon-facebook:before {
    content:"\e94d"
}
.icon-gplus:before {
    content:"\e94e"
}
.icon-youtube:before {
    content:"\e950"
}
.icon-twitter:before {
    content:"\e94f"
}
.icon-linkedin:before {
    content:"\e951"
}
.icon-rss:before {
    content:"\e952"
}
.icon-instagram:before {
    content:"\e964"
}
.icon-emptyCircle:before {
    content:"\e94b"
}
.icon-fullCircle:before {
    content:"\e94c"
}
.icon-quotes:before {
    content:"\e95d"
}
.icon-quotes-end:before {
    content:"\e945"
}
.icon-logo:before {
    content:"\e94a"
}
.icon-boxes:before {
    content:"\e900"
}
.icon-walkingPassenger:before {
    content:"\e901"
}
.icon-plane:before {
    content:"\e916"
}
.icon-handshake:before {
    content:"\e92d"
}
.icon-speaker:before {
    content:"\e926"
}
.icon-persona:before {
    content:"\e960";
    padding-right:10px
}
.icon-share:before {
    content:"\e92a";
    margin-left:-2px
}
.icon-printer:before {
    content:"\e92b"
}
.icon-enveloppe:before {
    content:"\e92c"
}
.icon-enveloppeRound:before {
    content:"\e95e"
}
.icon-rssRaw:before {
    content:"\e95f"
}
.icon-support:before {
    content:"\e961"
}
.icon-resources:before {
    content:"\e962"
}
.icon-emptyCircle:before {
    content:"\e94b"
}
.uiMenu {
    position:absolute;
    right:40px;
    top:24px;
    width:auto;
    border:none;
    border-radius:0;
    z-index:10;
    text-align:left;
    background-color:#fff
}

.oiHeader a.homeIcon {
    display:block;
    margin-left:15px;
    border:0;
    background-color:#fff;
    position:absolute;
    text-align:center;
    z-index:9;
    height:140px;
    width:142px;
    font-size:71px;
    padding-top:20px;
    color:#0A4278 !important;
    text-decoration:none;
    box-shadow: 0px 11px 21px -8px rgba(0, 0, 0, 0.2);
}

a.homeIcon:hover {
    text-decoration: none !important;
}

.oiHeader a.homeIcon .icon-logo {
    padding-bottom:16px;
    background-color:#fff;
    display:block
}

.oiHeader a.homeIcon .subLogo {
    display:block;
    border-top:3px solid #0A4278;
    background-image:url(/identity/s/OneIdResources/images/oisubLogo_ISSP.png);
    width:100%;
    background-repeat:no-repeat;
    height:26px;
    background-position-y:7px
}
.oiHeader a.homeIcon .logoTitle {
    display:block;
    border-top:3px solid #0A4278;
    font-size:12px
}

#bgHeader {
    position:absolute;
    width:100%;
    background-color:#00305b;
    height:52px;
    z-index:0;
    left:0
}


#footer {
    clear:both;
    padding:0;
    background-color:#00305b;
    width:100%;
    z-index:1;
    height:180px;
    position: relative;
}

#footer .widthLimiter {
    background-color:#00305b
}
#footer .header {
    background-color:#0a4279;
    width:100%;
    height:60px;
    padding-top:30px;
    padding-bottom:30px;
    display:inline-table
}
#footer .header .widthLimiter {
    background-color:#0a4279
}
#footer .header h2 {
    max-width:1180px;
    margin:13px auto 0;
    font-size:35px !important;
    color:#fff;
    font-weight:normal;
    font-family:"Arial", sans-serif;
    display:inline-block
}
#footer .header .icon-logo {
    font-size:48px;
    margin-left:5px;
    margin-right:40px;
    color:#fff
}
#footer .iataItem_Icon:hover {
    background: white;
    color: #00305b;
    cursor: pointer;
}
#footer .copyright {
    max-width:1180px;
    font-size:14px;
    padding:20px 0;
    color:#9aa3b7
}
#footer .copyright ul {
    float:right
}
#footer .copyright ul li {
    display:inline-block;
    border-left:1px solid #fff;
    padding:0 10px
}
#footer .copyright ul li:first-child {
    border-left:0
}
#footer .copyright p {
    margin-top: 14px;
}
#footer a:link, #footer a:visited {
    color: #fff !important;
    text-decoration: none;
    text-transform: uppercase;
}
#footer .icon_subTitle {
    font-family:"Arial", sans-serif;
    text-align:center;
    font-size:0.65rem;
    letter-spacing:0.08rem;
    padding-top: 10px;
}
#footer .footerEl {
    font-size:1.58em;
    display:inline-block;
    width:130px;
    margin-left:10px;
    margin-right:10px;
    margin-top:41px
}
#footer .iataItem_Icon {
    border-color:#bbb;
    border-radius:50%;
    border-style:solid;
    border-width:1px;
    height:64px;
    width:64px;
    position:relative;
    margin-left:32px;
    text-align:left
}
#footer .iataItem_Icon .icon {
    display: block;
    text-align: center;
    line-height: 62px;
}
#footer a{
    text-decoration:none !important;
}


.centerAll {
    text-align:center
}

.oiHeader {
    /*margin-top: -34px;*/
    position: relative;
}


/***************************************************************/

/****************************** Online Accreditation Forms **************************/

        .datePicker{
            z-index:9999;
        }
        .ui-autocomplete{  
            z-index:9999 !important;
        }
        .ui-dialog{  
            z-index:9999 !important;
        }
        .adlabel  {
         font-size: 91%;
         text-align: right;
         }
         
         .address-label {
           padding-left:30px;
         }
        .pbTitle {
            width: {!IF(isstep2,'90% !important','40% !important')};
        }
       
       .pbBody {
        padding-left:10px !important;    
       }
        
               
        .bPageBlock {
            border-top-width : thin !important;
        }
        
        .bPageBlock .detailList tr td, .bPageBlock .detailList tr th, .hoverDetail .bPageBlock .detailList tr td, .hoverDetail .bPageBlock .detailList tr th {
        border: none !important;
       }
        
      .pageNav {
    font-size: 10pt;
    top: 250px;
    left: 0px;
    height: auto;
    margin-bottom: 0;
    margin-left: 10px;
    margin-right: 0;
    padding-bottom: 0;
    padding-left: 0px;
    padding-right: 10px;
    padding-top: 3px;
    position: fixed;
    width: 8%;
    z-index: 100;
    color: #fff;
    padding: 4px 6px;
    background-color: #1797c0;
    border-top-right-radius: 6px;
    border-bottom-right-radius: 6px;
    font-weight: normal;
	}
        
        .pageNav a {
    		color: #fff !important;
		}
        
		p.LOB {
    		color: #fff !important;
			font-size: 120%;
			font-weight: bold;
			text-align: center;
		}
        
        .bEditBlock input {
            vertical-align:top !important;
        }
       
       .btn {
            padding: 2px 12px !important;
        }
                             
        .btn-primary {
            color: #fff !important;
            background: inherit !important;
            background-color: #337ab7 !important;
            border-color: #2e6da4 !important;
            border: 1px solid transparent !important;
            /*background: */
        }
        
        .tb-header {
            padding-right:20px;
        }
                 
        .modalrow {
            padding-top:10px;
        }
            
        #contentWrapper {  background: #fff !important; margin: 0 auto;max-width: 1170px;min-height:600px}
            
        .requiredText {display:none;}
        
        .dateFormat {display:none;}
        
        .errorMsg {color:#d74c3b}
            
        .progress-bar-off {
                color:#6BBBEA;
                font-weight:bold;
                background-image:none !important;
                background-color:transparent !important;
                border-right:2px solid white;
        }
        
        body .bPageBlock .pbBody .pbSubheader{
                background-image: url('') !important;
                background-color:  #1797c0;
                color: #fff;
        }

        body .bPageBlock .pbBody .summary-subsection .pbSubheader{
                background-image: url('') !important;
                background-color: initial;
                color: initial;
        }
        
        .pbSubheader {
            font-weight:bold;
            font-size:15px;
        }
                   
        .dataCol {
          padding-left:0px !important;
        }
                   
        .contact-detail {
            font-size:12px;
            margin-bottom:3px;
        }
                   
        .tbFooter {
         text-align:right;
        }
                   
        .requiredBlock {
            width:5px !important;
        }

        .checkbox-td {
            text-align: center;
        }

        .summary-table th {
            text-align: center;
        }

        .summary-table td.dataCell {
            border: 1px solid #e0e3e5 !important;
        }

        .statusIcon {
            margin-left: 2px;
        }
        
		.col1 {
			padding-bottom:5px;
			width:40%;
			vertical-align: text-top;
			font-weight:bold
		}
		
		.col1_regular {
			padding-bottom:5px;
			width:25%;
			vertical-align: text-top;
			font-weight:bold
		}       
			   
		.col2 {width:60%; padding-left:50px;vertical-align: text-top;}
		.col2_regular {width:25%; padding-left:50px;vertical-align: text-top;}
		.col2_4 {width:10%;padding-left:5px;vertical-align: text-top;}
		.col3 {width:50%}
		
		.display-none {
			display: none;
		}
		
		 input + label {
			font-weight:normal;
        }

.aplabel {
        font-weight: bold;
        color: #000;
        margin-top: 5px;
        margin-bottom: 5px;
        border: 0px solid #fff !important;
        }

/***************************************************************/

/****************************** General Portal Pages CSS **************************/

.ui-dialog-titlebar {
    background: #337ab7;
} 
       
body {
    font-family:Arial, sans-serif; 
    background-image: url("/identity/s/OneIdResources/images/bgDiag.png");
    background-repeat: repeat;
}
       
div.container {
    background-color:white;
    position:relative;
}
      
.recentcasespanel {
    min-height:354px;
    overflow-x: auto;
}

.panel-halfsize {
    color: #ffffff;
    background-color: #206ba4;
}

.blueborder {
    border-color: #428bca;
    min-height:147px;
}

/*tables*/
table.list {
    width:100%;
}

tbody {
    width:100%;
}

.detailList {
    width:100%;
}

#red {
    background-color:red;
    padding:30px;
    text-align: center;
    color: red;
}

.green {
    background-color:green;
    padding:30px;
    text-align: center;
    color: green;
}
       
th.headerRow {
    background-color: rgb(234, 234, 234);
    color:#428bca;
    font-size:12px;
    padding: 3px;
    border-right-style: inset;
}
       
.collapsing {
    display:none;
}
       
.header-holder {
    background-color:white;
    width: 100%;
    height: 36px;
    padding-top:6px;
    color: #337ab7;
}
       
.header-holder a {
    color: #337ab7;
    text-decoration : none;
}
       
.header-title {
    font-size:18px;
    color: #337ab7;
    margin-left:25px;
}
      
.header-link {
    float: right;
    font-size:12px;
    margin-right: 20px;
    padding-top:2px;
}

.header-link-user {
    float: right;
    font-size:14px;
    margin-right: 20px;
    padding-top:2px;
}
       
.img-arrow {
    vertical-align:text-bottom;
}
       
span.prevOff, span.nextOff {
    color:#c0c0c0;
}

/***************************************************************/

/****************************** Portal Pages CSS **************************/
h4 {/* 'tis for breadcrumbs */
    color: rgb(32, 107, 164);
    font-size:14px;
}
      
.center {
    text-align:center;
}
       
.blueback {
    background-color:#337AB7;
    color:white;
    padding: 4px;
}
       
.nav1 {
    list-style:none;
    padding-left: 0;
}

.nav2 {
    list-style:none;
    padding-left: 0;
    background-color: #EAEAEA;
    padding-right: 1px;
}
   
.mandatory {
    border-left-color: rgb(217, 83, 79);
    border-left-width: 5px;
}
      
.notification-style {
    border-bottom-style: inset;
    padding-bottom: 5px;
    padding-top: 5px;
    border-bottom-color: rgb(221, 221, 221);
    border-bottom-width: 1px;
}
      
.greenbadge {
    background-color:green;
}
      
.redbadge {
    background-color:red;
}
      
.mybutton {
    padding: 4px;
    border-radius: 25px;
}
      
.sml {
    width:125px;
}
      
.brandtext {
    font-size: 14px;
    color: rgb(48, 115, 172);
    font-family: Arial, Helvetica, sans-serif;
}
      
.icon-bar {
    background-color:#428bca;
}
       
#one.two.three.four{
    color:red;
}

label, .labelCol,.lbl {
    color :#4a4a56;
    font-weight: 600;
}

.btn_iata_primary {
    border: none;
    color: white;
    background-color: rgb(66, 139, 202);
    margin:5px;
}
      
.btn_iata_success {
    border: none;
    color: white;
    background-color: #5cb85c;
    margin:5px;
}
      
.btn_iata_cancel {
    border: none;
    color: white;
    background-color: #d9534f;
    margin:5px;
}
      
.sidenav {
    width: 100%;
}
      
.lbl_services {
    color: grey;
    font-size: 11px;
    padding-left: 50px;
}
       
.navbar-collapse {
    float: left;
    width: 100%;
    clear: both;
}
       
.navbar-right {
    color: #000;
}
       
#searchbox {
    top: 102px;
    padding-right:0px;
    height:10px;
}

/***************************************************************/

/****************************** Navigation Bar CSS **************************/

@media screen and (max-width: 768px) {
      
    .bPageBlock {
        overflow-x: auto;
    }
       
    .navbar-header {
        margin-bottom: 120px;
    }
       
    .navbar-form {
        padding: 0px 35px;
        margin-right:0px
    }

    #searchbox {
        display: none;
    }

    #navbarHeader {
        background-color: #00305b;
        margin-top: 50px;
        margin-bottom: 70px;
    }

    #navbar {
        background-color: white;
    }

    #navbarLogo {
        margin-top: -50px;
    }

    select[id$="LanguageLocaleKeySelect"] {
        width: 200px !important;
    }
}

@media (min-width: 768px) and (max-width: 992px) {
    #searchbox {
        display:none;
    }

    .navbar-collapse.collapse {
        display: none !important;
    }
    
    .navbar-collapse.collapse.in {
        display: block !important;
    }
    
    .navbar-header .collapse, .navbar-toggle {
        display:block !important;
    }
    
    .navbar-header {
        float:none;
        margin-bottom: 120px;
    }

    .navbar-nav {
        float: none;
        margin: 7.5px -15px;
    }

    .navbar-nav > li {
        float: none;
    }

    .navbar-nav > li > a {
        padding-top: 10px;
        padding-bottom: 10px;
        line-height: 20px;
    }

    .container-fluid > .navbar-collapse, .container-fluid > .navbar-header, .container > .navbar-collapse, .container > .navbar-header {
        margin-right: -15px;
        margin-left: -15px;
    }

    .navbar-collapse.in {
        overflow-y: auto;
    }

    .collapse.in {
        display: block;
    }

    .navbar-collapse {
        overflow-x: visible;
        border-top: 1px solid transparent;
        box-shadow: inset 0 1px 0 rgba(255,255,255,.1);
    }

    .navbar-right {
        float: none !important;
    }

    .container {
        width: initial !important;
    }

    .navbar-nav > li > .dropdown-menu {
        margin-top: initial;
    }

    .navbar-nav .open .dropdown-menu {
        position: static;
        float: none;
        width: auto;
        margin-top: 0;
        background-color: transparent;
        border: 0;
        -webkit-box-shadow: none;
        box-shadow: none;
    }

    .navbar-nav .open .dropdown-menu > li > a {
        line-height: 20px;
    }
    
    .navbar-nav .open .dropdown-menu .dropdown-header, .navbar-nav .open .dropdown-menu > li > a {
        padding: 5px 15px 5px 25px;
    }

    #navbarHeader {
        background-color: #00305b;
        margin-top: 50px;
        margin-bottom: 70px;
    }

    #navbar {
        background-color: white;
    }

    #navbarLogo {
        margin-top: -50px;
    }

    select[id$="LanguageLocaleKeySelect"] {
        width: 200px !important;
    }
}

@media screen and (min-width: 992px) {
      
    .navbar-right {
        top: -40px;
        right: 2%;
        position: absolute
    }
       
    .navbar-nav-menu>li>a {
        color:white;
        font-size:100%;
        text-decoration: none;
        border-bottom: 3px solid transparent;
    }
       
    .navbar-nav-menu>li>a:hover {
        background-color: #00305b;
        border-bottom: 5px solid red;
        padding-bottom: 7px
    }
       
    .navbar-nav-menu>li>a:focus {
       background-color: #00305b;
       border-bottom: 5px solid red;
       padding-bottom: 7px
    }
       
    .navbar-nav-menu .open>a, .navbar-nav-menu .open>a:focus, .navbar-nav-menu .open>a:hover {
        background-color: #00305b;
        border-bottom: 5px solid red;
        padding-bottom: 7px
    }
       
    .navbar-right .open>a, .navbar-right .open>a:focus, .navbar-right .open>a:hover {
        background-color: #fff;
    }
       
    .navbar-right>li>a  {
        font-weight: bold;
    }
       
    .navbar-right>li>a:hover  {
        background-color: white !important;
    }
       
    .navbar-right>li>a:focus  {
        background-color: white !important;
    }
       
    .navbar-nav>.active-nav>a {
        background-color: #00305b;
        border-bottom: 5px solid red;
        padding-bottom: 7px;
    }
       
    .nav-header-issp {
        background-color: #00305b;
        width:100%;
        position:absolute;
        top:55px;
        height:47px;
    }
       
    .navbar-text {
        color:grey;
        margin-top:0px;
        margin-bottom:0px;
    }
       
    .navbar-nav-menu {
        margin-left:160px
    }
       
    .navbar-form {
        float:left;
        margin-top:13px;
        padding: 0px 15px;
    }
       
    .container-issp {
        padding-left: 0px;
        height:155px
    }
       
    .panel-primary{
        min-height:314px;
    }
}

/***************************************************************/

