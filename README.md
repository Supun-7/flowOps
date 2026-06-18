<div align="center">
  <h1>⚡ FlowOps</h1>
  <p><strong>A Real-Time Event Management Platform</strong></p>
  
  [![Elixir](https://img.shields.io/badge/Elixir-1.15+-4B275F?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/)
  [![Phoenix](https://img.shields.io/badge/Phoenix-1.8.7-FD4F00?style=for-the-badge&logo=phoenix&logoColor=white)](https://www.phoenixframework.org/)
  [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
  [![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
</div>

<br />

> **FlowOps** is a modern, full-stack web application designed for creating, managing, and experiencing events in real time. Built on the rock-solid foundation of Elixir and Phoenix, it delivers a blazing-fast, interactive user interface without the overhead of heavy JavaScript frameworks.

---

## ✨ Features

- **🛡️ Secure Authentication** — Robust user registration, login, and session management.
- **📅 Comprehensive Event Management** — Create, view, edit, and delete events seamlessly.
- **⚡ Real-Time Interactivity** — Powered by Phoenix LiveView for instant UI updates and a native-like feel.
- **🔒 Protected Routes** — Strict access controls ensuring only authenticated users can manage their events.
- **🏛️ Clean Architecture** — Context-based domain design separating business logic from the web presentation layer.
- **💅 Beautiful UI** — Styled with Tailwind CSS for a responsive, modern, and accessible design.

## 🛠️ Technology Stack

| Layer | Technology | Description |
| :--- | :--- | :--- |
| **Language** | [Elixir](https://elixir-lang.org/) | A dynamic, functional language for scalable and maintainable applications. |
| **Framework** | [Phoenix](https://www.phoenixframework.org/) | A productive web framework that does not compromise speed or maintainability. |
| **Interactive UI** | [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) | Rich, real-time user experiences with server-rendered HTML. |
| **Database** | [PostgreSQL](https://www.postgresql.org/) | The world's most advanced open source relational database. |
| **ORM / Query** | [Ecto](https://hexdocs.pm/ecto/Ecto.html) | A toolkit for data mapping and language integrated query. |
| **Styling** | [Tailwind CSS](https://tailwindcss.com/) | A utility-first CSS framework for rapid UI development. |

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the following installed on your system:
- **Elixir** (v1.15 or higher)
- **Erlang/OTP** (compatible with your Elixir version)
- **PostgreSQL** (running locally)

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/supun7buddhima/flowops.git
   cd flowops
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   ```

3. **Database Setup**
   Create and migrate your database. (This will also run `priv/repo/seeds.exs` if available to populate demo data).
   ```bash
   mix ecto.setup
   ```

4. **Start the Phoenix server**
   ```bash
   mix phx.server
   ```

5. **Ready to go!** 🎈
   Visit [`http://localhost:4000`](http://localhost:4000) from your browser to see FlowOps in action.

## 📂 Project Structure

A quick overview of the core project structure:

```text
lib/
├── flowops/                  # 🧠 Core Business Logic Layer
│   ├── events.ex             # Events context (CRUD operations)
│   ├── accounts.ex           # Accounts context (Users, Auth)
│   └── ...
└── flowops_web/              # 🌐 Web Presentation Layer
    ├── router.ex             # Application routes and pipelines
    ├── controllers/          # Standard HTTP controllers
    ├── live/                 # Phoenix LiveView modules
    └── components/           # Reusable UI components (CoreComponents)
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
Feel free to check the [issues page](https://github.com/supun7buddhima/flowops/issues) if you want to contribute.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👨‍💻 Author

**Supun Dharmaratne**
- GitHub: [@supun7buddhima](https://github.com/supun7buddhima)

---

<div align="center">
  <i>Built with ❤️ using Elixir and Phoenix.</i>
</div>
