require 'rails_helper'

describe User do
  context '必要メソッド' do
    before { @user = User.new }

    subject { @user }

    it { should respond_to(:login_id) }
    it { should respond_to(:password_digest) }
    it { should respond_to(:remember_token) }
    it { should respond_to(:admin) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
 end
end
