# ArenaIQ — Venue Experience Assistant 🏟️

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Realtime-green?logo=supabase)](https://supabase.com)
[![Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-black?logo=vercel)](https://vercel.com)

> Built for **Google Hack2Skills** — Improving physical event experiences at large-scale venues.

---

## 🎯 Chosen Vertical

**Smart Venue Experience & Crowd Management**

Large sporting venues — stadiums, arenas, concert halls — host tens of thousands of attendees simultaneously. The common problems they face are:

- **Crowd bottlenecks** at entry gates and concession stands
- **Long, unpredictable wait times** at restrooms and food courts
- **Groups getting separated** inside the venue with no coordination tools
- **No real-time awareness** of which zones are congested vs. clear

ArenaIQ directly addresses all of these by acting as an intelligent, real-time venue co-pilot for every attendee.

---

## 💡 Approach & Logic

### Core Philosophy
> *"Every attendee should feel like they have a personal stadium guide in their pocket."*

ArenaIQ is built on three pillars:

1. **Sense** — Continuously monitor crowd density across every zone of the venue using a grid-based heatmap model.
2. **Think** — Run intelligent pathfinding and alert generation on top of the live density data.
3. **Guide** — Surface actionable, real-time guidance to the user through a premium glassmorphism UI.

### Architecture

```
┌────────────────────────────────────────────────────┐
│                   Flutter App (UI)                  │
│  Dashboard │ Navigation │ Queues │ Group │ Alerts   │
└──────────────────────┬─────────────────────────────┘
                       │ Provider (State Management)
          ┌────────────┴────────────┐
          │                         │
   ┌──────▼──────┐         ┌────────▼────────┐
   │  Local Mode │         │  Online Mode     │
   │ (Simulator) │         │ (Supabase RT)    │
   └──────┬──────┘         └────────┬────────┘
          │                         │
   ┌──────▼─────────────────────────▼────────┐
   │           Core Services                  │
   │  CrowdSimulator │ Pathfinder │ AlertEngine│
   └──────────────────────────────────────────┘
```

### State Management
Uses the **Provider** pattern with 5 dedicated providers:
- `VenueProvider` — Zone density, grid state, simulation tick
- `NavigationProvider` — Active route, destination, pathfinding requests
- `QueueProvider` — Wait time estimates per zone type
- `GroupProvider` — Member locations and meet-point coordination
- `AlertProvider` — Active smart alerts, history, dismissal

---

## ⚙️ How the Solution Works

### 1. 🗺️ Crowd Heatmap (10×8 Grid)
The venue is modelled as a **10 column × 8 row grid** of zones. Each zone has:
- A **type** (Gate, Seating, Food Court, Restroom, Corridor, Field)
- A **density value** (0.0 to 1.0 representing % occupancy)
- A **colour rendering** that transitions Green → Yellow → Red based on density

The grid is rendered using a custom `CustomPainter` for high performance with no external map SDK dependency.

### 2. 🌊 CrowdSimulator (Offline Mode)
When Supabase is unavailable, a local `CrowdSimulator` runs a **wave-based simulation**:
- Every 2 seconds, it applies a `sin()`-wave offset to each zone's density
- Different zone types have different base densities (e.g., food courts are busier at half-time)
- The simulation is seeded with realistic venue patterns so it feels authentic during demos

### 3. 🧭 Smart Navigation (Dijkstra Pathfinding)
The `Pathfinder` service implements **Dijkstra's shortest path algorithm** with crowd-aware edge weights:
```
edge_cost = base_distance + (crowd_density × crowd_penalty_factor)
```
- A low-density route that is slightly longer is preferred over a short route through a packed zone
- The resulting path is animated on screen as a glowing cyan route overlay
- Walk time is estimated from the path length and average crowd density

### 4. ⏱️ Queue Estimation
Each `QueuePoint` derives its estimated wait time from the zone's live density:
```
wait_time_minutes = base_wait × density² × zone_multiplier
```
- Restrooms: base = 5 min
- Food Courts: base = 8 min
- Gates: base = 3 min

### 5. 👥 Group Coordination
The `GroupProvider` simulates up to 4 group members at fixed grid positions. In online mode:
- Each member's position is synced to the `group_members` table in Supabase
- A shared **Meet Point** can be proposed and confirmed by all members in real-time
- Members are shown on the heatmap as pulsing coloured dots

### 6. 🔔 Smart Alerts (Rule-Based Engine)
The `AlertEngine` scans venue zone states every 5 seconds and fires alert rules:
- *"Gate 3 is crowded, try Gate 4"* → when density > 0.8 at a gate zone
- *"Food Court A has short queues"* → when density drops below 0.3
- *"Group member Sarah is far away"* → when member distance > 3 grid cells from user

### 7. ☁️ Supabase Real-Time Sync
When Supabase credentials are configured, the app switches to **live sync mode**:
- `venue_zones` table is subscribed to via Postgres Change Data Capture
- `group_members` table is updated on every position change
- `smart_alerts` table broadcasts alerts to all users in real-time
- Graceful offline fallback: if the connection drops, the app silently reverts to local simulation

---

## 📐 Assumptions Made

| # | Assumption | Rationale |
|---|-----------|-----------|
| 1 | The venue layout is fixed as a **10×8 grid** | Simplifies the demo while still being representative of a real stadium's zone structure |
| 2 | Crowd density data is **simulated** when Supabase is not configured | Enables fully offline demos without requiring a live backend |
| 3 | Group members are pre-populated with **simulated friends** | Demonstrates the feature without requiring multiple real devices in a hackathon setting |
| 4 | Walk speed is assumed to be **constant** (1 grid cell ≈ 30 seconds) | A reasonable average walking pace inside a crowded venue |
| 5 | The user's **starting position** is the venue entrance (top-left gate) | This is the logical starting point for any first-time attendee |
| 6 | Queue wait times are **estimated from density** rather than actual queue counts | In a production system, this would be replaced with camera-based people counting or turnstile data |
| 7 | Supabase Realtime is used for **broadcasting all events** | This is the simplest architecture for a hackathon; production would use a dedicated event streaming service |

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.x (Dart) |
| State Management | Provider |
| Backend / Realtime | Supabase (PostgreSQL + Realtime) |
| Offline Simulation | Custom Dart `CrowdSimulator` |
| Pathfinding | Dijkstra's Algorithm (custom Dart implementation) |
| Map Rendering | Flutter `CustomPainter` |
| Animations | `flutter_animate` |
| UI Design | Glassmorphism with `BackdropFilter` + `google_fonts` |
| Deployment | Vercel |
| Icons | `iconsax_flutter` |

---

## 🚀 Running Locally

```bash
# Clone the repository
git clone https://github.com/Subha2411/Promptwars.git
cd Promptwars/arena_iq

# Install dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Or run on a connected device
flutter run
```

> The app runs fully in **offline mode** by default. No Supabase credentials required.

### Enabling Supabase (Optional)
Edit `lib/config/supabase_config.dart`:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 🌐 Deploying to Vercel

You can deploy this Flutter Web app directly to Vercel by importing the repository and applying the following configuration:

*   **Framework Preset:** `Other`
*   **Root Directory:** `arena_iq`
*   **Build & Development Settings:**
    *   **Build Command:** `flutter/bin/flutter build web --release`
    *   **Install Command:** `if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter doctor && flutter/bin/flutter clean && flutter/bin/flutter config --enable-web`
    *   **Output Directory:** `build/web`

---

## 📊 Supabase Schema

```sql
-- Venue Zones
create table venue_zones (
  id text primary key,
  col int, row int,
  type text, density float,
  updated_at timestamptz default now()
);

-- Group Members
create table group_members (
  id uuid primary key default gen_random_uuid(),
  name text, avatar_color int,
  grid_col int, grid_row int,
  meet_point_col int, meet_point_row int
);

-- Smart Alerts
create table smart_alerts (
  id uuid primary key default gen_random_uuid(),
  type text, title text, message text,
  zone_id text, created_at timestamptz default now()
);
```

---

## 🎨 Design System

The UI is built on a **glassmorphism design system**:
- Dark base: `#0A0E1A`
- Primary accent: Cyan `#00D4FF`
- Secondary accent: Purple `#6C47FF`
- Success accent: Green `#00FF94`
- All surfaces: `BackdropFilter` with `blur(12)` + semi-transparent white borders

---

## 👥 Team

Built with ❤️ for **Google Hack2Skills** Hackathon.

---

*ArenaIQ — Navigate smarter. Wait less. Enjoy more.*
