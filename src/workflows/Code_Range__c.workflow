<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Code_Range_Range_Update</fullName>
        <description>Updates Range (name field) with the following: &quot;Area Code - Prefix - Country ISO Code - State ISO Code - Program Code - [Min Range - Max Range]&quot;</description>
        <field>Name</field>
        <formula>TEXT(Area_Code__c) + &apos;-&apos; +
Prefix__c + &apos;-&apos; +
IATA_ISO_Country__r.ISO_Code__c + &apos;-&apos; +
if( ISBLANK(IATA_ISO_State__c), &apos;&apos;, IATA_ISO_State__r.ISO_Code__c + &apos;-&apos;) +
TEXT(ProgramCode__c) + &apos;-[&apos; +
TEXT(Min_Range__c) + &apos;-&apos; +
TEXT(Max_Range__c)+&apos;]&apos;</formula>
        <name>Code Range - Range Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Code_Range_Unique_Key_Update</fullName>
        <description>Updates the field Unique_Key__c by concatenating with the following: &quot;Area Code - Prefix - Country ISO Code - State ISO Code - Program Code - [Min Range - Max Range]&quot;</description>
        <field>Unique_Key__c</field>
        <formula>TEXT(Area_Code__c) + &apos;-&apos; + 
	Prefix__c + &apos;-&apos; + 
	 IATA_ISO_Country__r.ISO_Code__c  + &apos;-&apos; + 
		 if( ISBLANK(IATA_ISO_State__c), &apos;&apos;, IATA_ISO_State__r.ISO_Code__c   + &apos;-&apos;) +
			TEXT(ProgramCode__c) + &apos;-[&apos; +
			TEXT(Min_Range__c) + &apos;-&apos; +
			TEXT(Max_Range__c)+&apos;]&apos;</formula>
        <name>Code Range - Unique Key Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Code Range Identifiers</fullName>
        <actions>
            <name>Code_Range_Range_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Code_Range_Unique_Key_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Unique_Key__c and Range (Name) fields on Code Range object</description>
        <formula>OR( isNew(), OR(  ischanged(Area_Code__c), 				ischanged(Prefix__c ), 				ischanged(IATA_ISO_Country__c), 				ischanged(IATA_ISO_State__c), 				ischanged(ProgramCode__c), 				ischanged(Min_Range__c), 				ischanged(Max_Range__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
