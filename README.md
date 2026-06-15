# ArenaIQ 🏟️ — Intelligent Venue Experience Assistant

> **Google Hack2Skills Submission**  
> *Improving the physical event experience at large-scale sporting venues*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Realtime-green?logo=supabase)](https://supabase.com)
[![Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-black?logo=vercel)](https://vercel.com)
[![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

---

## 🎯 Chosen Vertical — Smart Venue Experience

Attending a large-scale sporting event should be exciting — but the reality is often long queues, crowd confusion, and separated groups. **ArenaIQ** is an intelligent real-time venue assistant that makes navigating a 100,000-seat stadium as easy as using Google Maps.

**Key problems we solve:**
| Problem | ArenaIQ Solution |
|---------|-----------------|
| Crowded entry gates | Live heatmap shows least-crowded gates |
| Long restroom/food queues | Real-time wait time estimates per zone |
| Getting lost in the crowd | Density-optimised navigation routes |
| Groups getting separated | Live group member tracking + shared meet points |
| No situational awareness | Proactive smart alerts pushed to your phone |

---

## 💡 Approach & Logic

### The Core Idea
We model the entire venue as a **10×8 intelligent grid** where every cell is a "zone" (Gate, Seating, Food Court, Restroom, Corridor, Field). Each zone has a live **crowd density value** (0% to 100%) that updates every 2 seconds.

On top of this live grid, we run three core algorithms:

1. **Crowd-Aware Pathfinding** — Modified Dijkstra's algorithm that treats dense zones as "expensive" to cross, routing you around bottlenecks automatically.
2. **Queue Estimation Engine** — Derives wait time from zone density using a calibrated formula per zone type.
3. **Rule-Based Alert Engine** — Scans the grid every 5 seconds and fires human-readable alerts when conditions change (e.g., *"Gate 3 is getting crowded, try Gate 4"*).

### Offline-First, Cloud-Ready Architecture
```
┌────────────────── Flutter App ──────────────────────┐
│   Dashboard | Navigation | Queues | Group | Alerts  │
└──────────────────────┬──────────────────────────────┘
                       │ Provider State Management
          ┌────────────┴────────────┐
    ┌─────▼──────┐           ┌──────▼──────┐
    │ Offline    │           │ Online Mode │
    │ Simulation │           │  Supabase   │
    │ (Default)  │           │  Realtime   │
    └─────┬──────┘           └──────┬──────┘
          └──────────┬──────────────┘
              ┌──────▼──────────────────┐
              │  CrowdSimulator         │
              │  Pathfinder (Dijkstra)  │
              │  AlertEngine            │
              └─────────────────────────┘
```

The app works **100% offline** using a local wave-based crowd simulator, making it demo-ready without any network dependency. When Supabase credentials are added, it seamlessly switches to live multi-device sync.

---

## ⚙️ How the Solution Works

### 🗺️ Live Crowd Heatmap
- Venue is rendered as a `CustomPainter` 10×8 grid (no external map SDK needed)
- Cell colour transitions: 🟢 Green (< 35%) → 🟡 Yellow (35–65%) → 🔴 Red (> 65%)
- Colour opacity scales with exact density percentage for a true heatmap feel
- Updates every 2 seconds via `CrowdSimulator` (offline) or Supabase Realtime (online)

### 🧭 Smart Navigation
- Select a destination zone from the filter bar (Gate / Seating / Food Court / Restroom)
- Pathfinder runs Dijkstra's algorithm with this edge cost formula:
  ```
  edge_cost = 1.0 + (zone.density × 5.0)
  ```
- Low-density detour > short high-density path
- Route is drawn as an animated glowing cyan line over the heatmap
- Walk time estimated as: `steps × 30 seconds × average_density_multiplier`

### ⏱️ Queue Insights
- Each service zone (Food Court, Restroom, Gate) shows a live wait time estimate:
  ```
  wait_time = base_minutes × density² × zone_type_multiplier
  ```
- Cards update in real-time and sort by shortest wait first

### 👥 Group Coordination
- Up to 4 group members tracked on the heatmap as pulsing coloured dots
- Any member can propose a **Meet Point** — a shared rendezvous zone
- In online mode, positions and meet points sync across all devices via Supabase

### 🔔 Smart Alerts
Rule-based engine checks conditions every 5 seconds:
- Gate density > 80% → *"Try a less crowded entry"*
- Food zone density < 30% → *"Short queues at Food Court B"*
- Group member distance > 3 cells → *"Your group is spreading out"*
- Alerts are dismissable and stack in a horizontal feed on the dashboard

---

## 📐 Assumptions Made

| # | Assumption | Why |
|---|-----------|-----|
| 1 | Venue modelled as a fixed **10×8 grid** | Sufficient to demonstrate zone-level navigation without real blueprint data |
| 2 | Crowd density is **simulated locally** by default | Allows fully offline demo — no live event data required |
| 3 | Group members are **pre-populated as simulated friends** | Demonstrates group tracking without needing multiple physical devices |
| 4 | Walk speed = **1 grid cell per 30 seconds** | Conservative average for a crowded venue |
| 5 | Queue wait times are **derived from density**, not actual queue counts | Production would use turnstile counts or computer vision — density is a good proxy |
| 6 | User starts at the **venue entrance** (top-left gate zone) | Logical default for any first-time attendee |
| 7 | Supabase Realtime handles **all cross-device sync** | Simplest viable real-time architecture for a hackathon scope |

---

## 🛠️ Tech Stack

| Layer | Tech |
|-------|------|
| Mobile / Web Framework | Flutter 3.x (Dart) |
| State Management | Provider |
| Realtime Backend | Supabase (Postgres + Realtime) |
| Pathfinding | Custom Dijkstra (Dart) |
| Map Rendering | Flutter `CustomPainter` |
| Animations | `flutter_animate` |
| UI Design System | Glassmorphism (`BackdropFilter`) |
| Fonts | Google Fonts (Inter) |
| Deployment | Vercel |

---

## 🚀 Getting Started

```bash
# 1. Clone repo
git clone https://github.com/Subha2411/Promptwars.git
cd Promptwars/arena_iq

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (no setup needed — runs offline by default)
flutter run -d chrome
```

> **No API keys or Supabase setup required to run!**  
> The app boots in offline simulation mode automatically.

### Enable Live Sync (Optional)
Edit `lib/config/supabase_config.dart` with your Supabase project credentials.

### 🌐 Deploying to Vercel

You can deploy this Flutter Web app directly to Vercel by importing your repository and applying the following configuration:

*   **Framework Preset:** `Other`
*   **Root Directory:** `arena_iq`
*   **Build & Development Settings:**
    *   **Build Command:** `flutter/bin/flutter build web --release`
    *   **Install Command:** `if cd flutter; then git pull && cd .. ; else git clone https://github.com/flutter/flutter.git; fi && ls && flutter/bin/flutter doctor && flutter/bin/flutter clean && flutter/bin/flutter config --enable-web`
    *   **Output Directory:** `build/web`

---

## 📁 Project Structure

```
arena_iq/
├── lib/
│   ├── config/          # Supabase credentials
│   ├── models/          # VenueZone, GroupMember, SmartAlert, etc.
│   ├── providers/       # 5 core state providers
│   ├── screens/         # Home, Dashboard, Navigation, Queue, Group
│   ├── services/        # CrowdSimulator, Pathfinder, AlertEngine, Supabase
│   ├── utils/           # Constants, Extensions
│   └── widgets/         # GlassCard, Heatmap, RouteOverlay, AlertCard, etc.
└── vercel.json          # Vercel routing configuration
```

---

## 📸 Screenshots

| Home — Venue Select | Live Heatmap | Smart Navigation |
|---|---|---|
| Glassmorphic carousel of live events | 10×8 real-time crowd density grid | Cyan route overlay avoiding crowds |

---

*ArenaIQ — Navigate smarter. Wait less. Enjoy more.* 🏟️