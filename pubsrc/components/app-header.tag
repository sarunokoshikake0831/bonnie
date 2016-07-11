'use strict'

<app-header>
  <style scoped>
    #logo {
      width:      48px;
      height:     48px;
      margin-top:  8px;
    }
  </style>

  <nav>
    <div class="container">
      <div class="nav-wrapper">
        <a href="http://www.kdu.ac.jp" class="brand-logo">
          <img id="logo" src="img/KDU_logo_white-alpha.png" />
        </a>
        <ul id="nav-mobile" class="right hide-on-med-and-down">
          <li><a href="/logout">ログアウト</a></li>
        </ul>
      </div>
    </div>
  </nav>
</app-header>
