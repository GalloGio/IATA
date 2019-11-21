@page{
	size: 210mm 297mm;
	margin: 5cm 1cm 2cm 1cm;

    @top-left{
    	content: element(top_left);
    	font-size: 80%;
    }

    @top-center{
    	content: element(top_center);
    }

    @top-right{
    	content: element(top_right);
    	font-size: 80%;
    }
    
    @bottom-left{
        /*content: "Date: {!Day(Today())} - {!Month(Today())} - {!Year(Today())}";
        font-size: 80%;*/
    }

    @bottom-center{
        content : "Tel: (Toll free) +1 800 716 6326 / Tel: +1 (514) 390 6726 / +41 (22) 770 2751 / E-mail: ymq-cds@iata.org";
        font-size: 80%;
    }

    @bottom-right{
        content: counter(page) "/" counter(pages);
        font-size: 80%;
    }
}

body{
	font-family: "Garamond";
	font-size: 12px; 
}

.page_break{
	page-break-after: always; 
}


#top_left {                
    position: running(top_left);
    vertical-align: bottom;
}  


#top_center {                
    position: running(top_center);
    text-align: center;
}     

#top_right {                
    position: running(top_right);
    vertical-align: bottom;
} 

#bottom_center
	position:running(bottom_center);
}

.pagenumber {  
   content: element(bottom_right);             
} 

/*
 border: 1px solid black;
*/
#items { clear: both; width: 100%; margin: 30px 0 0 0; }

#total, #subtotal {
    font-weight: bold;
}

table{        
    -fs-table-paginate: paginate;
}