<?xml version="1.0" encoding="UTF-8"?>
<Agencies>
		<Agency>
				<ID label="ID" type="ID">XXXX</ID>
				<Name label="AMS Agency Name" type="Text">XXXX</Name>
				<A_Code__c label="A Code" length="4" type="Text">XXXX</A_Code__c>
				<Account__c label="Account" type="Lookup">XXXX</Account__c>
				<Airline_Code__c label="Airline Code" length="10" type="Text">XXXX</Airline_Code__c>
				<BSP_Code__c label="BSP Code" length="10" type="Text">XXXX</BSP_Code__c>
				<CASS_Number__c label="CASS Number" type="Number" precision="18" scale="0">XXXX</CASS_Number__c>
				<C_Code__c label="C Code" length="4" type="Text">XXXX</C_Code__c>
				<Chk_Dgt__c label="Check Digit" type="Number" precision="2" scale="0">XXXX</Chk_Dgt__c>
				<Company_Type__c label="Company Type" type="Picklist">XXXX</Company_Type__c>
				<IATACode__c label="IATA Code" length="20" type="Text">XXXX</IATACode__c>
				<Last_Inspection_Date__c label="Last Inspection Date" type="Date">XXXX</Last_Inspection_Date__c>
				<Legal_Name_2__c label="Legal Name 2" length="255" type="Text">XXXX</Legal_Name_2__c>
				<Legal_Name_3__c label="Legal Name 3" length="255" type="Text">XXXX</Legal_Name_3__c>
				<License_Number__c label="License Number" length="10" type="Text">XXXX</License_Number__c>
				<Location_Category__c label="Location Category" type="MultiselectPicklist">XXXX</Location_Category__c>
				<Location_Class__c label="Location Class" type="Picklist">XXXX</Location_Class__c>
				<NPrimaryAddresses__c label="NPrimaryAddresses" type="Summary">XXXX</NPrimaryAddresses__c>
				<N_Code__c label="N Code" length="4" type="Text">XXXX</N_Code__c>
				<Organization_Last_Change_Date__c label="Organization Last Change Date" type="Date">XXXX</Organization_Last_Change_Date__c>
				<Original_Approval_DAte__c label="Original Approval DAte" type="Date">XXXX</Original_Approval_DAte__c>
				<Other_Tax_Reference_Number__c label="Other Tax Reference Number" length="10" type="Text">XXXX</Other_Tax_Reference_Number__c>
				<Parent_Reference_Number__c label="Parent Reference Number" length="10" type="Text">XXXX</Parent_Reference_Number__c>
				<Phone_Number__c label="Phone Number" type="Phone">XXXX</Phone_Number__c>
				<Primary_address__c label="Primary address" type="Lookup">XXXX</Primary_address__c>
				<Recert_Expiry_Date__c label="Recert Expiry Date" type="Date">XXXX</Recert_Expiry_Date__c>
				<Reference_Number__c label="Reference Number" length="10" type="Text">XXXX</Reference_Number__c>
				<STD_Code__c label="STD Code" type="Number" precision="18" scale="0">XXXX</STD_Code__c>
				<Tax_Reference_Number__c label="Tax Reference Number" length="10" type="Text">XXXX</Tax_Reference_Number__c>
				<Trading_Name_1__c label="Trading Name 1" length="255" type="Text">XXXX</Trading_Name_1__c>
				<Trading_Name_2__c label="Trading Name 2" length="255" type="Text">XXXX</Trading_Name_2__c>
				<Verification_Date__c label="Verification Date" type="Date">XXXX</Verification_Date__c>
				<Addresses>
						<Address>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="Address Name" type="AutoNumber">XXXX</Name>
								<AMS_Country__c label="" type="Lookup">XXXX</AMS_Country__c>
								<AMS_Last_synchronization__c label="Last synchronization" type="DateTime">XXXX</AMS_Last_synchronization__c>
								<AMS_State__c label="State/Province" type="Lookup">XXXX</AMS_State__c>
								<AMS_ZipCode__c label="Zip/Postal Code" length="80" type="Text">XXXX</AMS_ZipCode__c>
								<Address_1__c label="Address 1" length="80" type="Text">XXXX</Address_1__c>
								<Address_2__c label="Address 2" length="80" type="Text">XXXX</Address_2__c>
								<Address_3__c label="Address 3" length="80" type="Text">XXXX</Address_3__c>
								<Address_Type__c label="Address Type" type="Picklist">XXXX</Address_Type__c>
								<Agency__c label="Agency" type="MasterDetail">XXXX</Agency__c>
								<City__c label="City" length="80" type="Text">XXXX</City__c>
								<Country_postal_abbreviation__c label="Country postal abbreviation" length="5" type="Text">XXXX</Country_postal_abbreviation__c>
								<Email__c label="Email" type="Email">XXXX</Email__c>
								<Fax__c label="Fax" type="Phone">XXXX</Fax__c>
								<Mobile__c label="Mobile" type="Phone">XXXX</Mobile__c>
								<Site_type__c label="Site type" type="Picklist">XXXX</Site_type__c>
								<Telephone__c label="Telephone" type="Phone">XXXX</Telephone__c>
								<Website__c label="Website" length="255" type="Text">XXXX</Website__c>
						</Address>
				</Addresses>
				<Agency_Profiles>
						<Agency_Profile>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="Address Name" type="AutoNumber">XXXX</Name>
								<Agency__c label="Agency" type="Lookup">XXXX</Agency__c>
								<Last_synchronization__c label="Last synchronization" type="DateTime">XXXX</Last_synchronization__c>
								<Location_Principal_Activity__c label="Location Principal Activity" type="Picklist">XXXX</Location_Principal_Activity__c>
								<Location_Principal_Destinations__c label="Location Principal Destinations" type="MultiselectPicklist">XXXX</Location_Principal_Destinations__c>
								<Location_Principal_Market_Specialization__c label="Location Principal Market Specialization" type="MultiselectPicklist">XXXX</Location_Principal_Market_Specialization__c>
								<Market_Focus_Corporate__c label="Market Focus Corporate" type="Picklist">XXXX</Market_Focus_Corporate__c>
								<Market_Focus_Leisure__c label="Market Focus Leisure" type="Picklist">XXXX</Market_Focus_Leisure__c>
								<Percentage_sold_of_Accomodation__c label="Percentage sold of Accomodation" type="Picklist">XXXX</Percentage_sold_of_Accomodation__c>
								<Percentage_sold_of_Air__c label="Percentage sold of Air" type="Picklist">XXXX</Percentage_sold_of_Air__c>
								<Percentage_sold_of_Land_Car__c label="Percentage sold of Land/Car" type="Picklist">XXXX</Percentage_sold_of_Land_Car__c>
								<Percentage_sold_of_Sea_Cruise__c label="Percentage sold of Sea/Cruise" type="">XXXX</Percentage_sold_of_Sea_Cruise__c>
								<Percentage_sold_of_Tour_Packages__c label="Percentage sold of Tour Packages" type="Picklist">XXXX</Percentage_sold_of_Tour_Packages__c>
								<Sales_Volume__c label="Sales Volume" type="Picklist">XXXX</Sales_Volume__c>
								<Name label="Agency Profile Name" type="AutoNumber">XXXX</Name>
								<ID label="ID" type="ID">XXXX</ID>
						</Agency_Profile>
				<Agency_Profiles>
				<Agents>
						<Agent>
								<ID label="ID" type="ID">XXXX</ID>				
								<Name label="Agent Last Name" type="Text">XXXX</Name>
								<Agency__c label="Agency" type="Lookup">XXXX</Agency__c>
								<Contact__c label="Contact" type="Lookup">XXXX</Contact__c>
								<First_Name__c label="Agent First Name" length="80" type="Text">XXXX</First_Name__c>
								<Language_of_correspondence__c label="Correspondence Language" type="Picklist">XXXX</Language_of_correspondence__c>
								<Last_Case_Assigned_Date_Time__c label="Last Case Assigned Date/Time" type="DateTime">XXXX</Last_Case_Assigned_Date_Time__c>
								<Last_synchronization__c label="Last synchronization" type="DateTime">XXXX</Last_synchronization__c>
								<Log_on_picklist__c label="Log on picklist" type="Picklist">XXXX</Log_on_picklist__c>
								<Logged_on__c label="Logged on" type="Checkbox">XXXX</Logged_on__c>
								<Maximum_case_workload__c label="Maximum case workload" type="Number" precision="2" scale="0">XXXX</Maximum_case_workload__c>
								<Maximum_cases_at_one_time__c label="Maximum cases at one time" type="Number" precision="2" scale="0">XXXX</Maximum_cases_at_one_time__c>
								<Next_case_request_date_time__c label="Next case request date/time" type="DateTime">XXXX</Next_case_request_date_time__c>
								<Region__c label="Region" type="Picklist">XXXX</Region__c>
								<Request_next_case__c label="Request next case" type="Checkbox">XXXX</Request_next_case__c>
								<User__c label="User" type="Lookup">XXXX</User__c>
								<isManager__c label="is Manager" type="Checkbox">XXXX</isManager__c>
						</Agent>
				</Agents>
				<Agency_Owners>
						<Agency_Ownership>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="AMS Agency Ownership Name" type="AutoNumber">XXXX</Name>
								<AMS_Agency_Owner__c label="Owner" type="MasterDetail">XXXX</AMS_Agency_Owner__c>
								<Agency__c label="Agency" type="MasterDetail">XXXX</Agency__c>
								<Percentage__c label="Percentage" type="Percent" precision="18" scale="2">XXXX</Percentage__c>
						</Agency_Ownership>
				</Agency_Owners>
				<Agency_computer_reservations>
						<Agency_computer_reservation>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="AMS Agency Computer Reservation Name" type="AutoNumber">XXXX</Name>
								<Agency__c label="Agency" type="MasterDetail">XXXX</Agency__c>
								<Computer_Reservation_System__c label="Computer Reservation System" type="MasterDetail">XXXX</Computer_Reservation_System__c>
						</Agency_computer_reservation>
				</Agency_computer_reservations>
				<Appointments>
						<Appointment>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="Appointment Name" type="AutoNumber">XXXX</Name>
								<Accreditation_Endorsement_Status_code__c label="Accreditation/Endorsement Status code" type="Picklist">XXXX</Accreditation_Endorsement_Status_code__c>
								<Accreditation_Endorsement_organisation__c label="Accreditation/Endorsement organisation" type="Picklist">XXXX</Accreditation_Endorsement_organisation__c>
								<Agency__c label="Agency" type="Lookup">XXXX</Agency__c>
								<Date_Organisation_Status_attained__c label="Date Organisation Status attained" type="Date">XXXX</Date_Organisation_Status_attained__c>
								<Last_synchronization__c label="Last synchronization" type="DateTime">XXXX</Last_synchronization__c>
								<Location_is_Endorsed_or_Accredited__c label="Location is Endorsed or Accredited by" type="Picklist">XXXX</Location_is_Endorsed_or_Accredited__c>
						</Appointment>
				</Appointments>
				<Agency_Airports>
						<Agency_Airport>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="Agency Airport (AMS) Name" type="AutoNumber">XXXX</Name>
								<Agency__c label="Agency" length="20" type="MasterDetail">XXXX</Agency__c>
								<Airport__c label="Airport" length="10" type="MasterDetail">XXXX</Airport__c>
						</Agency_Airport>
				</Agency_Airports>
				<Employees>
						<Employee>
								<ID label="ID" type="ID">XXXX</ID>
								<Name label="AMS Employee Name" type="AutoNumber">XXXX</Name>
								<Agency__c label="Agency" type="MasterDetail">XXXX</Agency__c>
								<Person__c label="Person" type="MasterDetail">XXXX</Person__c>
								<Title__c label="Title" length="200" type="Text">XXXX</Title__c>
								<Valid__c label="Valid" type="Checkbox">XXXX</Valid__c>
						</Employee>
				</Employees>
		</Agency>
</Agencies>
