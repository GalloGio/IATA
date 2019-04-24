public class ISSP_AMC_Metropolitan_Area {
	/*
	public integer cont {get;set;}
	public static integer count {get;set;}
	*/
	public Participation_Online_Application__c controllerParticipation {
		get {
			return controllerParticipation;
		}
		set {
			controllerParticipation = value;
			//startPage();
		}
	}

	/*
	public void startPage(){

		if(!string.isempty(controllerParticipation.Name_of_Airport_Authority_Airport_4__c) || !string.isEmpty(controllerParticipation.Email_of_Airport_Authority_Airport_4__c)){
			count =4;
			cont=4;
		}
		else if(!string.isempty(controllerParticipation.Name_of_Airport_Authority_Airport_3__c) || !string.isEmpty(controllerParticipation.Email_of_Airport_Authority_Airport_3__c)){
			cont=3;
			count=3;
		}
		else if(!string.isempty(controllerParticipation.Name_of_Airport_Authority_Airport_2__c) || !string.isEmpty(controllerParticipation.Email_of_Airport_Authority_Airport_2__c)){
			cont=2;
			count=2;
		}
		else if(!string.isempty(controllerParticipation.Name_of_Airport_Authority_Airport_1__c) || !string.isEmpty(controllerParticipation.Email_of_Airport_Authority_Airport_1__c)){
			cont=1;
			count=1;
		}
	}


	public void showInputText(){
		count++;
		cont++;
	}


	public ISSP_AMC_Metropolitan_Area() {
		cont=0;
		count=0;
	}*/
}