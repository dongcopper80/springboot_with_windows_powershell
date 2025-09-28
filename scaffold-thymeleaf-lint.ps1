Write-Host "==> Thêm Lint/Format cho Spring Boot + Thymeleaf"
npm init -y
npm install --save-dev `
  eslint prettier eslint-config-prettier eslint-plugin-prettier `
  stylelint stylelint-config-standard stylelint-config-prettier stylelint-order `
  htmlhint

@"
{
  "env": { "browser": true, "es2021": true },
  "extends": ["eslint:recommended", "plugin:prettier/recommended"]
}
"@ | Out-File .eslintrc.json -Encoding UTF8

@"
{
  "singleQuote": true,
  "semi": true,
  "printWidth": 100
}
"@ | Out-File .prettierrc -Encoding UTF8

@"
{
  "extends": ["stylelint-config-standard", "stylelint-config-prettier"],
  "plugins": ["stylelint-order"]
}
"@ | Out-File .stylelintrc.json -Encoding UTF8

@"
{
  "tagname-lowercase": false,
  "attr-lowercase": false,
  "attr-value-double-quotes": true,
  "id-unique": true
}
"@ | Out-File .htmlhintrc -Encoding UTF8

Write-Host "==> Hoàn tất cấu hình Lint/Format cho dự án Thymeleaf"
