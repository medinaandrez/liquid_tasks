# LiquidTasks 💧

**LiquidTasks** is a modern, premium productivity and task management application built entirely natively for the Apple ecosystem. It features a stunning, custom **"Liquid Glass"** aesthetic design with a heavy focus on user experience, intelligent contextual interactions, and fluid animations.

## ✨ Features

- **Liquid Glass UI:** A beautiful, translucent, and vibrant user interface that looks natively spectacular on both macOS and iOS.
- **Smart Navigation:** Automatically filters tasks into "Inbox", "Today", and "Upcoming" smart views.
- **Advanced Organization:** Group your tasks organically using **Areas of Focus**, **Projects**, and color-coded **Tags**.
- **Contextual Creation:** The app is smart enough to know where you are. Press `Cmd + N` inside a Project or Area, and the new task or project will automatically inherit that context.
- **Checklists (Subtasks):** Break down complex tasks into smaller, manageable subtasks directly within the task editor.
- **Drag & Drop Reordering:** Fully persistent, drag-and-drop task sorting powered by SwiftData.
- **Swipe Actions:** Quickly complete or delete tasks with native swipe gestures on iOS.
- **Keyboard Shortcuts:** Built for power users with global shortcuts like `Cmd + N` for quick task entry.

## 🛠 Tech Stack

- **Language:** Swift 6
- **Framework:** SwiftUI
- **Database / Persistence:** SwiftData
- **Architecture:** MVVM-inspired declarative views
- **Compatibility:** macOS 14.0+ / iOS 17.0+

## 🚀 Getting Started

To run this project locally, you will need **Xcode 15** or newer.

1. Clone the repository:
   ```bash
   git clone https://github.com/medinaandrez/liquid_tasks.git
   ```
2. Open the project folder and double-click `LiquidTasks.xcodeproj` to open it in Xcode.
3. Select your target device (e.g., "My Mac" or an "iOS Simulator").
4. Press `Cmd + R` to build and run the application.

*Note: Since the app utilizes SwiftData, if you ever experience migration errors during heavy schema modifications, simply delete the app from your simulator and re-run to generate a fresh database.*

## 🎨 Design Philosophy

LiquidTasks distances itself from the flat, boring designs of traditional to-do apps. By heavily utilizing SwiftUI's `Material` system (`.thinMaterial`, `.regularMaterial`), subtle drop shadows, and vibrant background gradients, the app achieves a frosted glass look that feels tactile and alive, encouraging users to actually *want* to organize their day.

---

*Developed with ❤️ and Agentic AI assistance.*
