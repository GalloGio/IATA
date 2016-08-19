<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FDS_CodingAOC</fullName>
        <ccEmails>alvarengam@iata.org</ccEmails>
        <description>FDS Coding - AOC Expiry alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>farrella@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pacificoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Airline_Coding/AUTO_Expiry_of_AOC_approaching</template>
    </alerts>
    <alerts>
        <fullName>FDS_CodingAOC2</fullName>
        <ccEmails>alvarengam@iata.org</ccEmails>
        <description>FDS Coding - AOC Expiry alert 2</description>
        <protected>false</protected>
        <recipients>
            <recipient>farrella@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jeffrey@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pacificoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Airline_Coding/AUTO_Expiry_of_AOC_approaching2</template>
    </alerts>
    <alerts>
        <fullName>Irregularity_Thresold_Met</fullName>
        <description>Irregularity Thresold Met</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SURVEY_a1Q20000000UD7AEAW</template>
    </alerts>
    <fieldUpdates>
        <fullName>AIMS_Accounts_RT_Assignment</fullName>
        <description>Assign &quot;Agenciy&quot; as Record Type when an AIMS Account is created</description>
        <field>RecordTypeId</field>
        <lookupValue>IATA_Agency</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>AIMS Accounts RT Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AccountIATAAirlineSetName</fullName>
        <description>Set the name of an IATA Airline Account, first using Trade Name, and in second place Name_on_AOC__c</description>
        <field>Name</field>
        <formula>IF(
  OR( ISNULL( TradeName__c ), TradeName__c == &apos;&apos;),
  IF (
    OR( ISNULL( Name_on_AOC__c ), Name_on_AOC__c == &apos;&apos;),
    Name,
    Name_on_AOC__c
  ),
  TradeName__c
)</formula>
        <name>AccountIATAAirlineSetName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Accountsiteupdate</fullName>
        <field>Site</field>
        <formula>if(
  ISPICKVAL(Industry,&apos;Travel Agent&apos;),
  Site,
  if( ISBLANK(IATACode__c), 
    if ( ISBLANK(Airline_Prefix__c),
      Airline_designator__c + &apos; &apos; + IATA_ISO_Country__r.ISO_Code__c,
      Airline_designator__c + &apos; &apos; + Airline_Prefix__c + &apos; &apos; + IATA_ISO_Country__r.ISO_Code__c
    ),
    Airline_designator__c + &apos; &apos; + IATACode__c + &apos; &apos; + IATA_ISO_Country__r.ISO_Code__c
  )
)</formula>
        <name>Account site update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AutoDDSOptIn</fullName>
        <field>DDS_Status__c</field>
        <literalValue>Opt-In</literalValue>
        <name>AutoDDSOptIn</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Data_quality_comment_history</fullName>
        <description>Historize the data quality feedback comment</description>
        <field>Data_quality_history__c</field>
        <formula>Data_quality_history__c + BR() + TEXT(TODAY()) + &apos;: &apos; + Comment_data_quality_feedback__c</formula>
        <name>Data quality comment history</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>InvoiceWorks_Account_True</fullName>
        <description>Updates the InvoiceWorks Account field with True</description>
        <field>InvoiceWorks_Account__c</field>
        <literalValue>1</literalValue>
        <name>InvoiceWorks Account = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Member_Airline_False</fullName>
        <description>Un-checks &apos;Member Airline Field&apos;</description>
        <field>IATA_Member__c</field>
        <literalValue>0</literalValue>
        <name>Member Airline: False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Parent_Branch_member_airlines</fullName>
        <description>This workflow makes a subsidiary have the same value in the field &apos;IATA member airline&apos; as its Parent company</description>
        <field>IATA_Member__c</field>
        <literalValue>1</literalValue>
        <name>Member Airline: True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rename_Branch</fullName>
        <field>Name</field>
        <formula>if(NOT(ISBLANK( Parent.TradeName__c)),Parent.TradeName__c,Parent.Name)</formula>
        <name>Rename Branch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Assign_account_recordtype</fullName>
        <field>RecordTypeId</field>
        <lookupValue>IATA_SIS_Account</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SIS - Assign account recordtype</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Account_Site</fullName>
        <field>Site</field>
        <formula>Airline_designator__c +  Member_Code_Numeric__c</formula>
        <name>SIS - Update Account Site</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Record_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>smitha@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>SIS Update Record Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetDDSToNoReply</fullName>
        <field>DDS_Status__c</field>
        <literalValue>No Reply</literalValue>
        <name>SetDDSToNoReply</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_ID_Card_Discount</fullName>
        <field>ID_Card_Key_Account_Discount__c</field>
        <formula>0</formula>
        <name>Set ID Card Discount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Site_index_field_updt</fullName>
        <field>Site_index__c</field>
        <formula>IF( OR( ISPICKVAL(Industry,&apos;Travel Agent&apos;), ISPICKVAL(Industry,&apos;Cargo Agent&apos;)),
Site, 
IF( ISBLANK(IATACode__c),
Airline_designator__c + &apos; &apos;+IATA_ISO_Country__r.ISO_Code__c,
Airline_designator__c + &apos; &apos; + IATACode__c + &apos; &apos; + IATA_ISO_Country__r.ISO_Code__c))</formula>
        <name>Site index field updt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIndustry</fullName>
        <description>It will update industry as &apos;Travel Agency&apos;</description>
        <field>Industry</field>
        <literalValue>Travel Agency</literalValue>
        <name>Update Industry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIndustryCargoAgent</fullName>
        <field>Industry</field>
        <literalValue>Cargo Agent</literalValue>
        <name>Update Industry - Cargo Agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateIndustrywithTravelAgency</fullName>
        <field>Industry</field>
        <literalValue>Travel Agent</literalValue>
        <name>Update Industry with Travel Agency</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DDS_Date</fullName>
        <field>DDS_Last_Update_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update DDS Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Modified_By_Source</fullName>
        <description>Updates this field with the date/time this record was last updated with master data from the source.</description>
        <field>Last_Modified_by_Source__c</field>
        <formula>NOW()</formula>
        <name>Update Last Modified By Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_acct_name</fullName>
        <field>Name</field>
        <formula>if(NOT(ISBLANK( Parent.TradeName__c)),Parent.TradeName__c,Parent.Name)</formula>
        <name>Update acct name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ACLIAccountSetName</fullName>
        <actions>
            <name>AccountIATAAirlineSetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the name of an ACLI account (RT = Airline Headquarters ) using its Trade Name or AOC Name</description>
        <formula>AND (   RecordType.DeveloperName = &apos;IATA_Airline&apos;,   OR( ISNEW(), ISCHANGED( TradeName__c ), ISCHANGED( Name_on_AOC__c ) )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIMS Accounts RT Assignment Rule</fullName>
        <actions>
            <name>AIMS_Accounts_RT_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Is_AIMS_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Standard Account,Standard Account</value>
        </criteriaItems>
        <description>AIMS Accounts record type Assignment rule</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AIMS%3A Update Industry - cargo agents</fullName>
        <actions>
            <name>UpdateIndustryCargoAgent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Is_AIMS_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>IATA Cargo Agent,Import Agent,CASS Associate,Couriers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Is_AIMS_Account__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Updates the field Industry in the cargo agent accounts that are uploaded from AIMS</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIMS%3A Update Industry - travel agents</fullName>
        <actions>
            <name>UpdateIndustrywithTravelAgency</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Is_AIMS_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>GSA General Sales Agent,IATA Passenger Sales Agent,SSI,TIDS Agent,ERSP Agent,Domestic Agent,Associations,Handling Agent,NISI,Airline Point of Sale,MSO Member Sales Office</value>
        </criteriaItems>
        <description>Updates the field Industry in the travel agent accounts that are uploaded from AIMS</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AIMS%3A Update Last Modified By Source</fullName>
        <actions>
            <name>Update_Last_Modified_By_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.LastModifiedById</field>
            <operation>equals</operation>
            <value>System Integrations</value>
        </criteriaItems>
        <description>Rule that updates the field Last Modified by Source with the date/time the record was last updated with master data from the source.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Account incomplete</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.BillingCountry</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Account site update</fullName>
        <actions>
            <name>Accountsiteupdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update account site if the account Record Type is Airline Branch or Airline Headquarters</description>
        <formula>and( or(RecordType.DeveloperName= &apos;IATA_Airline_BR&apos;, RecordType.DeveloperName= &apos;IATA_Airline&apos;,RecordType.DeveloperName= &apos;IATA_GSA&apos; ,(and (RecordType.DeveloperName= &apos;Standard_Account&apos;, ISPICKVAL(Sector__c,&apos;Airline&apos;)))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DDS Auto Opt-in</fullName>
        <actions>
            <name>SetDDSToNoReply</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>45 days after notification sent, automatically set to opt-in if no opt-out done</description>
        <formula>TEXT(DDS_Status__c) = &quot;No Reply&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AutoDDSOptIn</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Account.DDS_Last_Notification_Date__c</offsetFromField>
            <timeLength>45</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>DDS Update Date</fullName>
        <actions>
            <name>Update_DDS_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update last DDS Updated date</description>
        <formula>ISCHANGED(DDS_Status__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data quality comment history</fullName>
        <actions>
            <name>Data_quality_comment_history</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( Comment_data_quality_feedback__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FDS Coding AOC Expiry date alert 3 months before</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.ACLI_Status__c</field>
            <operation>equals</operation>
            <value>Active Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.AOC_Expiry_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Airline Headquarters</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ACLI_SAP_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>FDS Coding (Airline Management) - developped as part of changes for coding, Manuel G. - Used to alert a few users in the coding team, via email alert, than an AOC expiry date is approaching for the airline - business owner:  Ann Farrell</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FDS_CodingAOC</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.AOC_Expiry_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>FDS Coding AOC Expiry date alert 30 days before</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.ACLI_Status__c</field>
            <operation>equals</operation>
            <value>Active Company</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.AOC_Expiry_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Airline Headquarters</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ACLI_SAP_Id__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>FDS Coding (Airline Management) - developped as part of changes for coding, Manuel G. - Used to alert a few users in the coding team, via email alert, than an AOC expiry date is approaching for the airline - business owner:  Ann Farrell</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>FDS_CodingAOC2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Account.AOC_Expiry_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IW - Check InvoiceWorks Customer Account</fullName>
        <actions>
            <name>InvoiceWorks_Account_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>IATA IW</value>
        </criteriaItems>
        <description>This is used to automatically check the read-only field &apos;InvoiceWorks Customer&apos; when an Account is created by one of the users with IW Profiles</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Parent account IS NOT member airline</fullName>
        <actions>
            <name>Member_Airline_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Parent account IS NOT an IATA member airline. Updates field &apos;IATA member airline&apos; for subsidiaries.</description>
        <formula>Parent.IATA_Member__c  = false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Parent account IS member airline</fullName>
        <actions>
            <name>Parent_Branch_member_airlines</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Parent account is an IATA member airline.</description>
        <formula>Parent.IATA_Member__c  = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Rename Branch</fullName>
        <actions>
            <name>Update_acct_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.RecordTypeId</field>
            <operation>equals</operation>
            <value>Airline Branch</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.ParentId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset ID Card Discount</fullName>
        <actions>
            <name>Set_ID_Card_Discount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.IDCard_Key_Account__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Update Account Site</fullName>
        <actions>
            <name>SIS_Update_Account_Site</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Source_System__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SIS HelpDesk - Assign SIS recordtype when new account source system is SIS</fullName>
        <actions>
            <name>SIS_Assign_account_recordtype</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Update_Record_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Source_System__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Site Index</fullName>
        <actions>
            <name>Site_index_field_updt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>it copies the site to this filed</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
