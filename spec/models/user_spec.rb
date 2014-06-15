require 'spec_helper'

describe User do
  before do
    @user = User.create(login_id: "moko")
  end

  let(:user) { User.find_by(login_id: 'moko') }

  expect(user).to respond_to(:login_id)
end
