
# FinView Lite — Investment Insights Dashboard 🚀📊

**FinView Lite** is a **Flutter-based investment portfolio management dashboard** that gives users an interactive and insightful view of their financial holdings. Designed for **simplicity, responsiveness, and visual clarity**, it works seamlessly across **mobile, desktop, and web platforms**.  

FinView Lite is more than a dashboard—it's an exploration of the investment universe, where every interaction reflects how financial decisions shape your portfolio journey.

---

## Features ✨

### 🔐 Authentication & User Management
- **Mock Login** using local JSON data (`assets/portfolio.json`).  
- **Password Policy**: Minimum 6 characters, at least one uppercase letter, one number, and one symbol.  
- **Persistent Sessions**: Users stay logged in using **shared preferences**.  
- **Logout** clears the session and returns to the login screen.

### 📈 Dashboard & Portfolio Visualization
- **Portfolio Summary Card**  
  - Shows total portfolio value and gain/loss.  
  - Toggle between **absolute gain** and **percentage gain**.  
  - Animated sparkline chart shows portfolio performance trends.  

- **Interactive Asset Allocation Chart**  
  - Pie chart for top holdings by value, units, gain, or loss.  
  - Hover highlights corresponding row in holdings list (web only).  
  - Click a slice to scroll to the holding in the table.  

- **Holdings Table**  
  - Displays symbol, name, units, average cost, current value, and gain/loss.  
  - Hover highlights rows; click to view detailed popup info.  
  - Columns are **sortable** (symbol, name, units, value, gain/loss).  

- **Portfolio Refresh**  
  - Manual refresh simulates updated prices.  
  - Snackbars provide feedback for success or failure.

### 🎨 Theme & Customization
- **Dark/Light Mode Toggle**.  
- Philosophical space-themed color palette representing growth and evolution of investments.  

---

## Demo Login Credentials 🧾

- **Username:** Aarav Patel  
- **Password:** A@234A  

---

## Installation & Setup ⚙️

### Prerequisites
- Flutter >= 3.0  
- Dart (included with Flutter SDK)  
- Git  

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/finview_lite.git
cd finview_lite
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
- **Web:**  
```bash
flutter run -d chrome
```  
- **Desktop (Windows):**  
```bash
flutter run -d windows
```  
- **Mobile:**  
```bash
flutter run -d <device_id>
```

4. **Login** using the demo credentials above.

---

## Project Structure 🗂️

```
finview_lite/
│
├─ assets/
│   ├─ portfolio.json      # Mock data
│   └─ screenshots/        # Screenshots for README
│
├─ lib/
│   ├─ main.dart           # Entry point
│   ├─ models/             # Portfolio and holdings models
│   ├─ screens/            # Login, Dashboard, Summary screens
│   ├─ widgets/            # Charts, tables, cards
│   └─ theme/              # AppTheme.dart for colors and fonts
│
├─ pubspec.yaml            # Flutter dependencies
└─ README.md               # This file
```

---

## Notes 📝
- All data is mocked locally in `assets/portfolio.json`.  
- Charts use Flutter’s `fl_chart` library.  
- Fully responsive for **mobile, desktop, and web**.  
- Web-specific hover and click interactions are optimized.  
- Supports **dark and light themes**.  
- Table features like **sorting, highlighting, and detailed popups** enhance usability.  

---

## Suggested Enhancements 💡
- Add **dark mode toggle**.  
- Manual portfolio refresh simulating live prices.  
- Smooth animations for charts and portfolio summary.  

---

## Screenshots 📸

### Login Screen
![Login](assets/screenshots/Login.jpg)

### Dashboard
![Dashboard](assets/screenshots/Dashboard.jpg)  
![Dashboard - Light Mode](assets/screenshots/DashboardLightMode.jpg)

### Holdings Table
![Table - Dark Mode](assets/screenshots/TableDarkMode.jpg)  
![Table - Light Mode](assets/screenshots/TableLightMode.jpg)

### No Data Handling
![No Data Handling](assets/screenshots/NoDataHandling.jpg)

### Responsiveness
![Responsiveness](assets/screenshots/Responsiveness.jpg)

---

## License 📄
This project is **open-source** and free to use for learning and demonstration purposes.
