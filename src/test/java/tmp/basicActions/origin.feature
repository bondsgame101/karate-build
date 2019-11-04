Feature: Pulling Origin

Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
  * url 'https://api.qa.tdstickets.com/ticketing/'
  #    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
  * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}
Scenario: A full purchase in TMP Dev
  Given path 'stop'
  And request { 'carrierId': 1, 'type': 'ORIGIN' }
  When method post
  Then status 200

  * def origins = response
  * def condition = function(x){ return x.stationName == 'Boston (South Station)' }
  * def temp = karate.filter(origins, condition)
  * def origin = temp[0].stopUuid
  * print origin