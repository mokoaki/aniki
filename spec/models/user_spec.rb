require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.build(:user) }

  context 'methods' do
    it 'columns' do
      expect(user).to respond_to(:login_id)
      expect(user).to respond_to(:password_digest)
      expect(user).to respond_to(:remember_token)
      expect(user).to respond_to(:admin?)
      expect(user).to respond_to(:created_at)
      expect(user).to respond_to(:updated_at)

      expect(user).to respond_to(:password)
      expect(user).to respond_to(:password_confirmation)
      expect(user).to respond_to(:password_confirmation=)
    end

    it 'class methods' do
      expect(User).to respond_to(:new_remember_token)
      expect(User).to respond_to(:encrypt)
    end
  end

  describe 'validation' do
    describe 'login_id' do
      it 'nil invalid' do
        user[:login_id] = nil
        expect(user).to be_invalid
      end

      it 'null_character invalid' do
        user[:login_id] = ''
        expect(user).to be_invalid
      end

      it 'A invalid' do
        user[:login_id] = 'A'
        expect(user).to be_invalid
      end

      it 'A * 3 invalid' do
        user[:login_id] = 'A' * 3
        expect(user).to be_invalid
      end

      it 'space * 4 invalid' do
        user[:login_id] = ' ' * 4
        expect(user).to be_invalid
      end

      it 'A * 4 valid' do
        user[:login_id] = 'A' * 4
        expect(user).to be_valid
      end

      it 'A * 64 valid' do
        user[:login_id] = 'A' * 64
        expect(user).to be_valid
      end

      it 'A * 65 invalid' do
        user[:login_id] = 'A' * 65
        expect(user).to be_invalid
      end

      it 'uniqueness' do
        user[:login_id] = 'AAAAAA'
        user.save
        test_user = FactoryGirl.build(:user, login_id: 'aaaaaa')

        expect(test_user).to be_invalid
      end
    end

    describe 'password' do
      it 'nil invalid' do
        user.password              = nil
        user.password_confirmation = nil
        expect(user).to be_invalid
      end

      it 'null_character invalid' do
        user.password              = ''
        user.password_confirmation = ''
        expect(user).to be_invalid
      end

      it 'A invalid' do
        user.password              = 'A'
        user.password_confirmation = 'A'
        expect(user).to be_invalid
      end

      it 'A * 5 invalid' do
        user.password              = 'A' * 5
        user.password_confirmation = 'A' * 5
        expect(user).to be_invalid
      end

      it 'space * 6 invalid' do
        user.password              = ' ' * 6
        user.password_confirmation = ' ' * 6
        expect(user).to be_invalid
      end

      it 'A * 6 valid' do
        user.password              = 'A' * 6
        user.password_confirmation = 'A' * 6
        expect(user).to be_valid
      end

      it 'password != password_confirmation invalid' do
        user.password              = 'AAAAAA'
        user.password_confirmation = 'BBBBBB'
        expect(user).to be_invalid
      end
    end

    describe 'event' do
      it 'before_save' do
        user[:login_id] = 'AAAAAA'
        user.save

        expect(user[:login_id]).to eq('aaaaaa')
      end

      it 'before_create' do
        temp_token = user.remember_token
        user.save

        expect(user.remember_token).not_to eq(temp_token)
      end
    end
  end

  describe 'has_secure_password' do
    it 'has_secure_password' do
      user = FactoryGirl.build(:user, { password: nil })
      expect(user.password_digest).to be_nil
      user.password = 'a'
      expect(user.password_digest).not_to be_nil
    end
  end

  describe 'class methods' do
    describe 'new_remember_token' do
      let(:test1) { User.new_remember_token }
      let(:test2) { User.new_remember_token }

      it 'value check' do
        expect(test1.size).to eq(22)
        expect(test1).to match(/\A[\w-]+\z/)
        expect(test2.size).to eq(22)
        expect(test2).to match(/\A[\w-]+\z/)
      end

      it 'different value' do
        expect(test1).not_to eq(test2)
      end
    end

    it 'encrypt' do
      expect(User.encrypt('moko')).to     eq(Digest::SHA2.hexdigest('moko'))
      expect(User.encrypt('moko')).not_to eq(Digest::SHA2.hexdigest('mokoaki'))
    end
  end
end
