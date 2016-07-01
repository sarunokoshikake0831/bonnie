'use strict'

require('./app-header.tag')
require('./app-footer.tag')
require('./login-form.tag')
require('./report-registration.tag')
require('./report-search.tag')

const XHR = require('superagent')

<app-content>
  <style scoped>
    main        { margin-top: 8px     }
    h4, h5      { color:      #ef5350 }
    .div__logged_out { opacity:    0.2     }
  </style>

  <div class={ access_token? "div__logged_in": "div__logged_out" }>
    <div class="navbar-fixed">
      <app-header logout={ logout } />
    </div>

    <main>
      <div class="container">
        <div class="row">
          <div class="col s12">
            <ul class="tabs">
              <li class="tab col s3">
                <a class="active" href="#register">登録</a>
              </li>
              <li class="tab col s3"><a href="#search">検索</a></li>
            </ul>
          </div>
    
          <div id="register" class="col s12">
            <report-registration token={ access_token } />
          </div>
          <div id="search" class="col s12">
            <report-search token={ access_token } />
          </div>
        </div>
      </div>
    </main>

    <app-footer />
  </div>

  <login-form if={ !access_token } login={ login } />

  <script>
    this.access_token = null

    login(account, password) {
        XHR.post('/v1/oauth2/token').type('form').send({
            grant_type: 'password',
            username:   account,
            password:   password
        }).end( (err, res) => {
            if (err && res && res.status == 401) {
                alert('アカウントとパスワードの組み合わせが間違っています。')
            } else if (err && res) {
                alert('サーバでエラーが発生しました。');
            } else if (err) {
                alert('サーバとの通信に失敗しました。');
            } else if (res.ok) {
                this.access_token = res.body.access_token
                this.update()
                $('ul.tabs').tabs()
            } else {
                alert(`原因不明のエラーが発生しました: ${res.status}`)
            }
        })
    }

    logout() {
        this.access_token = null
        this.unmount(true)
        riot.mount('app-content')
    }
  </script>
</app-content>
