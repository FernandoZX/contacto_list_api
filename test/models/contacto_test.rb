# == Schema Information
#
# Table name: contactos
#
#  id            :integer          not null, primary key
#  name          :string
#  phone         :string
#  email         :string
#  birthday_date :datetime
#  age           :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class ContactoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
