[
  {
    "$match": {
      "$and": [
        {
          "statement.context.contextActivities.parent.id": {
            "$in": [
              "https://learningcenter.salt.ch/01.customer_operations/06.Monthly_Test/26.DEC22_Mobile/"
            ]
          }
        },
        {
          "statement.verb.id": {
            "$in": [
              "http://adlnet.gov/expapi/verbs/answered",
              "https://w3id.org/xapi/adl/verbs/waived"
            ]
          }
        },
        {
          "$nor": [
            {
              "statement.actor.mbox": "mailto:bruno.baudry@salt.ch"
            },
            {
              "statement.actor.mbox": "mailto:aron.peter@salt.ch"
            }
          ]
        },
        {
          "timestamp": {
            "$gt": {
              "$dte": "2022-12-09T00:00+01:00"
            }
          }
        }
      ]
    }
  },
  {
    "$group": {
      "_id": {
        "q_id": "$statement.object.id",
        "q_fr": "$statement.object.definition.name.fr",
        "q_de": "$statement.object.definition.name.de"
      },
      "avg": {
        "$avg": "$statement.result.score.scaled"
      }
    }
  }
]