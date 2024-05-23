# frozen_string_literal: true

class Mutations::UserMutation < Mutations::BaseMutation
  argument :id, ID, required: true, description: "User primary id"
  argument :email, String, required: false, description: "User email"

  type ::Types::UserType

  def resolve(id:, email: nil)
    @user = User.find(id)
    authorize! :show, @user
    @user
  end
end
