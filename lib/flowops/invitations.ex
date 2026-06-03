defmodule Flowops.Invitations do
  import Ecto.Query
  alias Flowops.Repo
  alias Flowops.Events.Invitation
  alias Flowops.Events.CommitteeMember
  alias Flowops.Accounts

  @doc "Invite a user to an event by email"
  def invite_user(event, email, role, invited_by_user) do
    case Accounts.get_user_by_email(email) do
      nil ->
        {:error, :user_not_found}

      invited_user ->
        %Invitation{}
        |> Invitation.changeset(%{
          event_id: event.id,
          invited_user_id: invited_user.id,
          invited_by_user_id: invited_by_user.id,
          role: role,
          status: "pending"
        })
        |> Repo.insert()
    end
  end

  @doc "Get all invitations for an event"
  def list_invitations(event_id) do
    Invitation
    |> where([i], i.event_id == ^event_id)
    |> preload([:invited_user, :invited_by_user])
    |> Repo.all()
  end

  @doc "Get all pending invitations for a user"
  def list_pending_invitations(user_id) do
    Invitation
    |> where([i], i.invited_user_id == ^user_id and i.status == "pending")
    |> preload([:event, :invited_by_user])
    |> Repo.all()
  end

  @doc "Accept an invitation"
  def accept_invitation(invitation_id, user_id) do
    invitation = Repo.get!(Invitation, invitation_id)

    if invitation.invited_user_id == user_id do
      Repo.transaction(fn ->
        invitation
        |> Invitation.changeset(%{status: "accepted"})
        |> Repo.update!()

        %CommitteeMember{}
        |> CommitteeMember.changeset(%{
          event_id: invitation.event_id,
          user_id: user_id,
          role: invitation.role
        })
        |> Repo.insert!()
      end)
    else
      {:error, :unauthorized}
    end
  end

  @doc "Decline an invitation"
  def decline_invitation(invitation_id, user_id) do
    invitation = Repo.get!(Invitation, invitation_id)

    if invitation.invited_user_id == user_id do
      invitation
      |> Invitation.changeset(%{status: "declined"})
      |> Repo.update()
    else
      {:error, :unauthorized}
    end
  end

  @doc "Get all committee members for an event"
  def list_committee_members(event_id) do
    CommitteeMember
    |> where([m], m.event_id == ^event_id)
    |> preload([:user])
    |> Repo.all()
  end
end
