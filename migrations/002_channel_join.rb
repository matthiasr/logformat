Sequel.migration do
  change do
    alter_table :channels do
      add_column :join, TrueClass, :default => false
    end
  end
end
