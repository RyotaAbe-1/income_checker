class CreateInsuranceFees < ActiveRecord::Migration[5.2]
  def change
    create_table :insurance_fees do |t|
      t.integer :standard_reward_bymonth
      t.integer :first_range
      t.integer :last_range
      
      t.timestamps
    end
  end
end
