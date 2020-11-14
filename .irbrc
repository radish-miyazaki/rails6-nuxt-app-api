# コンソール起動時
if defined? Rails::Console
  # Hirb.enabledの有効化
  Hirb.enable if defined? Hirb
end
