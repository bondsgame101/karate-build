Feature: Start Maintenance mode for kiosk

  Background:
    * def keyCloakInfo = { grant_type: 'client_credentials', client_id: 'kiosk',client_secret: 'd507efd5-f4eb-4607-8a05-91495aa8804e' }
    * call read('classpath:oauth2.feature') keyCloakInfo
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa


    * def currentTime =
    """
    function() {
      var SimpleDateFormat = Java.type('java.text.SimpleDateFormat');
      var Calendar = Java.type('java.util.Calendar');
      var cal = Calendar.getInstance();
      var sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      var date = cal.getTime();
      return sdf.format(date);
    }
    """
    * def now =  currentTime()
    * print now



  Scenario: Starting of Maintenance mode for Kiosk
    Given path 'v1/maintenance/start/'
    And request { 'when': '#(now)' }
    When method post
    Then status 200

    * print response
