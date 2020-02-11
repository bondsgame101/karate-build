Feature: Log In

  Background:
    #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}

  Scenario: A Log In and Customer Detail print
#    * header Authorization = call read('classpath:basic-auth.js') { username: 'sbrooks+ppb@tdstickets.com', password: 'test1234' } dev/stage
    * header Authorization = call read('classpath:basic-auth.js') { username: 'sbrooks+ppb1@tdstickets.com', password: 'test1234' } qa

    Given path 'user/login'
    And request {}
    When method post

    * def loggedIn = responseStatus == 200
    * print loggedIn
    * if (loggedIn) karate.call('customerDetail.feature')


