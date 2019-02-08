@isTest
private class EC2ConnectionTest {

	@isTest
	static void t1() {
		try {
			EC2Connection cc = new EC2Connection();
			system.assert( cc.TimeStamp() != null );
			EC2Connection.EC2Image ei = new EC2Connection.EC2Image();
			EC2Connection.EC2Instance ec2i  = new EC2Connection.EC2Instance();
			List<EC2Connection.EC2Image> di =  cc.DescribeImages('owner');
		} catch (Exception ex) {
		}
	}

	@isTest
	static void t2() {
		try {
			EC2Connection cc = new EC2Connection();
			HttpResponse t2 =  cc.RunInstances('imageid');
		} catch (Exception ex) {
		}

	}

	@isTest
	static void t3() {
		try {
			EC2Connection cc = new EC2Connection();
			HttpResponse t2 =  cc.TerminateInstances('imageid');
		} catch (Exception ex) {
		}
	}

	@isTest
	static void t4() {
		try {
			EC2Connection cc = new EC2Connection();
			HttpResponse t2 =  cc.RebootInstances('imageid');
		} catch (Exception ex) {
		}
	}

	@isTest
	static void t5() {
		try {
			EC2Connection cc = new EC2Connection();
			List<EC2Connection.EC2Instance> t2 =  cc.DescribeInstances();
		} catch (Exception ex) {
		}
	}

	@isTest
	static void t6() {
		try {
			EC2Connection cc = new EC2Connection();
			string tst_msg = '<?xml version="1.0"?><DescribeImagesResponse xmlns="http://ec2.amazonaws.com/doc/2008-05-05/"><imagesSet><item><imageId>aki-9800e5f1</imageId><imageLocation>ec2-public-images/vmlinuz-2.6.18-xenU-ec2-v1.0.x86_64.aki.manifest.xml</imageLocation>' +
			                 '<imageState>available</imageState><imageOwnerId>amazon</imageOwnerId><isPublic>true</isPublic><architecture>x86_64</architecture><imageType>kernel</imageType>' +
			                 '</item><item><imageId>aki-9b00e5f2</imageId><imageLocation>ec2-public-images/vmlinuz-2.6.18-xenU-ec2-v1.0.i386.aki.manifest.xml</imageLocation><imageState>available</imageState>' +
			                 '<imageOwnerId>amazon</imageOwnerId><isPublic>true</isPublic><architecture>i386</architecture><imageType>kernel</imageType></item>' +
			                 '</imagesSet></DescribeImagesResponse>';
			List<EC2Connection.EC2Image> imagelist =  cc.parseDescribeImagesReponse(tst_msg);

			string test_msg2 =
			    '<?xml version="1.0"?><DescribeInstancesResponse xmlns="http://ec2.amazonaws.com/doc/2008-05-05/"><reservationSet><item><reservationId>r-caf32da3</reservationId><ownerId>99999999914</ownerId><groupSet><item><groupId>general</groupId></item></groupSet><instancesSet><item><instanceId>i-9415bbfd</instanceId><imageId>ami-2c2fcb45</imageId><instanceState><code>16</code><name>running</name></instanceState><privateDnsName>domU-12-31-39-00-B5-26.compute-1.internal</privateDnsName><dnsName>ec2-75-101-158-228.compute-1.amazonaws.com</dnsName>' +
			    '<reason/><keyName>ssh-1</keyName><amiLaunchIndex>0</amiLaunchIndex><productCodes/><instanceType>m1.small</instanceType><launchTime>2008-10-21T17:22:01.000Z</launchTime><placement><availabilityZone>us-east-1c</availabilityZone></placement></item></instancesSet></item>    </reservationSet></DescribeInstancesResponse>';
			List<EC2Connection.EC2Instance> instList = cc.parseDescribeInstancesResponse(test_msg2);
		} catch (Exception ex) {
		}

	}

}