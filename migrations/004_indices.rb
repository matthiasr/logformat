Sequel.migration do
  change do
    alter_table :messages do
      add_index :time
      add_index :nick
    end
    alter_table :channels do
      add_index :name, :unique => true
    end
  end
end
