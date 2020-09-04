//
//  Constants.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Config {
        static let authHeader = "Authorization"
        static let meditations = "meditations"
        static let activities = "activities"
        static let purchases = "purchases"
        static let categories = "categories"
        static let generateUrl = "generateUrl"
        static let goals = "goals"
        static let ratings = "ratings"
        static let auth = "auth"
    }
    
    struct Analytics {
        // https://support.google.com/firebase/answer/6317498?hl=en&ref_topic=6317484
        static let networkCallSuccess = "NETWORK_CALL_SUCCESS"
        static let networkCallFailure = "NETWORK_CALL_FAILURE"
        static let GOAL_ADDED = "GOAL_ADDED"
        static let GOAL_UPDATED = "GOAL_UPDATED"
        static let MEDITATION_PLAYED = "MEDITATION_PLAYED"
        static let POST_ACTIVITY = "POST_ACTIVITY"
        static let RATING_POSTED = "RATING_POSTED"
        static let requestURL = "requestURL"
        static let code = "code"
        static let response = "response"
        static let present_offer = "present_offer"
    }
    
    struct Model {
        static let count = "count"
        static let total = "total"
        static let data = "data"
        static let exclusiveStartKey = "ExclusiveStartKey"
        static let lastEvaluatedKey = "LastEvaluatedKey"
    }
    
    struct Colors {
        static let lightishBlue = "346EFF"
        static let darkBlue = "002D9C"
    }
    
    struct Notifications {
        static let BuyProductNotification = "BuyProductNotification"
        static let GoalSet = "GoalSet"
        static let GoalDeleted = "GoalDeleted"
    }
    
    struct UserDefaultsKeys {
        static let meditationCompleteCount = "meditationCompleteCount"
        static let didShowRatingDialogueRecently = "didShowRatingDialogueRecently"
        static let didSubmitRating = "didSubmitRating"
        static let firstGoalCount = "firstGoalCount"
        static let encourageCount = "encourageCount"
        static let accessCode = "accessCode"
    }

}
