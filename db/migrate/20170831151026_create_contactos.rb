class CreateContactos < ActiveRecord::Migration[5.0]
  def change
    create_table :contactos do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.datetime :birthday_date
      t.integer :age

      t.timestamps
    end
  end
end
