global class BulkMasking implements Database.Batchable<String>, Database.Stateful{

   public final  List<String> objList;
   public Set<String> queryList;
   public  List<QueryClass> querytosend;
    
   public BulkMasking (String objStr){
         objList=objStr.split(',');
         system.debug('objList::'+objList);
         querytosend = new List<QueryClass>();
    }
  
   public Iterable<String > start(Database.BatchableContext info){
      system.debug('objList::'+objList);
      return objList;
   }

   public void execute(Database.BatchableContext BC, List<String> objList){
        
        system.debug('objList::'+objList);
      
        
     if(objList!=null && objList.size()>0){
          Set<String> objSet =new Set<String>();
          objSet.addAll(objList);
      
      for(String obj:objSet ){
        system.debug('obj::'+obj); 
              QueryClass queryobj = getFieldAPI(obj); 
              system.debug('queryobj ::'+queryobj ); 
              STring queryVal = queryobj!=null ? queryobj.queryval : '';
             if(queryobj!=null && queryVal !='Enter At least one Object Name' && queryVal !='Object Not Found' && queryVal !='Fields Not Found'){
                 
                 querytosend.add(queryobj );
                 
                  if(queryVal!=null && queryVal!='' && obj!=null && obj!='' &&  (queryobj.emailList.size()>0 || queryobj.phonelist.size()>0 )){
                     maskFields(queryVal, obj, queryobj.emailList, queryobj.phonelist );
                  }
             } 
        }  
    
     } 
      
     }
     

   public void finish(Database.BatchableContext BC){
        sendEmail(querytosend);
   }
   
   
    public static QueryClass getFieldAPI(String searchKey) { // This method to be replaced by getFieldMapAPI
        List<String> EmailFields = new List<String>();
        List<String> PhoneFields = new List<String>();
       
       QueryClass queryCls ; 
       
        if(searchKey=='' || searchKey == null){
         return null; // 'Enter At least one Object Name';
        }else {
            sObjectType objDscrb = Schema.getGlobalDescribe().get(searchKey);
            if(objDscrb==null){
              return null; // 'Object Not Found';
            }else {
                Map<String,Schema.SObjectField> mfields = objDscrb.getDescribe().fields.getMap();
                 String strFields='';
                  if(mfields==null || mfields.size()==0 ){
                          return null; //'Fields Not Found';
                  } else { 
                      for(Schema.SObjectField field : mfields.values()) { 
                      
                      system.debug('field :::'+field );
                                if(Schema.DisplayType.EMAIL == field.getDescribe().getType() || Schema.DisplayType.PHONE == field.getDescribe().getType()){
                                    
                                    if(Schema.DisplayType.EMAIL == field.getDescribe().getType()){
                                      EmailFields.add(field.getDescribe().getName());
                                    }else{
                                     PhoneFields.add(field.getDescribe().getName());
                                    }
                                  system.debug('strFields:::'+strFields);   
                                    if(strFields==null){
                                       strFields = field.getDescribe().getName();
                                    }else{
                                       if(strFields==''){
                                         strFields +=  field.getDescribe().getName();
                                       }else{
                                         strFields += ', ' + field.getDescribe().getName();
                                       }
                                       
                                    }
                               }     
                            }
                            
                            if(strFields==null || strFields==''){
                               strFields='No Fields Found';
                            }
                      system.debug('strFields:::'+strFields);
                        queryCls = new QueryClass(EmailFields,PhoneFields,strFields);
                        return queryCls;
                   } 
            }
       } 
    }
    
  public void maskFields(String queryString, String sObj, List<String> EmailFields, List<String> PhoneFields){
      
       System.debug('queryString:' +queryString);
       queryString= 'SELECT Id,'+ ' '+queryString+' ' +'FROM ' + sObj;
       List<sObject> sobjList= Database.query(queryString);
       List<sObject> sObjectListForUpdate = new List<sObject>();
        for(sObject s : sobjList){
            sObject newSObject = (sObject)s;
            for (String emailFld : EmailFields) {
                if (newSObject.get(emailFld) != null) {
                    string updatedEmail = 'testdsmtContactemail@dsmtsupporttest.com';
                    newSObject.put(EmailFld, updatedEmail);
                }
            }   
        for (String phone : PhoneFields) {
                if (newSObject.get(phone) != null) {
                    String updatedPhone = '111-111-1111';
                    newSObject.put(phone, updatedPhone);
                }
            }           
            sObjectListForUPdate.add(newSObject);
        }
        System.debug('SOBJECT :' +sObjectListForUpdate);
        database.update(sObjectListForUpdate, false);
  
  }  
      
    public void sendEmail(List<QueryClass> querydata){
       
       string header = 'Query, Email Fields, Phone Fields \n';
       string finalstr = header ;
       for(QueryClass qury: querydata){
           string recordString = qury.queryval+','+qury.phoneList+','+qury.emailList +'\n';
           finalstr = finalstr +recordString;
        }
       
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= 'MaskingQuerries.xls';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
       
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
       
        String[] toAddresses = new list<string> {'puneet.malhotra@clearesult.com'};
        String subject ='Field Masking Data';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Field Masking Data');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
       
    }  
  
    public class QueryClass{
       List<String> emailList;
       List<String> phoneList;
       String queryval;
      
     public QueryClass(List<string> emailstr, List<string> phonestr, string querystr){
        emailList= emailstr;
        phoneList= phonestr;
       system.debug('querystr::'+querystr);
        queryval= querystr;
        
     }  
    }  
}