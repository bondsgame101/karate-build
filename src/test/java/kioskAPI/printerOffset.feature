Feature: Start Maintenance mode for kiosk

  Background:
    * def keyCloakInfo = { grant_type: 'client_credentials', client_id: 'kiosk',client_secret: 'd507efd5-f4eb-4607-8a05-91495aa8804e' }
    * call read('classpath:oauth2.feature') keyCloakInfo
    * print accessToken

    * url 'https://api.qa.tdstickets.com/kiosk'
    * configure headers = { TDS-Serial-Number: 'F183009004', Authorization: '#("Bearer " + accessToken)', Content-Type: 'application/json'} qa

    * def currentTime = function(){ return java.lang.System.currentTimeMillis() + '' }
    * print currentTime


  Scenario: Starting of Maintenance mode for Kiosk
    Given path 'v1/printer/counter'
    And request { 'printerOffset': '23', 'printerSerialNumber': '13371357' }
    When method post
    Then status 200

    * print response