# Test RU user
ru_user = User.new(name: 'RU User', telegram_id: rand(1000000..9999999), base_currency: 'RUB', language_code: 'ru')
if ru_user.save
  puts "✅ RU User: #{ru_user.categories.count} categories"
  puts "   Categories: #{ru_user.categories.pluck(:name).join(', ')}"
  ru_user.destroy
end

# Test EN user
en_user = User.new(name: 'EN User', telegram_id: rand(1000000..9999999), base_currency: 'USD', language_code: 'en')
if en_user.save
  puts "✅ EN User: #{en_user.categories.count} categories"
  puts "   Categories: #{en_user.categories.pluck(:name).join(', ')}"
  en_user.destroy
end
