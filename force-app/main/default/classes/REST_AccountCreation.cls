@RestResource(urlMapping='/accounts/*')
global with sharing class REST_AccountCreation {
   @HttpPost
    global static AccountWrapper accPost(String name, String phone, String website) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountWrapper response = new AccountWrapper();
        Account acct = new Account();
        acct.Name = name;
        acct.Phone = phone;
        acct.Website = website;
        insert acct;
        response.acctList.add(acct);
        response.status = 'Success';
        response.message = 'Your Account was created successfully.';
        return response;
    }
    @HttpGet
    global static AccountWrapper accGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountWrapper response = new AccountWrapper();
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
      
            searchAccounts(req, res, response);
       
        return response;
    }
    
    @HttpDelete
    global static String accDelete(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        AccountWrapper response = new AccountWrapper();
        String accn = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
         if(srchAcc(accn )){
            searchAccounts(req, res, response);
            return 'Acc Delete';
         }else{
         return 'Please send Account Only';
         }
         
        
    }  
   
    
    Public static void searchAccounts(RestRequest req, RestResponse res,AccountWrapper response) {
      
        String accName= req.params.get('Name');
       
        if(accName == null || accName== '') {
            response.status = 'Error';
            response.message = 'Please provide a Name for your Account.';
            res.StatusCode = 400;
        }
        else {
            String searchAcc = '%'+accName+'%';
            List<Account> accResults =
            [SELECT Id, Name, Phone FROM Account WHERE Name LIKE : searchAcc ];
            if(accResults  != null && accResults.size() > 0) {
                response.acctList = accResults  ;
                response.status = 'Success';
                response.message = accResults.size()
                + ' Accounts were found  matched to Name.';
            }
            else {
                response.status = 'Error';
                response.message =
                'No Accounts were found based, please search again.';
            }
        }
    }
    
    private static Boolean srchAcc(String acc){
        if(acc == 'accounts') {
                return true;
        }
        return false;
    }
    
    global class AccountWrapper {
        public List<Account> acctList;
        public String status;
        public String message;
        public AccountWrapper(){
            acctList = new List<Account>();
        }
    }
}