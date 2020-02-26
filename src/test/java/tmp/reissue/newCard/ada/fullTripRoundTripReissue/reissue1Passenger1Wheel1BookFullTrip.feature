Feature: Reissue of 1 passenger from 1 passenger ticket, both directions
  Background:
  #    * url 'https://api.dev.tdstickets.com/ticketing/'
  #    * url 'https://api2.stage.tdstickets.com/ticketing/'
    * url 'https://api.qa.tdstickets.com/ticketing/'
#      * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '11033144-1420-4DAA-81EC-B62BA29EC6C2', 'Content-Type': 'application/json'}
    * configure headers = { 'TDS-Carrier-Code': 'PPB', 'TDS-Api-Key': '491ACBF0-9020-4471-984F-57772F1CE9C7', 'Content-Type': 'application/json'}
    * def getDate = read('classpath:get-date.js')

    * def getRandomInt =
    """
    function(max) {
        return Math.floor(Math.random() * Math.floor(max));
    }
    """

    * def randomSchedule =
     """
     function(list) {
       var random = getRandomInt(list.length)
       return list[random]
     }
     """

    * def today = getDate("today")
    * def tomorrow = getDate("tomorrow")
    * def week = getDate("week")
    * def randomDepart = getDate("randDepart")
    * def randomReturn = getDate("randReturn")

    * call read('file:src/test/java/tmp/loggedIn/newCard/oneWay/ada/oneWayTmp1px1wheelLoggedIn.feature')

  Scenario: 1 Passenger full trip reissue
    * def reissueSchedule =
    """
    {
      "course": "OUTBOUND",
      "reissue": {
        "confirmationCode": "#(reservation.confirmationCode)",
        "courses": [
          "OUTBOUND"
        ],
        "passengers": #(reservation.passengers)
      },
      "search": {
        "departDate": "#(randomDepart)",
        "destination": {
          "stopUuid": "#(reservation.outbound.destination.stopUuid)"
        },
        "origin": {
          "stopUuid": "#(reservation.outbound.origin.stopUuid)"
        }
      }
    }
    """
    * print reissueSchedule

    Given path 'reissue/schedule'
    And request reissueSchedule
    When method post
    Then status 200

    * def schedules = response
    * def selectedSchedule = randomSchedule(schedules)
    * print selectedSchedule
    * def scheduleUuid = selectedSchedule.scheduleUuid
    * def departDate = selectedSchedule.departTime.substring(0, selectedSchedule.departTime.lastIndexOf('T'))
    * print scheduleUuid
    * print departDate