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
    font-size: 8pt;
    top: 100px;
    left: 0px;
    height: 375px;
    margin-bottom: 0;
    margin-left: 0px;
    margin-right: 0;
    margin-top: -40px;
    padding-bottom: 0;
    padding-left: 0px;
    padding-right: 10px;
    padding-top: 3px;
    position: fixed;
    width: 6%;
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



