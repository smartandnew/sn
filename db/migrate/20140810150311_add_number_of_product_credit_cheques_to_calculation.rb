class AddNumberOfProductCreditChequesToCalculation < ActiveRecord::Migration
  def change
    add_column :calculations, :number_of_product_credit_cheques_, :integer
  end
end
