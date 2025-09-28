<#
PowerShell script: scaffold-vue-adminlte.ps1
Creates a Vue 3 + Vite project prewired with:
 - AdminLTE template (CSS/JS via npm)
 - Vue Router + Pinia
 - Vue I18n
 - Firebase Auth (Google, GitHub, Email/Password)
 - STOMP with @stomp/stompjs (and sockjs-client fallback)
 - Basic layout components: Header, Menubar (3-level), Footer, LeftSidebar, RightSidebar, CenterContent
 - Sample Login page supporting multi-type auth

Usage: Run in an empty directory or specify -ProjectName.
Example: .\scaffold-vue-adminlte.ps1 -ProjectName car-admin
#>

param(
    [string]$ProjectName = "vue-adminlte-app",
    [string]$PackageManager = "npm"  # or 'yarn'
)

function Write-File($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $content | Out-File -FilePath $path -Encoding UTF8 -Force
}

Write-Host "Scaffolding project: $ProjectName (package manager: $PackageManager)" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $ProjectName | Out-Null
Set-Location $ProjectName

if ($PackageManager -eq 'yarn') {
    yarn create vite . --template vue
} else {
    npm create vite@latest . -- --template vue
}

$deps = @(
    'vue-router@4','pinia','vue-i18n@9','firebase','@stomp/stompjs','sockjs-client','axios','admin-lte','bootstrap','jquery','popper.js'
)
if ($PackageManager -eq 'yarn') {
    yarn add $deps
    yarn add -D eslint prettier
} else {
    npm install --save $deps
    npm install --save-dev eslint prettier
}

$envContent = @"
VITE_FIREBASE_API_KEY=REPLACE_ME
VITE_FIREBASE_AUTH_DOMAIN=REPLACE_ME
VITE_FIREBASE_PROJECT_ID=REPLACE_ME
VITE_FIREBASE_APP_ID=REPLACE_ME
"@
Write-File ".env.local" $envContent

$mainJs = @"
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import i18n from './i18n'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'admin-lte/dist/css/adminlte.min.css'
import 'admin-lte/dist/js/adminlte.min.js'
import 'jquery'
const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(i18n)
app.mount('#app')
"@
Write-File "src/main.js" $mainJs

$appVue = @"<template>
  <router-view />
</template>
<script setup>
</script>
<style>
html,body,#app { height:100%; }
</style>
"@
Write-File "src/App.vue" $appVue

$router = @"
import { createRouter, createWebHistory } from 'vue-router'
import Login from '@/views/Login.vue'
import Dashboard from '@/views/Dashboard.vue'
import MainLayout from '@/layouts/MainLayout.vue'
const routes = [
  { path: '/login', name: 'Login', component: Login },
  { path: '/', component: MainLayout, children: [ { path: '', name: 'Dashboard', component: Dashboard } ] }
]
const router = createRouter({ history: createWebHistory(), routes })
export default router
"@
Write-File "src/router/index.js" $router

$store = @"
import { defineStore } from 'pinia'
import { ref } from 'vue'
export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const setUser = (u) => user.value = u
  const clear = () => user.value = null
  return { user, setUser, clear }
})
"@
Write-File "src/store/auth.js" $store

$i18n = @"
import { createI18n } from 'vue-i18n'
const messages = {
  en: { message: { welcome: 'Welcome', login: 'Login' } },
  vi: { message: { welcome: 'Chào mừng', login: 'Đăng nhập' } }
}
export default createI18n({ locale: 'en', fallbackLocale: 'en', messages })
"@
Write-File "src/i18n/index.js" $i18n

$firebase = @"
import { initializeApp } from 'firebase/app'
import { getAuth, GoogleAuthProvider, GithubAuthProvider, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut } from 'firebase/auth'
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID
}
const app = initializeApp(firebaseConfig)
const auth = getAuth(app)
const googleProvider = new GoogleAuthProvider()
const githubProvider = new GithubAuthProvider()
export { auth, googleProvider, githubProvider, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut }
"@
Write-File "src/services/firebase.js" $firebase

$stomp = @"
import { Client } from '@stomp/stompjs'
import SockJS from 'sockjs-client'
class StompService {
  constructor() { this.client = null }
  connect(url, onConnect) {
    this.client = new Client({
      webSocketFactory: () => new SockJS(url),
      reconnectDelay: 5000,
      onConnect: (frame) => { if (onConnect) onConnect(frame) }
    })
    this.client.activate()
  }
  subscribe(dest, cb) { if (!this.client) return; return this.client.subscribe(dest, (msg) => cb(msg)) }
  publish(dest, body) { if (!this.client) return; this.client.publish({ destination: dest, body }) }
}
export default new StompService()
"@
Write-File "src/services/stomp.js" $stomp

$layout = @"<template>
  <div class="wrapper">
    <AppHeader />
    <AppSidebar />
    <div class="content-wrapper">
      <section class="content">
        <div class="container-fluid">
          <div class="row">
            <div class="col-md-2"><LeftSidebar /></div>
            <div class="col-md-8"><router-view /></div>
            <div class="col-md-2"><RightSidebar /></div>
          </div>
        </div>
      </section>
    </div>
    <AppFooter />
  </div>
</template>
<script setup>
import AppHeader from '@/components/AppHeader.vue'
import AppSidebar from '@/components/AppSidebar.vue'
import AppFooter from '@/components/AppFooter.vue'
import LeftSidebar from '@/components/LeftSidebar.vue'
import RightSidebar from '@/components/RightSidebar.vue'
</script>
"@
Write-File "src/layouts/MainLayout.vue" $layout

$header = @"<template>
  <nav class="main-header navbar navbar-expand navbar-white navbar-light">
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
      </li>
      <li class="nav-item d-none d-sm-inline-block">
        <a href="#" class="nav-link">Home</a>
      </li>
    </ul>
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <select v-model="$i18n.global.locale">
          <option value="en">EN</option>
          <option value="vi">VI</option>
        </select>
      </li>
    </ul>
  </nav>
</template>
<script setup>
</script>
"@
Write-File "src/components/AppHeader.vue" $header

$sidebar = @"<template>
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <a href="#" class="brand-link">
      <span class="brand-text font-weight-light">AdminLTE Vue</span>
    </a>
    <div class="sidebar">
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
          <li class="nav-item has-treeview">
            <a href="#" class="nav-link">
              <i class="nav-icon fas fa-tachometer-alt"></i>
              <p>Level 1<i class="right fas fa-angle-left"></i></p>
            </a>
            <ul class="nav nav-treeview">
              <li class="nav-item has-treeview">
                <a href="#" class="nav-link">
                  <i class="far fa-circle nav-icon"></i>
                  <p>Level 2<i class="right fas fa-angle-left"></i></p>
                </a>
                <ul class="nav nav-treeview">
                  <li class="nav-item">
                    <router-link class="nav-link" to="/">Level 3 Item</router-link>
                  </li>
                  <li class="nav-item">
                    <router-link class="nav-link" to="/">Another Level 3</router-link>
                  </li>
                </ul>
              </li>
              <li class="nav-item">
                <router-link class="nav-link" to="/">Level 2 Item</router-link>
              </li>
            </ul>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/">Dashboard</router-link>
          </li>
        </ul>
      </nav>
    </div>
  </aside>
</template>
"@
Write-File "src/components/AppSidebar.vue" $sidebar

$footer = @"<template>
  <footer class="main-footer">
    <div class="float-right d-none d-sm-inline">Anything you want</div>
    <strong>Copyright &copy; 2025</strong>
  </footer>
</template>
"@
Write-File "src/components/AppFooter.vue" $footer

$left = @"<template>
  <div>
    <div class="card">
      <div class="card-header">Left</div>
      <div class="card-body">Left sidebar content</div>
    </div>
  </div>
</template>
"@
Write-File "src/components/LeftSidebar.vue" $left

$right = @"<template>
  <div>
    <div class="card">
      <div class="card-header">Right</div>
      <div class="card-body">Right sidebar content</div>
    </div>
  </div>
</template>
"@
Write-File "src/components/RightSidebar.vue" $right

$login = @"<template>
  <div class="login-page" style="max-width:420px;margin:40px auto;">
    <div class="card card-outline card-primary">
      <div class="card-header text-center"><h4>{{ $t('message.login') }}</h4></div>
      <div class="card-body">
        <form @submit.prevent="onEmailLogin">
          <div class="input-group mb-3">
            <input v-model="email" type="email" class="form-control" placeholder="Email" required>
          </div>
          <div class="input-group mb-3">
            <input v-model="password" type="password" class="form-control" placeholder="Password" required>
          </div>
          <button class="btn btn-primary btn-block">Login</button>
        </form>
        <hr />
        <button class="btn btn-danger btn-block" @click="onGoogle">Sign in with Google</button>
        <button class="btn btn-dark btn-block" @click="onGithub">Sign in with GitHub</button>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { auth, googleProvider, githubProvider, signInWithPopup, signInWithEmailAndPassword } from '@/services/firebase'
import { useAuthStore } from '@/store/auth'
const email = ref('')
const password = ref('')
const router = useRouter()
const authStore = useAuthStore()
async function onGoogle(){
  try{ const result = await signInWithPopup(auth, googleProvider); authStore.setUser(result.user); router.push('/') }catch(e){ console.error(e) }
}
async function onGithub(){
  try{ const result = await signInWithPopup(auth, githubProvider); authStore.setUser(result.user); router.push('/') }catch(e){ console.error(e) }
}
async function onEmailLogin(){
  try{ const res = await signInWithEmailAndPassword(auth, email.value, password.value); authStore.setUser(res.user); router.push('/') }catch(e){ console.error(e) }
}
</script>
"@
Write-File "src/views/Login.vue" $login

$dashboard = @"<template>
  <div>
    <h3>{{ $t('message.welcome') }}</h3>
    <p>Center content area. Replace with your dashboard components.</p>
  </div>
</template>
"@
Write-File "src/views/Dashboard.vue" $dashboard

$indexHtml = Get-Content index.html -Raw
$indexHtml = $indexHtml -replace '<body>', '<body class="hold-transition sidebar-mini layout-fixed">'
Write-File "index.html" $indexHtml

$pkg = Get-Content package.json -Raw | ConvertFrom-Json
$pkg.scripts.start = "vite"
$pkg.scripts.dev = "vite"
$pkg.scripts.build = "vite build"
$pkg.scripts.preview = "vite preview"
$pkg | ConvertTo-Json -Depth 10 | Out-File -FilePath package.json -Encoding UTF8

Write-Host "Scaffold complete with 3-level menubar." -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1) Edit .env.local and fill Firebase config values." -ForegroundColor Yellow
Write-Host "  2) Configure Firebase console: enable Google and GitHub providers." -ForegroundColor Yellow
Write-Host "  3) Run '$PackageManager run dev' to start development server." -ForegroundColor Yellow

Write-Host "==> Cài đặt Lint/Format (ESLint, Prettier, Stylelint, HTMLHint)..."
npm install --save-dev `
  eslint eslint-plugin-vue prettier eslint-config-prettier eslint-plugin-prettier `
  stylelint stylelint-config-standard stylelint-config-prettier stylelint-order htmlhint

# Tạo file cấu hình
@"
module.exports = {
  root: true,
  env: { node: true },
  extends: [
    'eslint:recommended',
    'plugin:vue/vue3-recommended',
    'plugin:prettier/recommended'
  ],
  parserOptions: { ecmaVersion: 2020 },
  rules: { 'vue/multi-word-component-names': 'off' }
};
"@ | Out-File .eslintrc.cjs -Encoding UTF8

@"
{
  "semi": true,
  "singleQuote": true,
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

Write-Host "==> Đã thêm cấu hình Lint/Format"

