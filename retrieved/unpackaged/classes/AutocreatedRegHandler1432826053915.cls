/**
*   @Author         :   Jitendra Zaa
*   @Date           :   5/29/2015
*   @Description    :   Match User from Other Salesforce instance with this Salesforce.
*
**/
global class AutocreatedRegHandler1432826053915 implements Auth.RegistrationHandler{
     /**
     *  This method is used to match existing user, If not find then we can create new User.
     *  This method will be executed only first time so that Salesforce can relate two users
     */
    global User createUser(Id portalId, Auth.UserData data){
    system.debug('data.username:::'+data.username);
        User u = [SELECT ID FROM User Where Other_Salesforce_Org_Username__c = : data.username];
       system.debug('u:::'+u);
        return u;
    }

    /**
    *   Once Users are related, after that whenever user will return, this method wil be executed.
    *   If needed, we can perform any information needed.
    *   In this blog , we are not going to perform any operation in this method.
    */
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
       //No Operation
    }
}