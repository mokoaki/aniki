module UsersHelper
  def sign_in(user)
    #ユーザ作成時、ログイン時に呼ばれる

    #ログイン毎にリメンバートークンは変える
    remember_token = User.new_remember_token

    #リメンバートークンをクッキーで持つ。画面遷移毎にこいつを使ってユーザ確認する
    cookies.permanent[:remember_token] = remember_token

    #暗号化したリメンバートークンをDBに保存
    #この値と、クッキーから入手したリメンバートークンを暗号化した値が一緒なら認証済みユーザ。実装はcurrent_user
    user.update_attribute(:remember_token, User.encrypt(remember_token))

    #@current_userへユーザ格納
    self.current_user = user
  end

  def signed_in?
    #current_userが有効かどうかでログイン済かどうか判断
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    #DB内の暗号化したリメンバートークンと、クッキーから入手したリメンバートークンを暗号化した値が一緒なら認証済みユーザ
    #2度目以降のアクセスはもちろん値を返すだけ　逆に言うと画面遷移時には最低1回はDBアクセスが発生する
    @current_user ||= User.find_by(remember_token: User.encrypt(cookies[:remember_token]))
  end
end
