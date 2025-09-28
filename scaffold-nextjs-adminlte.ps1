<#
.SYNOPSIS
  Scaffold Next.js + React + AdminLTE + Firebase + i18n + STOMP + 3-level menu
#>

param(
    [string]$AppName = "nextjs-adminlte"
)

Write-Host ">>> Tạo dự án Next.js $AppName" -ForegroundColor Cyan
npx create-next-app@latest $AppName --typescript --eslint --app
if ($LASTEXITCODE -ne 0) { throw "Next.js project creation failed." }

Set-Location $AppName

Write-Host ">>> Cài dependencies chính" -ForegroundColor Cyan
npm install admin-lte bootstrap @fortawesome/fontawesome-free \
            firebase \
            next-i18next react-i18next i18next \
            @stomp/stompjs sockjs-client \
            axios

Write-Host ">>> Cấu hình AdminLTE trong next.config.mjs và _app.tsx" -ForegroundColor Cyan
# Thêm SCSS global
@'
import "bootstrap/dist/css/bootstrap.min.css";
import "admin-lte/dist/css/adminlte.min.css";
import "@fortawesome/fontawesome-free/css/all.min.css";
import "../styles/globals.css";
import type { AppProps } from "next/app";

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
'@ | Out-File "pages/_app.tsx" -Encoding utf8 -Force

Write-Host ">>> Tạo thư mục layout & components" -ForegroundColor Cyan
New-Item -ItemType Directory -Force "components/layout" | Out-Null
New-Item -ItemType Directory -Force "components/menu" | Out-Null
New-Item -ItemType Directory -Force "services" | Out-Null
New-Item -ItemType Directory -Force "locales/en" | Out-Null
New-Item -ItemType Directory -Force "locales/vi" | Out-Null

# 1️⃣ i18n config
@'
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import en from "./locales/en/common.json";
import vi from "./locales/vi/common.json";

i18n.use(initReactI18next).init({
  resources: { en: { translation: en }, vi: { translation: vi } },
  lng: "en",
  fallbackLng: "en",
  interpolation: { escapeValue: false },
});
export default i18n;
'@ | Out-File "i18n.ts" -Encoding utf8

@'{ "hello": "Hello World" }'@ | Out-File "locales/en/common.json" -Encoding utf8
@'{ "hello": "Xin chào" }'@  | Out-File "locales/vi/common.json" -Encoding utf8

# 2️⃣ Sidebar 3-level component
@'
import Link from "next/link";

const menu = [
  { label: "Dashboard", icon: "fa-tachometer-alt", route: "/" },
  {
    label: "Management", icon: "fa-cogs",
    children: [
      {
        label: "Users",
        children: [
          { label: "List", route: "/users" },
          { label: "Roles", route: "/roles" }
        ]
      },
      {
        label: "Settings",
        children: [
          { label: "General", route: "/settings/general" },
          { label: "Security", route: "/settings/security" }
        ]
      }
    ]
  }
];

export default function Sidebar() {
  return (
    <aside className="main-sidebar sidebar-dark-primary elevation-4">
      <div className="sidebar">
        <nav>
          <ul className="nav nav-pills nav-sidebar flex-column" data-widget="treeview" data-accordion="false">
            {menu.map((lvl1,i)=>(
              <li key={i} className="nav-item">
                <a className="nav-link">
                  <i className={`nav-icon fas ${lvl1.icon}`}></i>
                  <p>{lvl1.label}{lvl1.children && <i className="right fas fa-angle-left"></i>}</p>
                </a>
                {lvl1.children &&
                  <ul className="nav nav-treeview">
                    {lvl1.children.map((lvl2,j)=>(
                      <li key={j} className="nav-item">
                        <a className="nav-link">
                          <i className="far fa-circle nav-icon"></i>
                          <p>{lvl2.label}<i className="right fas fa-angle-left"></i></p>
                        </a>
                        {lvl2.children &&
                          <ul className="nav nav-treeview">
                            {lvl2.children.map((lvl3,k)=>(
                              <li key={k} className="nav-item">
                                <Link href={lvl3.route} className="nav-link">
                                  <i className="far fa-dot-circle nav-icon"></i>
                                  <p>{lvl3.label}</p>
                                </Link>
                              </li>
                            ))}
                          </ul>
                        }
                      </li>
                    ))}
                  </ul>
                }
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </aside>
  );
}
'@ | Out-File "components/layout/Sidebar.tsx" -Encoding utf8

# 3️⃣ Firebase service placeholder
@'
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, GithubAuthProvider, signInWithPopup, signInWithEmailAndPassword } from "firebase/auth";

const firebaseConfig = {
  apiKey: "YOUR_KEY",
  authDomain: "YOUR_DOMAIN",
  projectId: "YOUR_PROJECT",
  appId: "YOUR_APP_ID",
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);

export const loginGoogle = () => signInWithPopup(auth, new GoogleAuthProvider());
export const loginGitHub = () => signInWithPopup(auth, new GithubAuthProvider());
export const loginEmail = (email:string, pass:string) => signInWithEmailAndPassword(auth, email, pass);
'@ | Out-File "services/firebase.ts" -Encoding utf8

# 4️⃣ STOMP Service
@'
import { Client } from "@stomp/stompjs";
import SockJS from "sockjs-client";

export function createStompClient(url: string) {
  const client = new Client({
    webSocketFactory: () => new SockJS(url),
    debug: str => console.log(str)
  });
  client.activate();
  return client;
}
'@ | Out-File "services/stomp.ts" -Encoding utf8

Write-Host ">>> Scaffold hoàn tất." -ForegroundColor Green
Write-Host "Hãy cập nhật Firebase config trong services/firebase.ts" -ForegroundColor Yellow
Write-Host "Chạy 'npm run dev' để khởi động ứng dụng." -ForegroundColor Cyan

Write-Host "==> Cài đặt Lint/Format (ESLint, Prettier, Stylelint, HTMLHint)..."
npm install --save-dev `
  eslint eslint-config-next prettier eslint-config-prettier eslint-plugin-prettier `
  stylelint stylelint-config-standard stylelint-config-prettier stylelint-order htmlhint

@"
{
  "root": true,
  "extends": ["next/core-web-vitals", "plugin:prettier/recommended"]
}
"@ | Out-File .eslintrc.json -Encoding UTF8

@"
{
  "singleQuote": true,
  "semi": true,
  "trailingComma": "es5",
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

Write-Host "==> Hoàn tất cấu hình Lint/Format cho Next.js"

