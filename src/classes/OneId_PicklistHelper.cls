/*
	Disclaimer:

	Since salesforce has no native way to find dependent picklist values on the describe 
	we can leverage the "validFor" obtained by serializing the describe result for a picklist

	validFor tokens are converted from base64 representations (e.g. gAAA) to binary (100000000000000000000)
	each character corresponds to 6 bits, determined by normal base64 encoding rules.
	The binary bits correspond to controlling values that are active - e.g. in the example above, 
	this dependent option is available for the first controlling field only.

	The class below does that for the Sector and Category fields on the Account. You can find a 
	more complete explanation and an example of how to do this dynamically on this gist:
	https://gist.github.com/boxfoot/4166342
*/
public class OneId_PicklistHelper {

    private class PicklistEntryDescribe{
        String active;
        String defaultValue;
        String label;
        String value;
        String validFor;
    }

    private static final String base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    // Convert decimal to binary representation (alas, Apex has no native method :-(
    //    eg. 4 => '100', 19 => '10011', etc.
    // Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
    // These, in reverse order, are the binary.
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    // Convert a base64 token into a binary/bits representation
    // e.g. 'gAAA' => '100000000000000000000'
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }

    private static Map<String,List<Schema.PicklistEntry>> sectorValues{
        get{
            if(sectorValues == null){
                sectorValues = new Map<String,List<Schema.PicklistEntry>>();

                List<Schema.PicklistEntry> sectorEntries = Account.Sector__c.getDescribe().getPicklistValues();
                List<Schema.PicklistEntry> categoryEntries = Account.Category__c.getDescribe().getPicklistValues();

                for(Schema.PicklistEntry p : sectorEntries) sectorValues.put(p.getValue(),new List<Schema.PicklistEntry>());

                for(Schema.PicklistEntry p : categoryEntries){
                    PicklistEntryDescribe picklistValue = (PicklistEntryDescribe)JSON.deserialize(JSON.serialize(p), PicklistEntryDescribe.class);
                    
                    if (picklistValue.validFor==null || picklistValue.validFor=='') continue;

                    String validForBits = base64ToBits(picklistValue.validFor);
                    for (Integer i = 0; i < validForBits.length(); i++) {
                        // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
                        if (validForBits.mid(i, 1) == '1') sectorValues.get(sectorEntries[i].getValue()).add(p);
                    }
                }
            }
            return sectorValues;
        }
        set;
    }

    public static List<Schema.PicklistEntry> getDependentValues(String value){
        return sectorValues.get(value);
    }
}