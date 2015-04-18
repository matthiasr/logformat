require 'bcrypt'

Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, :unique => true
      String :password_digest
    end
    # the special user representing not-logged-in users
    self[:users].insert(:id => 0, :name => 'anonymous', :password_digest => '*')
  end

  down do
    drop_table(:users)
  end
end
