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
# :no-doc:
class Contacto < ApplicationRecord
  before_save :calculate_age_birthday
  validates :name, presence: true
  validates :name, length: { maximum: 200 }
  validates :name, format: {
    with: /\A\b[a-zA-Z0-9_ ]+\b\z/i, on: :create
  }
  validates :phone, presence: true
  validates :phone, length: { maximum: 10 }
  validates :phone, format: {
    with: /^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/, on: :create
  }
  validates :email,
            format: {
              with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
              allow_blank: true,
              allow_nil: true
            }

  private

  def calculate_age_birthday
    return if birthday_date
  end
end
