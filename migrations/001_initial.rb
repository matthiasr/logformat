Sequel.migration do
  change do
    create_table(:channels) do
      primary_key :id
      String :name, :unique => true
    end

    create_table(:messages) do
      primary_key :id
      foreign_key :channel_id, :channels
      DateTime :time, :default => Sequel::CURRENT_TIMESTAMP
      String :nick
      String :text, :text => true
    end
  end
end
