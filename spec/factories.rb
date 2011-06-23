# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name   "zhihui li"
  user.email  "modus_li@163.com"
  user.password "password"
  user.password_confirmation "password"
end