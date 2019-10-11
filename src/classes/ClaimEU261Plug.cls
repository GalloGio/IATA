/**
 * Created by mansourim on 26-Jan-18.
 */

global class ClaimEU261Plug implements Process.Plugin{
    global Process.PluginResult invoke(Process.PluginRequest request) {
        String Departure_Airport = (String) request.inputParameters.get('Departure_Airport');
        String Arrival_Airport = (String) request.inputParameters.get('Arrival_Airport');
        System.debug('Departure airport is ' + Departure_Airport);
        System.debug('Arrival airport is ' + Arrival_Airport);
        List<Object> FlightInformation = ClaimEU261Helper.getFlightInformation(Departure_Airport,Arrival_Airport);
        Decimal FlightDistance = (Decimal)FlightInformation.get(0);
        String DepartAirportIsEU = (String)FlightInformation.get(1);
        String ArrivalAirportIsEU = (String)FlightInformation.get(2);

        Map<String,Object> result = new Map<String,Object>();
        result.put('FlightDistance',FlightDistance);
        result.put('DepartAirportIsEU',DepartAirportIsEU);
        result.put('ArrivalAirportIsEU',ArrivalAirportIsEU);
        
        return new Process.PluginResult(result);
    }

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Flight Information';
        result.Tag = 'Claim EU261';
        result.inputParameters = new
                List<Process.PluginDescribeResult.InputParameter>{
                new Process.PluginDescribeResult.InputParameter('Departure_Airport',
                        Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('Arrival_Airport',
                        Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
                new Process.PluginDescribeResult.OutputParameter('FlightDistance', Process.PluginDescribeResult.ParameterType.Decimal),
                new Process.PluginDescribeResult.OutputParameter('DepartAirportIsEU', Process.PluginDescribeResult.ParameterType.STRING),
                new Process.PluginDescribeResult.OutputParameter('ArrivalAirportIsEU', Process.PluginDescribeResult.ParameterType.STRING)
        };
        return result;
    }
    
}