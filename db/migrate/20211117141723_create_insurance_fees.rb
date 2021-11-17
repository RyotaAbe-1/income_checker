class CreateInsuranceFees < ActiveRecord::Migration[5.2]
  def change
    create_table :insurance_fees do |t|
      t.float :standard_reward_bymonth
      t.float :first
      t.float :last

      t.timestamps
    end
  end
end
