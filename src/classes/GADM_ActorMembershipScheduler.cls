global without sharing class GADM_ActorMembershipScheduler implements Schedulable {

	global void execute(SchedulableContext context) {
		notifyUsersAboutActorMembershipTermination();
	}

	private void notifyUsersAboutActorMembershipTermination() {
		GADM_ActorMembershipNotifier.notifyUsers();
	}

}
