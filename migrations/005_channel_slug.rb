Sequel.migration do
  transaction
  up do
    alter_table(:channels) do
      add_column :slug, String
    end
    self[:channels].all.each do |c|
      self[:channels].filter(:id => c[:id]).update(:slug => c[:name][1..-1])
    end
    alter_table(:channels) do
      add_index :slug, :unique => true
    end
  end
  down do
    alter_table(:channels) do
      drop_column :slug
    end
  end
end
