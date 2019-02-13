<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Automatic type of customer - Cargo</fullName>
        <actions>
            <name>Type_of_Customer_Cargo_agent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Type_of_customer_cargo_detail_export</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>IATA Cargo Agent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Complaint (IDFS ISS),Cases - Global</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Automatic type of customer - Travel</fullName>
        <actions>
            <name>Type_of_Customer_Travel_agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>IATA Passenger Sales Agent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Americas,Cases - Asia &amp; Pacific,Cases - Europe,Cases - Africa &amp; Middle East,Cases - China &amp; North Asia,Internal Cases (IDFS ISS),SAAM,SIDRA,Complaint (IDFS ISS),Cases - Global</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BJS Complaint assignment to Complaint team</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_Update_owner_BJS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND (2 OR 3) AND 4) AND (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - China &amp; North Asia,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - Global</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <description>the query is reopened and assigned to BJS complaint team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FDS Delete New Interaction Info</fullName>
        <actions>
            <name>Clear_interaction_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>New_interaction_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear New interaction field when Query is closed. It is necessary when query  had another Record Type with New Interaction Info</description>
        <formula>AND(OR ( 
RecordType.DeveloperName = &quot;Cases_Global&quot;, 
RecordType.DeveloperName = &quot;OSCAR_Communication&quot;, RecordType.DeveloperName = &quot;CasesAmericas&quot;, RecordType.DeveloperName = &quot;CasesEurope&quot;, RecordType.DeveloperName = &quot;InternalCasesEuropeSCE&quot; , RecordType.DeveloperName = &quot;CasesMENA&quot; , RecordType.DeveloperName = &quot;ExternalCasesIDFSglobal&quot;, RecordType.DeveloperName = &quot;Cases_China_North_Asia&quot;, RecordType.DeveloperName = &quot;ProcessEuropeSCE&quot;, RecordType.DeveloperName = &quot;sMAP_sales_Monitoring_Alert_Process&quot;, RecordType.DeveloperName = &quot;ComplaintIDFS&quot;, RecordType.DeveloperName = &quot;IDFS_Airline_Participation_Process&quot;, RecordType.DeveloperName = &quot;CS_Process_IDFS_ISS&quot;, RecordType.DeveloperName =&quot;IATA_Financial_Review&quot;, RecordType.DeveloperName =&quot;ID_Card_Application&quot;, RecordType.DeveloperName =&apos;Airline_Coding_Application&apos;,RecordType.DeveloperName =&apos;DPC_Service_Request&apos;) , OwnerId = LastModifiedById, contains(TEXT(Status),&quot;Closed&quot;), not(ispickval(New_interaction__c, &quot;&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>GDC MAD complaint queue assignment</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ComplaintUpdateowner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND (3 OR 6)) AND (4 AND 5)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Europe,ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Internal Cases (IDFS ISS),Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East,Americas,Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>the query is reopened and assigned to GDC MAD complaint queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS First time resolution</fullName>
        <actions>
            <name>IDFS_First_time_resolution</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 4) AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>,Cases - Europe,ACCA Customer Service Request (External),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Manual order / Returned document form,Order of AWB / allocation (CASS),Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reopening_reason__c</field>
            <operation>equals</operation>
            <value>same query</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global</value>
        </criteriaItems>
        <description>Fills in the first time resolution of the case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS final resolution date</fullName>
        <actions>
            <name>SCE_first_closure</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 6) AND 2 AND (3  OR (4 AND 5))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,ACCA Customer Service Request (External),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Manual order / Returned document form,Order of AWB / allocation (CASS),Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.First_closure_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reopened_case__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reopening_reason__c</field>
            <operation>equals</operation>
            <value>same query,complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>,Cases - Global</value>
        </criteriaItems>
        <description>fills in the final resolution date of the case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RecType Complaint %28IDFS ISS%29</fullName>
        <actions>
            <name>RecType_Complaint_IDFS_ISS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notEqual</operation>
            <value>TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notEqual</operation>
            <value>MITA Interline Agreements,X3 numeric and or 3 digit airline code,Airline Designator Code,Baggage Tag Issuer,General Queries,Location Identifier</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <description>For COMPLAINTS =&gt; update rec type to Complaint (IDFS ISS) except for Topic=TIESS OR Subtopic= &quot;Interline Agreements (MITA)&quot; OR Subtopic= any &quot;IATA Codes (not applicable to Agents)&quot; subtopics except &quot;MSO - Member Sales Office&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Customer Recovery assignment to OCIT</fullName>
        <actions>
            <name>ComplaintUpdateowner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESCCaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 and 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,Cases - Europe,ACCA Customer Service Request (External),Order of AWB / allocation (CASS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>the query is reopened (in progress) and assigned to OCIT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIN Complaint assignment to Complaint team</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_Update_owner_SIN</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND (2 OR 3) AND 4) AND (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Global,ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Asia &amp; Pacific,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <description>the query is reopened and assigned to SIN complaint team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
