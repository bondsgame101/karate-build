Feature: Start Maintenance mode for kiosk

  Background:
    * url 'https://accounts.stage.tdstickets.com/auth/realms/qa/protocol/openid-connect/token'
    * form field grant_type = 'client_credentials'
    * form field client_id = 'kiosk'
    * form field client_secret = 'd507efd5-f4eb-4607-8a05-91495aa8804e'
    * method post
    * status 200

    * def accessToken = response.access_token
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa

    * def currentTime = function(){ return java.lang.System.currentTimeMillis() + '' }
    * print currentTime


  Scenario: Starting of Maintenance mode for Kiosk
    Given path 'v1/printer/counter'
    And request { 'inchesPrinted': '5960', 'printerSerialNumber': '13371357', 'ticketsPrinted': '745' }
    When method post
    Then status 200

    * print response