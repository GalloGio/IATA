/**
	* Description: This class contains the controller for the Visualforce page (Encrypt Utility)
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
public with sharing class vfIECEncryptUtility {
	// Input field values
	public string txtPlainString {get; set;}
	public string txtEncryptedString {get; set;}
	public Boolean bUrlEncode { get; set; }
	public Boolean bUrlDecode { get; set; }

	public vfIECEncryptUtility () {
		bUrlEncode = false;
		bUrlDecode = false;
	}

	public void EncryptString () {
		if (bUrlEncode)
			txtEncryptedString = IECUtil.EncryptEncodeParameter(txtPlainString);
		else
			txtEncryptedString = IECUtil.EncryptParameter(txtPlainString);
	}

	public void DecryptString () {
		if (bUrlDecode)
			txtPlainString = IECUtil.DecodeDecryptParameter(txtEncryptedString);
		else
			txtPlainString = IECUtil.DecryptParameter(txtEncryptedString);
	}
}
