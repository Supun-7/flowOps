# FlowOps ⚡

> A real-time event management platform built with Elixir, Phoenix LiveView, and PostgreSQL.

---

## Overview

FlowOps is a full-stack web application for creating and managing events in real time. Users can register, log in, and manage their events through a clean, responsive interface powered by Phoenix LiveView — no page reloads, no JavaScript frameworks.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Elixir |
| Framework | Phoenix Framework |
| Real-time UI | Phoenix LiveView |
| Database ORM | Ecto |
| Database | PostgreSQL |

---

## Features

- 🔐 Secure user authentication (register, log in, log out)
- 📅 Create, view, edit, and delete events
- ⚡ Real-time UI updates with Phoenix LiveView
- 🔒 Protected routes — only authenticated users can access events
- 🗂 Clean context-based architecture separating business logic from the web layer

---

## Getting Started

### Prerequisites

- Elixir 1.15+
- Phoenix 1.7+
- PostgreSQL

### Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/flowops.git
cd flowops

# Install dependencies
mix deps.get

# Create and migrate the database
mix ecto.setup

# Start the server
mix phx.server
```

Visit [`http://localhost:4000`](http://localhost:4000) in your browser.

---

## Project Structure

```
lib/
├── flowops/                  # Business logic layer
│   ├── events.ex             # Events context (CRUD operations)
│   └── events/
│       └── event.ex          # Event schema (maps to DB table)
└── flowops_web/              # Web layer
    ├── router.ex             # Routes and auth pipelines
    └── live/
        └── event_live/       # LiveView pages for events
            ├── index.ex      # Event list page
            ├── show.ex       # Single event page
            └── form.ex       # Create / edit form
```

---

## Status

🚧 Actively in development.

---

## Author

**Supun Dharmaratne**  
[GitHub](https://github.com/YOUR_USERNAME)
