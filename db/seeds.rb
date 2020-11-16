table_names = %w(
  users
)

table_names.each do |table_name|
  # 環境によってパスを変更する
  path = Rails.root.join("db/seeds/#{Rails.env}/#{table_name}.rb")

  # パスにファイルが存在しない場合はdevelopmentディレクトリを読み込む
  path = path.sub(Rails.env, "development") unless File.exist?(path)

  # ファイルを読み込む
  require path
end
