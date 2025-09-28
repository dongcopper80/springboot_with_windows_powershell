<#
.SYNOPSIS
  Scaffold Angular + AdminLTE + Firebase + i18n + STOMP + 3-level menu
#>

param(
    [string]$AppName = "adminlte-angular"
)

Write-Host ">>> Tạo dự án Angular $AppName" -ForegroundColor Cyan

# 1️⃣ Tạo project Angular với SCSS & Routing
ng new $AppName --routing --style=scss
if ($LASTEXITCODE -ne 0) { throw "Angular project creation failed." }

Set-Location $AppName

Write-Host ">>> Cài dependencies chính" -ForegroundColor Cyan
npm install admin-lte bootstrap @fortawesome/fontawesome-free `
            firebase @angular/fire `
            @ngx-translate/core @ngx-translate/http-loader `
            @stomp/stompjs sockjs-client --save

Write-Host ">>> Thêm AdminLTE vào angular.json" -ForegroundColor Cyan
# Chỉnh angular.json tự động (append styles/scripts)
$angularJson = Get-Content "angular.json" -Raw | ConvertFrom-Json
$styles = $angularJson.projects.$AppName.architect.build.options.styles
$scripts = $angularJson.projects.$AppName.architect.build.options.scripts

$styles += @(
  "node_modules/bootstrap/dist/css/bootstrap.min.css",
  "node_modules/admin-lte/dist/css/adminlte.min.css"
)
$scripts += @(
  "node_modules/jquery/dist/jquery.min.js",
  "node_modules/bootstrap/dist/js/bootstrap.bundle.min.js",
  "node_modules/admin-lte/dist/js/adminlte.min.js"
)
$angularJson.projects.$AppName.architect.build.options.styles = $styles
$angularJson.projects.$AppName.architect.build.options.scripts = $scripts
$angularJson | ConvertTo-Json -Depth 100 | Out-File "angular.json" -Encoding utf8

Write-Host ">>> Tạo thư mục layout & components cơ bản" -ForegroundColor Cyan
New-Item -ItemType Directory -Force "src/app/layout" | Out-Null
New-Item -ItemType Directory -Force "src/app/services" | Out-Null
New-Item -ItemType Directory -Force "src/app/i18n" | Out-Null

# 2️⃣ Tạo Sidebar component với menu 3 cấp
@'
import { Component } from '@angular/core';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html'
})
export class SidebarComponent {
  menu = [
    {
      label: 'Dashboard', icon: 'fa-tachometer-alt', route: '/dashboard'
    },
    {
      label: 'Management', icon: 'fa-cogs',
      children: [
        {
          label: 'Users',
          children: [
            { label: 'List', route: '/users' },
            { label: 'Roles', route: '/roles' }
          ]
        },
        {
          label: 'Settings',
          children: [
            { label: 'General', route: '/settings/general' },
            { label: 'Security', route: '/settings/security' }
          ]
        }
      ]
    }
  ];
}
'@ | Out-File "src/app/layout/sidebar.component.ts" -Encoding utf8

@'
<aside class="main-sidebar sidebar-dark-primary elevation-4">
  <div class="sidebar">
    <nav>
      <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" data-accordion="false">
        <li *ngFor="let lvl1 of menu" class="nav-item">
          <a class="nav-link">
            <i class="nav-icon fas" [ngClass]="lvl1.icon"></i>
            <p>
              {{ lvl1.label }}
              <i class="right fas fa-angle-left"></i>
            </p>
          </a>
          <ul class="nav nav-treeview" *ngIf="lvl1.children">
            <li *ngFor="let lvl2 of lvl1.children" class="nav-item">
              <a class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>{{ lvl2.label }} <i class="right fas fa-angle-left"></i></p>
              </a>
              <ul class="nav nav-treeview" *ngIf="lvl2.children">
                <li *ngFor="let lvl3 of lvl2.children" class="nav-item">
                  <a [routerLink]="lvl3.route" class="nav-link">
                    <i class="far fa-dot-circle nav-icon"></i>
                    <p>{{ lvl3.label }}</p>
                  </a>
                </li>
              </ul>
            </li>
          </ul>
        </li>
      </ul>
    </nav>
  </div>
</aside>
'@ | Out-File "src/app/layout/sidebar.component.html" -Encoding utf8

# 3️⃣ Tạo i18n ví dụ
New-Item -ItemType Directory -Force "src/assets/i18n" | Out-Null
@'{ "hello": "Hello World" }'@ | Out-File "src/assets/i18n/en.json" -Encoding utf8
@'{ "hello": "Xin chào" }'@  | Out-File "src/assets/i18n/vi.json" -Encoding utf8

Write-Host ">>> Hoàn tất scaffold." -ForegroundColor Green
Write-Host "Hãy mở src/environments/environment.ts và cấu hình Firebase."
Write-Host "Chạy 'ng serve' để khởi động ứng dụng." -ForegroundColor Yellow

Write-Host "==> Cài đặt Lint/Format (ESLint, Prettier, Stylelint, HTMLHint)..."
npm install --save-dev `
  eslint @angular-eslint/eslint-plugin @angular-eslint/eslint-plugin-template @angular-eslint/eslint-parser `
  prettier eslint-config-prettier eslint-plugin-prettier `
  stylelint stylelint-config-standard stylelint-config-prettier stylelint-order htmlhint

# Tạo file cấu hình
@"
{
  "singleQuote": true,
  "semi": true,
  "printWidth": 100
}
"@ | Out-File .prettierrc -Encoding UTF8

@"
{
  "extends": ["stylelint-config-standard", "stylelint-config-prettier"]
}
"@ | Out-File .stylelintrc.json -Encoding UTF8

@"
{
  "tagname-lowercase": true,
  "attr-lowercase": true,
  "id-unique": true
}
"@ | Out-File .htmlhintrc -Encoding UTF8

