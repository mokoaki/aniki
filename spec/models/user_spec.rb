require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  context 'methods' do
    it 'columns' do
      expect(user).to respond_to(:login_id)
      expect(user).to respond_to(:password_digest)
      expect(user).to respond_to(:remember_token)
      expect(user).to respond_to(:admin)
      expect(user).to respond_to(:created_at)
      expect(user).to respond_to(:updated_at)

      expect(user).to respond_to(:password)
      expect(user).to respond_to(:password_confirmation)
    end

    it 'class methods' do
      expect(User).to respond_to(:new_remember_token)
      expect(User).to respond_to(:encrypt)
    end
  end

  describe 'validation' do
    context 'login_id' do
      it 'nil invalid' do
        user.login_id = nil
        expect(user).to be_invalid
      end

      it 'null_character invalid' do
        user.login_id = ''
        expect(user).to be_invalid
      end

      it 'A invalid' do
        user.login_id = 'A'
        expect(user).to be_invalid
      end

      it 'AAAAA invalid' do
        user.login_id = 'AAAAA'
        expect(user).to be_invalid
      end

      it 'AAAAAA valid' do
        user.login_id = 'AAAAAA'
        expect(user).to be_valid
      end

      it 'A * 64 valid' do
        user.login_id = 'A' * 64
        expect(user).to be_valid
      end

      it 'A * 65 invalid' do
        user.login_id = 'A' * 65
        expect(user).to be_invalid
      end

      it 'uniqueness' do
        temp_user = user.clone
        temp_user.login_id = 'abcdefg'
        temp_user.save

        user.login_id = 'ABCDEFG'

        expect(user).to be_invalid
      end
    end

    context 'password' do
      it 'nil invalid' do
        temp_user.password              = nil
        temp_user.password_confirmation = nil
        expect(user).to be_invalid
      end

      it 'null_character invalid' do
        temp_user.password              = ''
        temp_user.password_confirmation = ''
        expect(user).to be_invalid
      end

      it 'A invalid' do
        temp_user.password              = 'A'
        temp_user.password_confirmation = 'A'
        expect(user).to be_invalid
      end

      it 'AAAAA invalid' do
        temp_user.password              = 'AAAAA'
        temp_user.password_confirmation = 'AAAAA'
        expect(user).to be_invalid
      end

      it 'AAAAAA valid' do
        temp_user.password              = 'AAAAAA'
        temp_user.password_confirmation = 'AAAAAA'
        expect(user).to be_valid
      end

      it 'password != password_confirmation invalid' do
        temp_user.password              = 'AAAAAA'
        temp_user.password_confirmation = 'BBBBBB'
        expect(user).to be_invalid
      end
    end

  describe 'event' do
    it 'before_save' do
      user.login_id = 'AAAAAA'
      user.save

      expect(user.login_id).to eq('aaaaaa')
    end

    it 'before_create' do
      temp_token = user.remember_token
      user.save

      expect(user.remember_token).not_to eq(temp_token)
    end
  end

  describe 'うんたらmethods' do
    pendind 'has_secure_password'
    a
  end

  describe 'class methods' do
    it 'new_remember_token' do
      test1 = User.new_remember_token
      test2 = User.new_remember_token

      expect(test1.size).to eq(64)
      expect(test1).to match(/\A[0-9a-f]+\z/)
      expect(test2.size).to eq(64)
      expect(test2).to match(/\A[0-9a-f]+\z/)
      expect(test1).not_to eq(test2)
    end

    it 'encrypt' do
      expect(User.encrypt('moko')).to eq(Digest::SHA2.hexdigest('moko'))
    end
  end
end
