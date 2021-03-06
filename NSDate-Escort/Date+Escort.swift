import Foundation

extension Date {
    static var _currentCalendar: Calendar?
    public static var currentCalendar: Calendar {
        get {
            if _currentCalendar == nil || _currentCalendar?.identifier != identifier {
                if let identifier = defaultCalendarIdentifier {
                    _currentCalendar = Calendar(identifier: identifier)
                } else {
                    _currentCalendar = Calendar.current
                }
            }
            _currentCalendar!.timeZone = NSTimeZone.local
            return _currentCalendar!
        }
    }
    
    static var lock = NSLock()
    static var identifier: Calendar.Identifier?
    public static var defaultCalendarIdentifier: Calendar.Identifier? {
        get {
            lock.lock()
            let i = identifier
            lock.unlock()
            return i
        }
        set {
            lock.lock()
            identifier = newValue
            lock.unlock()
        }
    }
    
    //
    public static func tomorrow() -> Date {
        return Date.dateFormNow(day: 1)
    }
    
    public static func yesterday() -> Date {
        return Date.dateFormNow(day: -1)
    }
    
    public static func dateFormNow(day: Int) -> Date {
        return Date().add(day: day)
    }
    
    //
    public func startDateOfYear() -> Date {
        return date(of: .year).date
    }
    
    public func startDateOfMonth() -> Date {
        return date(of: .month).date
    }
    
    public func startDateOfWeekday() -> Date {
        return date(of: .weekOfYear).date
    }
    
    public func startDateOfDay() -> Date {
        return date(of: .day).date
    }
    
    public func date(of unit: NSCalendar.Unit) -> (date: Date, interval: TimeInterval) {
        let calendar = type(of: self).currentCalendar as NSCalendar
        var start: NSDate?
        var interval: TimeInterval = 0
        calendar.range(of: unit, start: &start, interval: &interval, for: self)
        return (start! as Date, interval)
    }
        
    
    // comparing
    public func isSameYear(as date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let leftComponents = calendar.dateComponents([.era, .year], from: self)
        let rightComponents = calendar.dateComponents([.era, .year], from: date)
        return leftComponents.era == rightComponents.era
            && leftComponents.year == rightComponents.year
    }
    
    public func isThisYear() -> Bool {
        return self.isSameYear(as: Date())
    }
    
    public func isSameMonth(as date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let leftComponents = calendar.dateComponents([.era, .year, .month], from: self)
        let rightComponents = calendar.dateComponents([.era, .year, .month], from: date)
        return leftComponents.era == rightComponents.era
            && leftComponents.year == rightComponents.year
            && leftComponents.month == rightComponents.month
    }
    
    public func isThisMonth() -> Bool {
        return self.isSameWeek(as: Date())
    }
    
    public func isSameWeek(as date: Date) -> Bool {
        let leftComponents = type(of: self).currentCalendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        let rightComponents = type(of: self).currentCalendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        return leftComponents.weekOfYear == rightComponents.weekOfYear
            && leftComponents.yearForWeekOfYear == rightComponents.yearForWeekOfYear
    }
    
    public func isThisWeek() -> Bool {
        return self.isSameWeek(as: Date())
    }
    
    public func isNextWeek() -> Bool {
        return self.isSameWeek(as: Date().add(weekOfYear: 1))
    }
    
    public func isLastWeek() -> Bool {
        return self.isSameWeek(as: Date().add(weekOfYear: -1))
    }
    
    public func isEqual(ignoringTime date: Date) -> Bool {
        let calendar = type(of: self).currentCalendar
        let components: Set<Calendar.Component> = [.era, .year, .month, .day]
        let left = calendar.dateComponents(components, from: self)
        let right = calendar.dateComponents(components, from: date)
        return left.era == right.era
            && left.year == right.year
            && left.month == right.month
            && left.day == right.day
    }
    
    public func isToday() -> Bool {
        return self.isEqual(ignoringTime: Date())
    }
    
    public func isTomorrow() -> Bool {
        return self.isEqual(ignoringTime: Date.tomorrow())
    }
    
    public func isYesterday() -> Bool {
        return self.isEqual(ignoringTime: Date.yesterday())
    }
    
    public func isInPast() -> Bool {
        return self < Date()
    }
    
    public func isInFuture() -> Bool {
        return Date() < self
    }
    
    // date roles
    public func isTypicallyWorkday() -> Bool {
        return !self.isTypicallyWeekend()
    }
    
    public func isTypicallyWeekend() -> Bool {
        let calendar = type(of: self).currentCalendar
        let weekdayRange = calendar.maximumRange(of: .weekday)
        let weekdayOfDate = calendar.component(.weekday, from: self)
        return weekdayOfDate == weekdayRange!.lowerBound || weekdayOfDate == weekdayRange!.upperBound - 1
    }
    
    // retrieving interval
    public func seconds(after date: Date) -> Int {
        return Date.currentCalendar.dateComponents([.second], from: self, to: date).second!
    }
    
    public func minutes(after date: Date) -> Int {
        return Date.currentCalendar.dateComponents([.minute], from: self, to: date).minute!
    }
    
    public func hours(after date: Date) -> Int {
        return Date.currentCalendar.dateComponents([.hour], from: self, to: date).hour!
    }
    
    public func days(after date: Date) -> Int {
        return Date.currentCalendar.dateComponents([.day], from: self, to: date).day!
    }
    
    public func months(after date: Date) -> Int {
        return Date.currentCalendar.dateComponents([.month], from: self, to: date).month!
    }
    
    public func years(after date: Date) -> Int {
        return Date.currentCalendar.dateComponents([.year], from: self, to: date).year!
    }
    
    public func add(era: Int? = nil, year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil, weekday: Int? = nil, weekdayOrdinal: Int? = nil, quarter: Int? = nil, weekOfMonth: Int? = nil, weekOfYear: Int? = nil, yearForWeekOfYear: Int? = nil) -> Date {
        var components = DateComponents()
        
        components.era = era
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        components.weekday = weekday
        components.weekdayOrdinal = weekdayOrdinal
        components.quarter = quarter
        components.weekOfMonth = weekOfMonth
        components.weekOfYear = weekOfYear
        components.yearForWeekOfYear = yearForWeekOfYear
        
        let calendar = type(of: self).currentCalendar
        return calendar.date(byAdding: components, to: self)!
    }
    
    // decomposing
    public var era: Int {
        get { return type(of: self).currentCalendar.component(.era, from: self) }
    }
    
    public var year: Int {
        get { return type(of: self).currentCalendar.component(.year, from: self) }
    }
    
    public var month: Int {
        get { return type(of: self).currentCalendar.component(.month, from: self) }
    }
    
    public var day: Int {
        get { return type(of: self).currentCalendar.component(.day, from: self) }
    }
    
    public var hour: Int {
        get { return type(of: self).currentCalendar.component(.hour, from: self) }
    }
    
    public var minute: Int {
        get { return type(of: self).currentCalendar.component(.minute, from: self) }
    }
    
    public var second: Int {
        get { return type(of: self).currentCalendar.component(.second, from: self) }
    }
    
    public var weekday: Int {
        get { return type(of: self).currentCalendar.component(.weekday, from: self) }
    }
    
    public var weekdayOrdinal: Int {
        get { return type(of: self).currentCalendar.component(.weekdayOrdinal, from: self) }
    }
    
    public var quarter: Int {
        get { return type(of: self).currentCalendar.component(.quarter, from: self) }
    }
    
    public var weekOfMonth: Int {
        get { return type(of: self).currentCalendar.component(.weekOfMonth, from: self) }
    }
    
    public var weekOfYear: Int {
        get { return type(of: self).currentCalendar.component(.weekOfYear, from: self) }
    }
    
    public var yearForWeekOfYear: Int {
        get { return type(of: self).currentCalendar.component(.yearForWeekOfYear, from: self) }
    }
    
    public var nanosecond: Int {
        get { return type(of: self).currentCalendar.component(.nanosecond, from: self) }
    }
    
    // extract
    public var gregorianYear: Int {
        get {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = NSTimeZone.local
            return calendar.dateComponents([.year], from: self).year!
        }
        
    }
    
    public var nearestHour: Int {
        get {
            let calendar = type(of: self).currentCalendar
            let minuteRange = calendar.range(of: .minute, in: .hour, for: self)!
            // always 30...
            let halfMinuteInHour = (minuteRange.upperBound - minuteRange.lowerBound) / 2
            if (minute < halfMinuteInHour) {
                return hour
            } else {
                let anHourLater = self.add(hour: 1)
                return anHourLater.hour
            }
        }
    }
}
