.columnTitleCenter{
        text-align:center;
  }
  
 .whiterow {
        background-color: #fff;
        color: #1797c0;
        border-bottom:dashed 0px #000
        }
        
        .bluerow {
        background-color: #ddeffa;
        border-bottom:dashed 0px #000
        }
        
        .countryReqsGrid {
        border-collapse: collapse; 
        }
        
        .apcontainer div {
        border-top: 0px !important;
        border: 1px solid #ececec;
        }
        
        .apcontainer .pbSubsection {
        border: 0px !important;
        }
        
        .col1 {
        width: 55%;
        }  
        
        .col2 {
        font-weight:bold;
        width: 10%;
        }   
        
        .col3 {
        width: 35%;
        }   
        
        .countryReqsGrid td {
        padding-top:7px;
        }
        
        .countryReqsGrid {
        width: 100%;
        }
        
        body .bPageBlock .pbBody .pbSubheader{
        background-color:  #1797c0 !important;
        color: #fff !important;
        }
        
.pbHeader {
        border: 0px solid #ececec !important;
        border-bottom: 0px !important;
        background-color: #fff !important;
        margin-left: 100px !important;
        margin-right: 100px !important;
        }   

 .pbTitle h2 {
        color: #1797c0 !important;
        }
         
        .brandSecondaryBrd {
        border: none !important;
        }
        
        .secondaryPalette.bPageBlock {
        background-color: #fff !important;
        }
        
        .bPageBlock .detailList tr td, .bPageBlock .detailList tr th, .hoverDetail .bPageBlock .detailList tr td, .hoverDetail .bPageBlock .detailList tr th {
        border: none !important;
        }
          
  
.apcontainer, .pbBottomButtons  {
        margin-left: 100px !important;
        margin-right: 100px !important;
        }

        
  .aplabel {
        font-weight: bold;
        color: #000;
        margin-top: 5px;
        margin-bottom: 5px;
        border: 0px solid #fff !important;
        }
        
        /* Styles for PDF rendered forms */
.aptable {border: 1px solid black; border-spacing: 0;padding; 5px; border-collapse: collapse;}
.aptable td {border: 1px solid black;padding: 5px; border-collapse: collapse;}
.noborders {border: 0px solid black; border-spacing: 0;padding; 5px; border-collapse: collapse;}
.noborders  td {border: 0px solid black; border-spacing: 0;padding; 5px; border-collapse: collapse;}
.bluebg {background-color: #035; color: white;}
.bluebg2 {background-color: #0074B7; color: black;}
.bluebg3 {background-color: #008394; color: black;}
.yellowbg {background-color: #FF9; color: #035;}
.whitetext {color: white;font-weight: bold;text-align: center;font-size: 14pt;}
.bluetext {color: #035;font-weight: bold;text-align: center;font-size: 14pt;}
.whitetext2 {color: white;font-style: italic;}
.bluefont {color: #035;}
.bluefontbig {color: #035;font-size: 14pt;}
.greenfont {color: #ABCC3A;font-weight: bold;}
.label {color: #035;}
        
h2 {text-align: center;}

@page {
margin-top: 3.5cm;
margin-bottom: 2cm;
margin-left: 0.5cm;
margin-right: 0.5cm;
@top-center {content: element(header);}
@bottom-left {content: element(footer);font-size: 80%;}
}

div.header {padding: 10px;position: running(header);}
div.footer {display: block;padding: 5px;position: running(footer);}
.pagenumber:before {content: counter(page);}
.pagecount:before {content: counter(pages);}

/* Styles for AP process forms */

.whitebg {background-color: #fff;}
.bluebg {background-color: #004373;}
.green {font-size: 14pt; color: green;}
.red {font-size: 14pt; color: #C90435;}
.header {background-color: #fff !important; border: none;}
.headerdiv { border-top: 1px dotted #000 !important;}
td.hactive {font-size: 14pt; color: green; border-bottom: 5px solid green !important; padding-left: 20px;margin-left: 20px;background-color: #fff !important;}
td.hactivered {font-size: 14pt; color: #C90435; border-bottom: 5px solid #C90435 !important; padding-left: 20px;margin-left: 20px;background-color: #fff !important;}
td.hinactive {font-size: 14pt; color: #000; border-bottom: 0px !important; padding-left: 20px;margin-left: 20px;background-color: #fff !important;}

.pageNav {
    font-size: 9pt;
    top: 100px;
    left: 0px;
    height: 420px;
    margin-bottom: 0;
    margin-left: 0px;
    margin-right: 0;
    margin-top: -40px;
    padding-bottom: 0;
    padding-left: 0px;
    padding-right: 10px;
    padding-top: 3px;
    position: fixed;
    width: 7%;
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
    text-decoration: none !important;
}
        
p.LOB {

    color: #fff !important;
	font-size: 120%;
	font-weight: bold;
	text-align: center;
}

        
.close {
        float: right;
        font-size: 21px;
        font-weight: bold;
        line-height: 1;
        color: #000000;
        text-shadow: 0 1px 0 #ffffff;
        opacity: 0.2;
        filter: alpha(opacity=20);
        }
        
        .close:hover, .close:focus {
        color: #000000;
        text-decoration: none;
        cursor: pointer;
        opacity: 0.5;
        filter: alpha(opacity=50);
        }
        
        button.close {
        padding: 0;
        cursor: pointer;
        background: transparent;
        border: 0;
        -webkit-appearance: none;
        }
        
        .modal-open {
        overflow: hidden;
        }
        
        body.modal-open, .modal-open .navbar-fixed-top, .modal-open .navbar-fixed-bottom {
        margin-right: 15px;
        }
        
        .modal {
        position: fixed;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        z-index: 1040;
        display: none;
        overflow: auto;
        overflow-y: scroll;
        }
        
.modal.fade .modal-dialog {
        -webkit-transform: translate(0, -25%);
        -ms-transform: translate(0, -25%);
        transform: translate(0, -25%);
        -webkit-transition: -webkit-transform 0.3s ease-out;
        -moz-transition: -moz-transform 0.3s ease-out;
        -o-transition: -o-transform 0.3s ease-out;
        transition: transform 0.3s ease-out;
        }
        
        .modal.in .modal-dialog {
        -webkit-transform: translate(0, 0);
        -ms-transform: translate(0, 0);
        transform: translate(0, 0);
        }
        
        .modal-dialog {
        margin-top:50px;
        z-index: 1050;
        width: auto;
        padding: 10px;
        margin-right: auto;
        margin-left: auto;
        }
        
        .modal-content {
        position: relative;
        background-color: #ffffff;
        border: 1px solid #999999;
        border: 1px solid rgba(0, 0, 0, 0.2);
        border-radius: 6px;
        outline: none;
        -webkit-box-shadow: 0 3px 9px rgba(0, 0, 0, 0.5);
        box-shadow: 0 3px 9px rgba(0, 0, 0, 0.5);
        background-clip: padding-box;
        }
        
        .modal-backdrop {
        position: fixed;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        z-index: 1030;
        background-color: #000000;
        }
        
        .modal-backdrop.fade {
        opacity: 0;
        filter: alpha(opacity=0);
        }
        
        .modal-backdrop.in {
        opacity: 0.5;
        filter: alpha(opacity=50);
        }
        
        .modal-header {
        min-height: 16.428571429px;
        padding: 15px;
        border-bottom: 1px solid #e5e5e5;
        }
        
        .modal-header .close {
        margin-top: -2px;
        }
        
        .modal-title {
        margin: 0;
        line-height: 1.428571429;
        }
        
        .modal-body {
        position: relative;
        padding: 20px;
        }
        
        .modal-footer {
        padding: 19px 20px 20px;
        margin-top: 15px;
        text-align: right;
        border-top: 1px solid #e5e5e5;
        }
        
        .modal-footer:before, .modal-footer:after {
        display: table;
        content: " ";
        }
        
        .modal-footer:after {
        clear: both;
        }
        
        .modal-footer:before,
        .modal-footer:after {
        display: table;
        content: " ";
        }
        
        .modal-footer:after {
        clear: both;
        }
        
        
        @media screen and (min-width: 768px) {
        .modal-dialog {
        right: auto;
        left: 50%;
        width: 600px;
        padding-top: 30px;
        padding-bottom: 30px;
        }
        
        .modal-content {
        -webkit-box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.5);
        }
     }