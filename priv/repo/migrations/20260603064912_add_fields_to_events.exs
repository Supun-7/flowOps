defmodule Flowops.Repo.Migrations.AddFieldsToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :status, :string, default: "upcoming", null: false
      add :cover_image, :string
      add :map_link, :string
      add :capacity, :integer
    end
  end
end
