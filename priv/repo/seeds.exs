alias Flowops.Accounts
alias Flowops.Accounts.User
alias Flowops.Events.Event
alias Flowops.Events.CommitteeMember
alias Flowops.Events.Invitation
alias Flowops.Events.Task, as: EventTask
alias Flowops.Repo

import Ecto.Changeset

# ──────────────────────────────────────────────
# 1. DEMO USERS
# ──────────────────────────────────────────────

demo_password = "Demo@2024Secure!"

users_data = [
  %{email: "admin@gmail.com", is_admin: true},
  %{email: "sarah@flowops.com", is_admin: false},
  %{email: "james@flowops.com", is_admin: false},
  %{email: "priya@flowops.com", is_admin: false},
  %{email: "mike@flowops.com", is_admin: false}
]

users =
  Enum.map(users_data, fn data ->
    case Accounts.get_user_by_email(data.email) do
      nil ->
        {:ok, user} =
          %User{}
          |> User.email_changeset(%{email: data.email})
          |> User.password_changeset(%{password: demo_password})
          |> put_change(:is_admin, data.is_admin)
          |> put_change(:confirmed_at, DateTime.utc_now(:second))
          |> Repo.insert()

        IO.puts("✅ Created user: #{data.email}#{if data.is_admin, do: " (admin)", else: ""}")
        user

      user ->
        user
        |> change(%{is_admin: data.is_admin})
        |> Repo.update!()

        IO.puts("ℹ️  User already exists: #{data.email}, updated admin flag")
        Repo.get_by!(User, email: data.email)
    end
  end)

[admin, sarah, james, priya, mike] = users

# ──────────────────────────────────────────────
# 2. DEMO EVENTS (owned by admin)
# ──────────────────────────────────────────────

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

events_data = [
  %{
    title: "TechFusion 2026 — Annual Tech Conference",
    description: "A premier technology conference featuring keynote speakers, workshops, and networking sessions covering AI, cloud computing, and modern web development.",
    location: "Lotus Hall, BMICH, Colombo 07",
    start_time: NaiveDateTime.add(now, 3 * 24 * 3600, :second),
    end_time: NaiveDateTime.add(now, 3 * 24 * 3600 + 8 * 3600, :second),
    status: "upcoming",
    capacity: 500,
    map_link: "https://maps.google.com/?q=BMICH+Colombo"
  },
  %{
    title: "Startup Pitch Night — June Edition",
    description: "Monthly startup pitch event where 10 selected startups present their ideas to a panel of investors and industry mentors. Live Q&A and networking to follow.",
    location: "Trace Expert City, Maradana",
    start_time: NaiveDateTime.add(now, -1 * 3600, :second),
    end_time: NaiveDateTime.add(now, 3 * 3600, :second),
    status: "live",
    capacity: 150,
    map_link: "https://maps.google.com/?q=Trace+Expert+City+Colombo"
  },
  %{
    title: "Design Thinking Workshop",
    description: "An interactive half-day workshop on design thinking methodologies. Participants learned to apply human-centered design to solve real-world problems.",
    location: "Hilton Colombo, Lotus Ballroom",
    start_time: NaiveDateTime.add(now, -7 * 24 * 3600, :second),
    end_time: NaiveDateTime.add(now, -7 * 24 * 3600 + 4 * 3600, :second),
    status: "ended",
    capacity: 80,
    map_link: "https://maps.google.com/?q=Hilton+Colombo"
  },
  %{
    title: "Community Hackathon — Build for Good",
    description: "A 24-hour hackathon focused on building technology solutions for social good. Teams compete to create impactful projects addressing community challenges.",
    location: "University of Moratuwa, IT Faculty",
    start_time: NaiveDateTime.add(now, 10 * 24 * 3600, :second),
    end_time: NaiveDateTime.add(now, 11 * 24 * 3600, :second),
    status: "upcoming",
    capacity: 200,
    map_link: "https://maps.google.com/?q=University+of+Moratuwa"
  },
  %{
    title: "Women in Tech Meetup",
    description: "A networking and knowledge-sharing event celebrating women in technology. Features panel discussions, lightning talks, and mentorship speed dating.",
    location: "Cinnamon Grand, Colombo",
    start_time: NaiveDateTime.add(now, -3 * 24 * 3600, :second),
    end_time: NaiveDateTime.add(now, -3 * 24 * 3600 + 3 * 3600, :second),
    status: "ended",
    capacity: 120,
    map_link: "https://maps.google.com/?q=Cinnamon+Grand+Colombo"
  }
]

events =
  Enum.map(events_data, fn data ->
    case Repo.get_by(Event, title: data.title, user_id: admin.id) do
      nil ->
        {:ok, event} =
          %Event{}
          |> Event.changeset(data, %{user: admin})
          |> Repo.insert()

        IO.puts("✅ Created event: #{data.title}")
        event

      event ->
        IO.puts("ℹ️  Event already exists: #{data.title}")
        event
    end
  end)

[tech_conf, pitch_night, design_workshop, hackathon, women_tech] = events

# ──────────────────────────────────────────────
# 3. COMMITTEE MEMBERS
# ──────────────────────────────────────────────

committee_data = [
  # TechFusion 2026
  %{event: tech_conf, user: sarah, role: "Stage Manager", attendance: "absent", work: "available"},
  %{event: tech_conf, user: james, role: "Registration Lead", attendance: "absent", work: "available"},
  %{event: tech_conf, user: priya, role: "Logistics Coordinator", attendance: "absent", work: "available"},
  %{event: tech_conf, user: mike, role: "AV Technician", attendance: "absent", work: "available"},

  # Startup Pitch Night (live — some present)
  %{event: pitch_night, user: sarah, role: "MC / Host", attendance: "present", work: "busy"},
  %{event: pitch_night, user: james, role: "Timer Keeper", attendance: "present", work: "available"},
  %{event: pitch_night, user: priya, role: "Guest Liaison", attendance: "present", work: "busy"},

  # Design Workshop (ended)
  %{event: design_workshop, user: sarah, role: "Facilitator", attendance: "left", work: "available"},
  %{event: design_workshop, user: mike, role: "Materials Coordinator", attendance: "left", work: "available"},

  # Hackathon
  %{event: hackathon, user: james, role: "Mentor Coordinator", attendance: "absent", work: "available"},
  %{event: hackathon, user: priya, role: "Judging Panel Lead", attendance: "absent", work: "available"},
  %{event: hackathon, user: mike, role: "Infrastructure Lead", attendance: "absent", work: "available"},

  # Women in Tech (ended)
  %{event: women_tech, user: sarah, role: "Panel Moderator", attendance: "left", work: "available"},
  %{event: women_tech, user: priya, role: "Speaker Coordinator", attendance: "left", work: "available"}
]

now_dt = DateTime.utc_now() |> DateTime.truncate(:second)

Enum.each(committee_data, fn data ->
  case Repo.get_by(CommitteeMember, event_id: data.event.id, user_id: data.user.id) do
    nil ->
      joined_at = if data.attendance in ["present", "left"], do: DateTime.add(now_dt, -2 * 3600, :second)
      left_at = if data.attendance == "left", do: DateTime.add(now_dt, -1 * 3600, :second)

      %CommitteeMember{}
      |> CommitteeMember.changeset(%{
        event_id: data.event.id,
        user_id: data.user.id,
        role: data.role,
        attendance_status: data.attendance,
        work_status: data.work,
        joined_at: joined_at,
        left_at: left_at
      })
      |> Repo.insert!()

      IO.puts("✅ Added committee: #{data.user.email} → #{data.event.title} (#{data.role})")

    _existing ->
      IO.puts("ℹ️  Committee member already exists: #{data.user.email} → #{data.event.title}")
  end
end)

# ──────────────────────────────────────────────
# 4. INVITATIONS (pending ones for demo)
# ──────────────────────────────────────────────

invitation_data = [
  # Mike is invited to Pitch Night but hasn't responded yet
  %{event: pitch_night, invited: mike, invited_by: admin, role: "Sound Engineer", status: "pending"},

  # Pending invitations for Hackathon
  %{event: hackathon, invited: sarah, invited_by: admin, role: "Workshop Facilitator", status: "pending"},

  # Some accepted invitations (matching committee members above)
  %{event: tech_conf, invited: sarah, invited_by: admin, role: "Stage Manager", status: "accepted"},
  %{event: tech_conf, invited: james, invited_by: admin, role: "Registration Lead", status: "accepted"},
  %{event: tech_conf, invited: priya, invited_by: admin, role: "Logistics Coordinator", status: "accepted"},
  %{event: tech_conf, invited: mike, invited_by: admin, role: "AV Technician", status: "accepted"},

  # A declined invitation
  %{event: women_tech, invited: mike, invited_by: admin, role: "Photographer", status: "declined"},
  %{event: women_tech, invited: james, invited_by: admin, role: "Registration", status: "declined"}
]

Enum.each(invitation_data, fn data ->
  case Repo.get_by(Invitation, event_id: data.event.id, invited_user_id: data.invited.id) do
    nil ->
      %Invitation{}
      |> Invitation.changeset(%{
        event_id: data.event.id,
        invited_user_id: data.invited.id,
        invited_by_user_id: data.invited_by.id,
        role: data.role,
        status: data.status
      })
      |> Repo.insert!()

      IO.puts("✅ Created invitation: #{data.invited.email} → #{data.event.title} (#{data.status})")

    _existing ->
      IO.puts("ℹ️  Invitation already exists: #{data.invited.email} → #{data.event.title}")
  end
end)

# ──────────────────────────────────────────────
# 5. TASKS
# ──────────────────────────────────────────────

tasks_data = [
  # TechFusion 2026 tasks
  %{event: tech_conf, title: "Book keynote speaker flights", assigned_to: sarah, created_by: admin, status: "done"},
  %{event: tech_conf, title: "Set up registration portal", assigned_to: james, created_by: admin, status: "in_progress"},
  %{event: tech_conf, title: "Order event merchandise (T-shirts, lanyards)", assigned_to: priya, created_by: admin, status: "pending"},
  %{event: tech_conf, title: "Test AV equipment and projectors", assigned_to: mike, created_by: admin, status: "pending"},
  %{event: tech_conf, title: "Prepare speaker welcome kits", assigned_to: sarah, created_by: admin, status: "pending"},
  %{event: tech_conf, title: "Confirm catering menu and headcount", assigned_to: priya, created_by: admin, status: "in_progress"},

  # Startup Pitch Night tasks (live event — some done)
  %{event: pitch_night, title: "Print scorecards for judges", assigned_to: sarah, created_by: admin, status: "done"},
  %{event: pitch_night, title: "Set up live-stream on YouTube", assigned_to: james, created_by: admin, status: "done"},
  %{event: pitch_night, title: "Distribute welcome packets to investors", assigned_to: priya, created_by: admin, status: "in_progress"},
  %{event: pitch_night, title: "Coordinate post-event networking drinks", assigned_to: priya, created_by: admin, status: "pending"},

  # Design Workshop tasks (ended — all done)
  %{event: design_workshop, title: "Prepare sticky notes and materials", assigned_to: mike, created_by: admin, status: "done"},
  %{event: design_workshop, title: "Print participant workbooks", assigned_to: sarah, created_by: admin, status: "done"},
  %{event: design_workshop, title: "Collect participant feedback forms", assigned_to: sarah, created_by: admin, status: "done"},

  # Hackathon tasks
  %{event: hackathon, title: "Set up WiFi and power stations", assigned_to: mike, created_by: admin, status: "pending"},
  %{event: hackathon, title: "Recruit 10 industry mentors", assigned_to: james, created_by: admin, status: "in_progress"},
  %{event: hackathon, title: "Prepare judging criteria document", assigned_to: priya, created_by: admin, status: "pending"},
  %{event: hackathon, title: "Arrange overnight food and beverages", assigned_to: nil, created_by: admin, status: "pending"},

  # Women in Tech tasks (ended)
  %{event: women_tech, title: "Confirm panel speakers", assigned_to: sarah, created_by: admin, status: "done"},
  %{event: women_tech, title: "Arrange mentorship pairing sheets", assigned_to: priya, created_by: admin, status: "done"}
]

Enum.each(tasks_data, fn data ->
  attrs = %{
    event_id: data.event.id,
    title: data.title,
    created_by_user_id: data.created_by.id,
    status: data.status
  }

  attrs =
    if data.assigned_to do
      Map.put(attrs, :assigned_to_user_id, data.assigned_to.id)
    else
      attrs
    end

  # Check if task already exists by title + event
  existing = Repo.get_by(EventTask, event_id: data.event.id, title: data.title)

  case existing do
    nil ->
      %EventTask{}
      |> EventTask.changeset(attrs)
      |> Repo.insert!()

      IO.puts("✅ Created task: #{data.title}")

    _existing ->
      IO.puts("ℹ️  Task already exists: #{data.title}")
  end
end)

IO.puts("")
IO.puts("═══════════════════════════════════════════════════")
IO.puts("  🎉 Demo data seeded successfully!")
IO.puts("═══════════════════════════════════════════════════")
IO.puts("")
IO.puts("  Demo Credentials (all use same password):")
IO.puts("  Password: #{demo_password}")
IO.puts("")
IO.puts("  👑 admin@gmail.com      — Admin (event organizer)")
IO.puts("  👤 sarah@flowops.com    — Committee member")
IO.puts("  👤 james@flowops.com    — Committee member")
IO.puts("  👤 priya@flowops.com    — Committee member")
IO.puts("  👤 mike@flowops.com     — Committee member")
IO.puts("")
IO.puts("═══════════════════════════════════════════════════")
