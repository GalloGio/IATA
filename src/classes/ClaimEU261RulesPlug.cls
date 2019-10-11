/**
 * Created by mansourim on 26-Jan-18.
 */

global class ClaimEU261RulesPlug implements Process.Plugin{
    global Process.PluginResult invoke(Process.PluginRequest request) {
        
        String Delayed_Flight_Time = (String) request.inputParameters.get('Delayed_Flight_Time');
        String Extraordinary_Circumstances = (String) request.inputParameters.get('Extraordinary_Circumstances');
        Decimal Flight_Distance = (Decimal) request.inputParameters.get('Flight_Distance');
        String isDeparture_Airport_EU = (String) request.inputParameters.get('isDeparture_Airport_EU');
        String isConnecting_Airport_EU = (String) request.inputParameters.get('isConnecting_Airport_EU');
        String isArrival_Airport_EU = (String)request.inputParameters.get('isArrival_Airport_EU');
        String isCarrier_EU = (String)request.inputParameters.get('isCarrier_EU');
        String claimType = (String)request.inputParameters.get('claimType');
        String DelayFlightSection = (String)request.inputParameters.get('DelayFlightSection');
            
        System.debug('Delayed time is ' + Delayed_Flight_Time);
        System.debug('is was an Extraordinay circumstances?' + Extraordinary_Circumstances);
        System.debug('Flight Distance is ' + Flight_Distance);
        System.debug('is Departure Airport EU? ' + isDeparture_Airport_EU);
        System.debug('is Connecting Airport EU? ' + isConnecting_Airport_EU);
        System.debug('is Arrival Airport EU? ' + isArrival_Airport_EU);
        System.debug('is Carrier EU? ' + isCarrier_EU);
        System.debug('Delay Flight section is ' + DelayFlightSection);
        
        Map<String,Object> inputs = new Map<String,Object>();
        inputs.put('Delayed_Flight_Time', Delayed_Flight_Time);
        inputs.put('Extraordinary_Circumstances', Extraordinary_Circumstances);
        inputs.put('Flight_Distance', Flight_Distance);
        inputs.put('isDeparture_Airport_EU', isDeparture_Airport_EU);
        inputs.put('isConnecting_Airport_EU', isConnecting_Airport_EU);
        inputs.put('isArrival_Airport_EU', isArrival_Airport_EU);
        inputs.put('isCarrier_EU', isCarrier_EU);
        inputs.put('claimType', claimType);
        inputs.put('DelayFlightSection', DelayFlightSection);
        
        List<Object> FinalResult = ClaimEU261Helper.getFinalResult(inputs);
        String CompensationAmount = 'Different compensations available';
        String Description = 'Rules are not defined correctly, we have more than one possible compensation for this claim. Please contact your Administrator';
        If (FinalResult.size() == 1){
	        ClaimEU261__c Rules = (ClaimEU261__c)FinalResult.get(0);
	        CompensationAmount = (String)Rules.CompensationAmount__c;
    	    Description = (String)Rules.Description__c;
        }
        else if (FinalResult.size() == 0){
	        CompensationAmount = 'No compensation found';
    	    Description = 'No rules was defined for this type of Claim. Please contact your Administrator';
        }
        Map<String,Object> result = new Map<String,Object>();
        result.put('CompensationAmount',CompensationAmount);
        result.put('Description',Description);
        return new Process.PluginResult(result);
    }

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Claim Compensation';
        result.Tag = 'Claim EU261';
        result.inputParameters = new
                List<Process.PluginDescribeResult.InputParameter>{
                new Process.PluginDescribeResult.InputParameter('Delayed_Flight_Time',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Extraordinary_Circumstances',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Flight_Distance',Process.PluginDescribeResult.ParameterType.Decimal, true),
                new Process.PluginDescribeResult.InputParameter('isDeparture_Airport_EU',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('isConnecting_Airport_EU',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('isArrival_Airport_EU',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('isCarrier_EU',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('claimType',Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('DelayFlightSection',Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
                new Process.PluginDescribeResult.OutputParameter('CompensationAmount', Process.PluginDescribeResult.ParameterType.String),
                new Process.PluginDescribeResult.OutputParameter('Description', Process.PluginDescribeResult.ParameterType.String)
        };
        return result;
    }
    
}