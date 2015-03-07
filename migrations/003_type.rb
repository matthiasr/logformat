Sequel.migration do
  change do
    alter_table(:messages) do
      add_column :type, String
    end
  end
end
