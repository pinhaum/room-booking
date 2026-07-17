class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms, comment: "Salas disponíveis para reserva" do |t|
      t.string :name, null: false, comment: "Nome único da sala"
      t.integer :capacity, null: false, comment: "Capacidade máxima de pessoas"
      t.text :description, comment: "Descrição opcional da sala"
      t.boolean :available, null: false, default: true, comment: "Indica se a sala pode ser reservada"

      t.timestamps
    end

    add_index :rooms, :name, unique: true
  end
end
