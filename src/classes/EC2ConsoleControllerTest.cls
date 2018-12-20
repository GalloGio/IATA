@isTest
private class EC2ConsoleControllerTest {
	
	@isTest
	static void t2() { 
        try{
        EC2ConsoleController ecc = new EC2ConsoleController();
        ecc.getdescribeImages();
        }catch(Exception ex){
        }   
    }

    @isTest
	static void t3() { 
        try{
            EC2ConsoleController ecc = new EC2ConsoleController();
            ecc.refreshImages();    
        }catch(Exception ex){
        }
    }

    @isTest
	static void t4() {
        try{ 
            EC2ConsoleController ecc = new EC2ConsoleController();
            ecc.RebootInstances();
        }catch(Exception ex){
        }   
    }

    @isTest
	static void t5() { 
        try{
            EC2ConsoleController ecc = new EC2ConsoleController();
            ecc.getOwners();
            ecc.TerminateInstances();
        }catch(Exception ex){
        }
            
    }
    
    @isTest
	static void t6() { 
        try{
            EC2ConsoleController ecc = new EC2ConsoleController();
            ecc.RunInstances();
        }catch(Exception ex){
        }   
    }
	
}