Feature: Scheduling an End of Maintenance Mode on a kiosk

  Background:
    * def keyCloakInfo = { grant_type: 'client_credentials', client_id: 'kiosk',client_secret: 'd507efd5-f4eb-4607-8a05-91495aa8804e' }
    * call read('classpath:oauth2.feature') keyCloakInfo
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa

    * def hour =
    """
    function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var Calendar = Java.type('java.util.Calendar');
      var cal = Calendar.getInstance();
      cal.add(Calendar.HOUR, 1);
      var sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      var date = cal.getTime();
      return sdf.format(date);
    }
    """
    * def hourLater =  hour()
    * print hourLater

#    * def thirtyMinFuture = currentTime
#    * print thirtyMinFuture

  Scenario: Ending of Maintenance mode for Kiosk
    Given path 'v1/maintenance/end'
    * param maintenanceId = 1
    And request { 'when': '#(hourLater)' }
    When method post
    Then assert responseStatus == 200 || responseStatus == 400
    And match $ == '200' || {"message":"This terminal is not currently in maintenance mode"}

    * print response

#    * def result = responseStatus == 400 ? { 'message': 'This terminal is not currently in maintenance mode' } : karate.abort()
