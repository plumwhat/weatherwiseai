import Foundation

class RecommendationEngine {
    static let shared = RecommendationEngine()
    
    private init() {}
    
    func generateRecommendations(
        activities: [Activity],
        weatherData: [String: WeatherData]
    ) -> [ActivityRecommendation] {
        var recommendations: [ActivityRecommendation] = []
        
        for activity in activities {
            guard let weather = weatherData[activity.location] else {
                // If no weather data available, mark as not recommended
                let recommendation = ActivityRecommendation(
                    activity: activity,
                    suitability: .notRecommended,
                    reasons: ["Weather data not available for \(activity.location)"],
                    timeSlotAnalysis: []
                )
                recommendations.append(recommendation)
                continue
            }
            
            let recommendation = analyzeActivity(activity, with: weather)
            recommendations.append(recommendation)
        }
        
        return recommendations.sorted { lhs, rhs in
            // Sort by suitability (Good > Possible > Not Recommended)
            let lhsValue = suitabilityValue(lhs.suitability)
            let rhsValue = suitabilityValue(rhs.suitability)
            return lhsValue > rhsValue
        }
    }
    
    private func analyzeActivity(_ activity: Activity, with weather: WeatherData) -> ActivityRecommendation {
        let today = Calendar.current.component(.weekday, from: Date())
        let todayName = dayName(for: today)
        
        // Check if activity is scheduled for today
        guard activity.isAvailableOnDay(todayName) else {
            return ActivityRecommendation(
                activity: activity,
                suitability: .notRecommended,
                reasons: ["Activity not scheduled for today (\(todayName))"],
                timeSlotAnalysis: []
            )
        }
        
        // Get today's forecast
        let todayForecast = weather.forecast.first { forecast in
            Calendar.current.isDateInToday(forecast.date)
        } ?? weather.forecast.first
        
        guard let forecast = todayForecast else {
            return ActivityRecommendation(
                activity: activity,
                suitability: .notRecommended,
                reasons: ["No forecast data available for today"],
                timeSlotAnalysis: []
            )
        }
        
        // Analyze each time slot
        var timeSlotAnalyses: [TimeSlotAnalysis] = []
        var overallIssues: [String] = []
        var goodSlots = 0
        
        for timeSlot in activity.timeSlots {
            let analysis = analyzeTimeSlot(timeSlot, activity: activity, forecast: forecast)
            timeSlotAnalyses.append(analysis)
            
            if analysis.isGood {
                goodSlots += 1
            } else {
                overallIssues.append(contentsOf: analysis.issues)
            }
        }
        
        // Determine overall suitability
        let suitability: ActivityRecommendation.SuitabilityLevel
        if goodSlots == activity.timeSlots.count {
            suitability = .good
        } else if goodSlots > 0 {
            suitability = .possible
        } else {
            suitability = .notRecommended
        }
        
        // Generate overall reasons
        var reasons: [String] = []
        if suitability == .good {
            reasons.append("All time slots have favorable weather conditions")
        } else if suitability == .possible {
            reasons.append("\(goodSlots) out of \(activity.timeSlots.count) time slots have favorable conditions")
        }
        
        // Add unique issues
        let uniqueIssues = Array(Set(overallIssues))
        reasons.append(contentsOf: uniqueIssues)
        
        return ActivityRecommendation(
            activity: activity,
            suitability: suitability,
            reasons: reasons,
            timeSlotAnalysis: timeSlotAnalyses
        )
    }
    
    private func analyzeTimeSlot(
        _ timeSlot: TimeSlot,
        activity: Activity,
        forecast: ForecastDay
    ) -> TimeSlotAnalysis {
        var issues: [String] = []
        
        // Get weather data for the time slot
        let relevantHours = forecast.hourly.filter { hourly in
            timeSlot.containsTime(hourly.time)
        }
        
        guard !relevantHours.isEmpty else {
            return TimeSlotAnalysis(
                timeSlot: timeSlot,
                isGood: false,
                issues: ["No hourly data available for time slot \(timeSlot.start)-\(timeSlot.end)"]
            )
        }
        
        // Calculate averages for the time slot
        let avgTemp = relevantHours.map { $0.temp }.reduce(0, +) / Double(relevantHours.count)
        let maxWind = relevantHours.map { $0.wind }.max() ?? 0
        let maxRain = relevantHours.map { $0.rain }.max() ?? 0
        
        // Check temperature range
        if avgTemp < Double(activity.minTemp) {
            issues.append("Temperature too low (\(Int(avgTemp))°C, minimum: \(activity.minTemp)°C)")
        } else if avgTemp > Double(activity.maxTemp) {
            issues.append("Temperature too high (\(Int(avgTemp))°C, maximum: \(activity.maxTemp)°C)")
        }
        
        // Check wind conditions
        if maxWind > Double(activity.maxWind) {
            issues.append("Wind too strong (\(Int(maxWind)) km/h, maximum: \(activity.maxWind) km/h)")
        }
        
        // Check rain conditions
        if maxRain > activity.maxRain {
            issues.append("Rain chance too high (\(maxRain)%, maximum: \(activity.maxRain)%)")
        }
        
        return TimeSlotAnalysis(
            timeSlot: timeSlot,
            isGood: issues.isEmpty,
            issues: issues
        )
    }
    
    // MARK: - Helper Methods
    
    private func suitabilityValue(_ suitability: ActivityRecommendation.SuitabilityLevel) -> Int {
        switch suitability {
        case .good: return 3
        case .possible: return 2
        case .notRecommended: return 1
        }
    }
    
    private func dayName(for weekday: Int) -> String {
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return dayNames[weekday - 1]
    }
}
