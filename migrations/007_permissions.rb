Sequel.migration do
  change do
    create_table(:permissions) do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :channel_id, :channels
      Integer :rule
      index [:user_id,:channel_id], :unique => true
    end
  end
end
