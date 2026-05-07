Create a complete architecture and SwiftUI code implementation for an iOS app called **Calendy**, a 1:1 local-only alternative to the Saturn schedule app. 

**Core Constraint:** The app must be entirely **serverless**. All data must be stored locally using SwiftData or CoreData. No external APIs or accounts are required.

**Key Features to Implement:**
1.  **Local Schedule Engine:** A system to manage high school class periods, including A/B day rotations and custom bell schedules.
2.  **Home Screen Widgets:** Using WidgetKit, create a 'Next Class' widget and a 'Full Day' schedule view.
3.  **Live Activities:** Implement ActivityKit to show the current class, time remaining, and a progress bar in the **Dynamic Island** and on the Lock Screen.
4.  **Local Notifications:** Use UserNotifications to trigger alerts 5 minutes before a class begins.
5.  **Persistence Layer:** Provide a SwiftData model for `Course`, `Period`, and `SchoolDay`.

**Technical Requirements:**
*   Use **SwiftUI** for the frontend.
*   Ensure the **Live Activity** updates automatically based on a local timer or background task.
*   The UI should be clean and modern, optimized for a high school student's daily use.
*   Include the boilerplate for a `WidgetBundle` and the `Attributes` struct for the Live Activity."

---

### Implementation Tips for Calendy

Since you are targeting a local-only experience, keep these technical hurdles in mind:

*   **Persistence:** Since you have no server, **SwiftData** is your best bet for a modern app. It handles the "schema" of your school schedule easily and saves everything directly to your iPhone's storage.
*   **The "Tick" Problem:** Live Activities usually like server pushes (Push Notifications) to update. For a local app, you have to rely on `ActivityKit`'s ability to show a countdown timer that is set when the activity starts, as apps have limited background execution time.
*   **Widgets:** Remember that Home Screen widgets are not "live" apps; they are archived snapshots. You will need to tell the `TimelineProvider` to refresh the widget at the start of every class period.



### Example Data Structure
Your SwiftData model might look like this to keep things organized:

```swift
@Model
class Course {
    var name: String
    var room: String
    var teacher: String
    var startTime: Date
    var endTime: Date
    
    init(name: String, room: String, teacher: String, startTime: Date, endTime: Date) {
        self.name = name
        self.room = room
        self.teacher = teacher
        self.startTime = startTime
        self.endTime = endTime
    }
}
```