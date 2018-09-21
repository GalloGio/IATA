<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_90_Days_before_contract_end_date</fullName>
        <description>Alert 90 Days before contract end date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MarketingPAX/Opportunity90DaysToContractEnd</template>
    </alerts>
    <alerts>
        <fullName>Closed_deal_AME</fullName>
        <description>Closed deal AME</description>
        <protected>false</protected>
        <recipients>
            <recipient>auragh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MACS_Admin/MMAlertonClosedDealsNrcrm</template>
    </alerts>
    <alerts>
        <fullName>MACS_alert_of_new_deals_over_10K_non_rcrm</fullName>
        <ccEmails>brazeaug@iata.org, walkers@iata.org, OdeleJ@iata.org</ccEmails>
        <description>MACS alert of new deals over 10K (non rcrm)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorAmericas</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorAsiaPac</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorEurope</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorMEA</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesDirector</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesDirectorBIITCO</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>astridgec@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>auragh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bertolusj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>debonol2@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>deghelderc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heinickem@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>itania@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kikanor@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krishnanh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>legerf@iata.org.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mccorleys@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mckayt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>siponenp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wangw@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wyattj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MACS_Admin/MMAlertonClosedDealsNrcrm</template>
    </alerts>
    <alerts>
        <fullName>Marketingalertofnewdeals</fullName>
        <ccEmails>brazeaug@iata.org, walkers@iata.org, OdeleJ@iata.org</ccEmails>
        <description>MACS alert of new deals over 10K</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorAmericas</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorAsiaPac</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesAssistantDirectorEurope</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesDirector</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SalesDirectorBIITCO</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>astridgec@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>auragh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bertolusj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>debonol2@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>deghelderc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>greenwayt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>heinickem@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>itania@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kikanor@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krishnanh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>legerf@iata.org.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mccorleys@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mckayt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>siponenp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wangw@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MarketingPAX/MMAlertonClosedDeals</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Notify_Ben_Barrocas</fullName>
        <description>Opportunity: Notify Ben Barrocas</description>
        <protected>false</protected>
        <recipients>
            <recipient>barrocasb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Opportunity_Notification_to_Ben_Barrocas</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_owner_Change</fullName>
        <description>MACS  Opportunity Owner Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>siponenp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MarketingPAX/Opportunity_Owner_Change</template>
    </alerts>
    <alerts>
        <fullName>Outdated_Opportunity</fullName>
        <description>Outdated_Opportunity</description>
        <protected>false</protected>
        <recipients>
            <recipient>Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MACS_Admin/Outdated_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>RCRM_Opportunity_rejected</fullName>
        <description>RCRM Opportunity rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RCRM_Email_Notifications/Notification_to_Sales_Manager_Sale_rejected_by_PM</template>
    </alerts>
    <alerts>
        <fullName>RCRM_Opportunity_sent_for_validation_notification</fullName>
        <description>RCRM Opportunity sent for validation notification</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_RCRM_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>RCRM_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RCRM_Email_Notifications/Notification_to_Product_Manager_New_Opportunity_to_Validate</template>
    </alerts>
    <alerts>
        <fullName>RCRM_Oppotunity_validated</fullName>
        <description>RCRM Oppotunity validated</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RCRM_Email_Notifications/Notification_to_Sales_Manager_Sale_validated_by_PM</template>
    </alerts>
    <alerts>
        <fullName>RCRM_Renewal_Opportunity_Reminder</fullName>
        <description>RCRM Renewal Opportunity Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>RCRM_Email_Notifications/Contract_Renewal_Reminder</template>
    </alerts>
    <rules>
        <fullName>90 days befor contract expiry</fullName>
        <actions>
            <name>Alert_90_Days_before_contract_end_date</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Will_Renew__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.Contract_Expiry_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Africa Deal Alert</fullName>
        <active>false</active>
        <description>Identifies an opportunity closing in IATA&apos;s Africa RCT</description>
        <formula>AND (     ISPICKVAL(Geographic_Region__c, &apos;Africa&apos;),     OwnerId = LastModifiedById, Amount   &gt;= 10000,      ISPICKVAL( StageName ,&apos;7. Closed Sales / Sold&apos;),      $User.Division = &apos;MACS&apos;            )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Asia Pac Deal Alert</fullName>
        <active>true</active>
        <description>Identifies an opportunity closing in IATA&apos;s Asia Pacific RCT</description>
        <formula>AND (          OR (                ISPICKVAL(Geographic_Region__c, &apos;Asia Pacific&apos;),                ISPICKVAL(Geographic_Region__c, &apos;South Asia&apos;),                ISPICKVAL(Geographic_Region__c, &apos;Oceania&apos;)                 ),      OwnerId = LastModifiedById, Amount   &gt;= 10000,      ISPICKVAL( StageName ,&apos;7. Closed Sales / Sold&apos;),      $User.Division = &apos;MACS&apos;            )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Big Deal Alert</fullName>
        <active>false</active>
        <description>Used to send a big deal email alert.Created for Big Deal alert modification for MACS.</description>
        <formula>AND(OwnerId=LastModifiedById, Amount &gt;10000, ISPICKVAL(StageName,&quot;7. Closed Sales / Sold&quot;),  LastModifiedBy.Division  = &quot;MACS&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Business Insight Campaign Opportunity</fullName>
        <actions>
            <name>x01DetailsRevenueManagement</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x02DetailsMarketingDirector</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x03Agreewithsalesonnewprogrammembers</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x04Assignsspecificairlinesdeadlinetogetfirstinfo</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x05Developroadmapintotheorganisation</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.CampaignId</field>
            <operation>startsWith</operation>
            <value>BI Survey</value>
        </criteriaItems>
        <description>This workflow rule is triggered when an Opportunity linked with a Business Insight Survey Campaign is created or modified and the rule nerver has run. It automatically creates the 16 predefined BI Survey tasks.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Business Insight Campaign Opportunity 2</fullName>
        <actions>
            <name>x06ReceivedetailsfromCountryManager</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x07SendbrochurewithCCtoSales</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x08Decideonalistofquestionstobeasked</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x09Agreeonatimingforawebpresentation</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x10EvaluateoutputoffirstcontactsYesorNo</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.CampaignId</field>
            <operation>startsWith</operation>
            <value>BI Survey</value>
        </criteriaItems>
        <description>Same as previous, tasks 6-10</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Business Insight Campaign Opportunity 3</fullName>
        <actions>
            <name>x11Setupamanagementmeetingfollowupmeetingforpotentials</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x12Evaluateoutputofthemeetings</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x13Setuptestlogintodemositeandhandover</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x14Tailorinformationfortheindividualairlines</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>x15Followupgoornogo</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.CampaignId</field>
            <operation>startsWith</operation>
            <value>BI Survey</value>
        </criteriaItems>
        <description>Same as previous, tasks 11-15</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Business Insight Campaign Opportunity 4</fullName>
        <actions>
            <name>x16Preparecontractandsendtoclient</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.CampaignId</field>
            <operation>startsWith</operation>
            <value>BI Survey</value>
        </criteriaItems>
        <description>Same as previous, tasks 16</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Europe Deal Alert</fullName>
        <active>true</active>
        <description>Identifies an opportunity closing in IATA&apos;s Europe RCT</description>
        <formula>AND (          OR (                ISPICKVAL(Geographic_Region__c, &apos;Europe&apos;),                ISPICKVAL(Geographic_Region__c, &apos;Russia and CIS&apos;)                 ),      OwnerId = LastModifiedById, Amount   &gt;= 10000,      ISPICKVAL( StageName ,&apos;7. Closed Sales / Sold&apos;),      $User.Division = &apos;MACS&apos;            )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MACS - Close Deal Notification %28RCRM%29</fullName>
        <actions>
            <name>Marketingalertofnewdeals</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifications sent to sales and marketing about closed deals over US$ 10,000</description>
        <formula>AND(Amount &gt;= 10000, ISPICKVAL(StageName,&apos;7. Closed Sales / Sold&apos;), RecordType.Name = &quot;RCRM Opportunity&quot;,  Block_alerts_on_updates__c = false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MACS - Close Deal Notification %28non RCRM%29</fullName>
        <actions>
            <name>MACS_alert_of_new_deals_over_10K_non_rcrm</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifications sent to sales and marketing about closed deals over US$ 10,000
As it concerns non RCRM opps, the NBB is not included in the message</description>
        <formula>AND(Amount &gt;= 10000, ISPICKVAL(StageName,&apos;7. Closed Sales / Sold&apos;),  RecordType.Name &lt;&gt; &quot;RCRM Opportunity&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MENA Deal Alert</fullName>
        <actions>
            <name>Closed_deal_AME</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Customer_Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>7. Closed Sales / Sold</value>
        </criteriaItems>
        <description>Identifies an opportunity closing in IATA&apos;s MENA RCT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>North America Deal Alert</fullName>
        <active>true</active>
        <description>Identifies an opportunity closing in IATA&apos;s North America RCT</description>
        <formula>AND  (     ISPICKVAL(Geographic_Region__c, &apos;North America&apos;),     OwnerId = LastModifiedById, Amount   &gt;= 10000,      ISPICKVAL( StageName ,&apos;7. Closed Sales / Sold&apos;),      $User.Division = &apos;MACS&apos;            )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>North Asia Deal Alert</fullName>
        <active>true</active>
        <description>Identifies an opportunity closing in IATA&apos;s North Asia RCT</description>
        <formula>AND (       ISPICKVAL(Geographic_Region__c, &apos;North Asia&apos;),      OwnerId = LastModifiedById, Amount   &gt;= 10000,      ISPICKVAL( StageName ,&apos;7. Closed Sales / Sold&apos;),      $User.Division = &apos;MACS&apos;            )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>One time blast%3A Outdated Opportunities</fullName>
        <actions>
            <name>Outdated_Opportunity</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Used once to send an update to all owners of outdated opportunities</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity owner change - MACS</fullName>
        <actions>
            <name>Opportunity_owner_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Rule that identifies when an opportunity has changed owner</description>
        <formula>AND(ISCHANGED(OwnerId),  CreatedBy.Division = &quot;MACS&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity%3A Notification to Ben Barrocas</fullName>
        <actions>
            <name>Opportunity_Notify_Ben_Barrocas</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.OwnerId</field>
            <operation>equals</operation>
            <value>Tom Greenway,Maria Belen Acosta</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>y. Pending,Closed,GDP - 7. Sold,7. Closed Sales / Sold,z. Lost,Closed / Sold,GDP - z.Lost</value>
        </criteriaItems>
        <description>every time an opportunity is either CREATED or CLOSED (Won or Lost),Opportunity Owner = Tom Greenway; Maria Belen Acosta
-	Notification Recipient = Ben Barrocas</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Outdated Opportunities</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Outdated_Opportunity</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Post Sale follow-up Task</fullName>
        <actions>
            <name>Postfollowuptask</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed / Sold,7. Closed Sales / Sold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Sales_Team__c</field>
            <operation>contains</operation>
            <value>Field Sales</value>
        </criteriaItems>
        <description>Workflow  assigns a post sale follow-up task to the opportunity owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCRM Contract Renewal Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>RCRM Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Future renewal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Reminder_date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends a renewal reminder email to the owner of the RCRM renewal Opportunity at the pre-calculated date.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>RCRM_Renewal_Opportunity_Reminder</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.Reminder_date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>RCRM Send notif to PM new sale to validate</fullName>
        <actions>
            <name>RCRM_Opportunity_sent_for_validation_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>RCRM Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RCRM_Validation_Status__c</field>
            <operation>equals</operation>
            <value>Sent to PM for validation</value>
        </criteriaItems>
        <description>A notification is sent to the PM when a RCRM Opportunity is sent to him for validation. Alternate PM also receives a copy.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCRM Send notif to SM opportunity rejected by PM</fullName>
        <actions>
            <name>RCRM_Opportunity_rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification sent to the SM when the PM rejects a sale (a RCRM Opportunity). Not sent if the PM user validating the Opp is the owner (contract getting renewed by PM).</description>
        <formula>AND (   RecordType.DeveloperName = &apos;RCRM_Opportunity&apos;,   ISPICKVAL( RCRM_Validation_Status__c , &apos;Rejected by PM&apos;),   OwnerId &lt;&gt;  $User.Id  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RCRM Send notif to SM opportunity validated by PM</fullName>
        <actions>
            <name>RCRM_Oppotunity_validated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notification sent to the SM when the PM validates a sale (a RCRM Opportunity). Not sent if the PM user validating the Opp is the owner (contract getting renewed by PM).</description>
        <formula>AND (   RecordType.DeveloperName = &apos;RCRM_Opportunity&apos;,   ISPICKVAL( RCRM_Validation_Status__c , &apos;Validated by PM&apos;),   OwnerId &lt;&gt;  $User.Id  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>The Americas Deal Alert</fullName>
        <active>true</active>
        <description>Identifies an opportunity closing in IATA&apos;s The Americas RCT</description>
        <formula>AND (     ISPICKVAL(Geographic_Region__c, &apos;The Americas&apos;),     OwnerId = LastModifiedById, Amount   &gt;= 10000,      ISPICKVAL( StageName ,&apos;7. Closed Sales / Sold&apos;),      $User.Division = &apos;MACS&apos;            )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>CommunicateOrderInvoiceRequesttotheProductManager</fullName>
        <assignedToType>owner</assignedToType>
        <description>Congratulations on this new sale!

Please complete the Order &amp; Invoice procedure to be sent to the PM if not already done. This will ensure your sales efforts and those of your colleagues are properly recognized.

Kind Regards,
Finance and CPC</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Communicate Order &amp; Invoice Request to the Product Manager</subject>
    </tasks>
    <tasks>
        <fullName>EnterFinalContractdetails</fullName>
        <assignedToType>owner</assignedToType>
        <description>Dear colleague,

A copy of the contract and the revenue schedule for this deal have to be created. please make suyre you proide this input prior to closing the opportunity in Salesforce.com.

Your Corporate Services department</description>
        <dueDateOffset>-1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Enter Final Contract details</subject>
    </tasks>
    <tasks>
        <fullName>GetintouchwithyourIDFScolleague</fullName>
        <assignedToType>owner</assignedToType>
        <description>You&apos;ve just created an opportunity in a country where an IDFS colleague can be of assistance. Get in touch with him, it could be very helpful in closing this deal!</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Get in touch with your IDFS colleague</subject>
    </tasks>
    <tasks>
        <fullName>Postfollowuptask</fullName>
        <assignedToType>owner</assignedToType>
        <description>Follow-up task should be created within 3 months for this opportunity</description>
        <dueDateOffset>97</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Post follow-up task</subject>
    </tasks>
    <tasks>
        <fullName>ShareaccesstothisopportunitywithCargoISGABISpecialist</fullName>
        <assignedToType>owner</assignedToType>
        <description>Access to this opportunity must be shared with the BIS (GABI - Cargo IS) specialist. Use the &apos;Add Sales team&apos; function (menu found lower in this page) to provide him access to it. He&apos;ll do all he can to help you close this sale.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.CreatedDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Share access to this opportunity with Cargo IS/GABI Specialist</subject>
    </tasks>
    <tasks>
        <fullName>ShareaccesstothisopportunitywithConsultingEFSpecialist</fullName>
        <assignedToType>owner</assignedToType>
        <description>Access to this opportunity must be shared with the Consulkting / E&amp;F Specialist. Use the &apos;Add Sales team&apos; function (menu found lower in this page) to provide him access to it. He&apos;ll do all he can to help you close this sale.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.CreatedDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Share access to this opportunity with Consulting / E&amp;F Specialist</subject>
    </tasks>
    <tasks>
        <fullName>UpdateCloseDate</fullName>
        <assignedToType>owner</assignedToType>
        <description>Dear Colleague,

Opportunities in stage 5 normally close within the next 90 days. The Opportunity Close Date must reflect this. Please adjust as needed. This is extremely important for proper forecasting, pipeline integrity and reporting.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Update Close Date</subject>
    </tasks>
    <tasks>
        <fullName>ValidateclosedsalesinputOwner</fullName>
        <assignedToType>owner</assignedToType>
        <description>1. Account Information Complete
2. Sales Codes added - if sales involved 
3. Product &amp; Amount reflect agreement 
4. All contacts identified
5. Close date = Customer Signature Date
6. Contract Create, linked to Opportunity
7. Revenue Schedule created</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Validate closed sales input - Owner</subject>
    </tasks>
    <tasks>
        <fullName>Validateinput</fullName>
        <assignedToType>owner</assignedToType>
        <description>1. Account Information Complete
2. Sales Codes added - if sales involved 
3. Product &amp; Amount reflect agreement 
4. All contacts identified
5. Close date = Customer Signed Date
6. Contract Created, linked to Opportunity
7. Revenue Schedule created</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Validate input</subject>
    </tasks>
    <tasks>
        <fullName>x01DetailsRevenueManagement</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>01-Details Revenue Management</subject>
    </tasks>
    <tasks>
        <fullName>x02DetailsMarketingDirector</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>02-Details Marketing Director</subject>
    </tasks>
    <tasks>
        <fullName>x03Agreewithsalesonnewprogrammembers</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>03-Agree with sales on new program members</subject>
    </tasks>
    <tasks>
        <fullName>x04Assignsspecificairlinesdeadlinetogetfirstinfo</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>04-Assigns specific airlines / deadline to get first info</subject>
    </tasks>
    <tasks>
        <fullName>x05Developroadmapintotheorganisation</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>05-Develop roadmap into the organisation</subject>
    </tasks>
    <tasks>
        <fullName>x06ReceivedetailsfromCountryManager</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>06-Receive details from Country Manager</subject>
    </tasks>
    <tasks>
        <fullName>x07SendbrochurewithCCtoSales</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>07-Send brochure with CC to Sales</subject>
    </tasks>
    <tasks>
        <fullName>x08Decideonalistofquestionstobeasked</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>08-Decide on a list of questions to be asked</subject>
    </tasks>
    <tasks>
        <fullName>x09Agreeonatimingforawebpresentation</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>09-Agree on a timing for a web presentation</subject>
    </tasks>
    <tasks>
        <fullName>x10EvaluateoutputoffirstcontactsYesorNo</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>10-Evaluate output of first contacts (Yes or No)</subject>
    </tasks>
    <tasks>
        <fullName>x11Setupamanagementmeetingfollowupmeetingforpotentials</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>11-Set up a management meeting/ follow up meeting for potentials</subject>
    </tasks>
    <tasks>
        <fullName>x12Evaluateoutputofthemeetings</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>12-Evaluate output of the  meetings</subject>
    </tasks>
    <tasks>
        <fullName>x13Setuptestlogintodemositeandhandover</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>13-Set up test login to demo site / and hand over</subject>
    </tasks>
    <tasks>
        <fullName>x14Tailorinformationfortheindividualairlines</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>14-Tailor information for the individual airlines</subject>
    </tasks>
    <tasks>
        <fullName>x15Followupgoornogo</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>15-Follow up - go or no go</subject>
    </tasks>
    <tasks>
        <fullName>x16Preparecontractandsendtoclient</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>16-Prepare contract and send to client</subject>
    </tasks>
</Workflow>
