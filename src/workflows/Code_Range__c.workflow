<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Code_Range_name_update</fullName>
        <field>New_Name__c</field>
        <formula>TEXT(Area_Code__c) + &apos;-&apos; + 
	Prefix__c + &apos;-&apos; + 
	 IATA_ISO_Country__r.ISO_Code__c  + &apos;-&apos; + 
		 if( ISBLANK(IATA_ISO_State__c), &apos;&apos;, IATA_ISO_State__r.ISO_Code__c   + &apos;-&apos;) +
			TEXT(ProgramCode__c) + &apos;-[&apos; +
			TEXT(Min_Range__c) + &apos;-&apos; +
			TEXT(Max_Range__c)+&apos;]&apos;</formula>
        <name>Code Range - name update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Name</fullName>
        <field>Name</field>
        <formula>TEXT(Area_Code__c) + &apos;-&apos; +
Prefix__c + &apos;-&apos; +
IATA_ISO_Country__r.ISO_Code__c + &apos;-&apos; +
if( ISBLANK(IATA_ISO_State__c), &apos;&apos;, IATA_ISO_State__r.ISO_Code__c + &apos;-&apos;) +
TEXT(ProgramCode__c) + &apos;-[&apos; +
TEXT(Min_Range__c) + &apos;-&apos; +
TEXT(Max_Range__c)+&apos;]&apos;</formula>
        <name>Update Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Name</fullName>
        <actions>
            <name>Code_Range_name_update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( isNew(), OR(
 ischanged(Area_Code__c),
				ischanged(Prefix__c ),
				ischanged(IATA_ISO_Country__c),
				ischanged(IATA_ISO_State__c),
				ischanged(ProgramCode__c),
				ischanged(Min_Range__c),
				ischanged(Max_Range__c)
))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
