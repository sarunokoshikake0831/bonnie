'use strict'

require('./app-header.tag')
require('./app-footer.tag')
require('./login-form.tag')
require('./report-registration.tag')
require('./report-search.tag')
require('./change-password.tag')

const XHR = require('superagent')

<app-content>
  <style scoped>
    main          { margin-top: 8px     }
    h4, h5        { color:      #ef5350 }
    .div__fogged  { opacity:    0.2     }

    .tmp__mounted {
      width:  100%;
      height: 100%;
    }

    .tmp__unmounted {
      width:  0%;
      height: 0%;
    }
  </style>

  <div class={ tmp == null? "div__clear": "div__fogged" }>
    <app-header />

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
            <report-search token={ access_token } user={ user } />
          </div>
        </div>
      </div>
    </main>

    <app-footer />
  </div>

  <tmp class={ tmp == null? 'tmp__unmounted': 'tmp__mounted' }></tmp>

  <script>
    this.access_token = null
    this.tmp          = null

    this.on('mount', () => {
        this.tmp = riot.mount('tmp', 'login-form', { login: this.login })[0]
        this.update()
    })

    unmount_tmp() {
        this.tmp.unmount(true)
        this.tmp = null
        this.update()
        $('ul.tabs').tabs() // Materialize の jquery 用コード。うざい。
        riot.route('/')
    }

    login(account, password) {
        XHR.post('/v1/oauth2/token').type('form').send({
            grant_type: 'password',
            account:    account,
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
                this.user         = res.body.user
                this.unmount_tmp()
            } else if (res) {
                alert(`原因不明のエラーが発生しました: ${res.status}`)
            } else {
                alert('原因不明のエラーが発生しました。')
            }
        })
    }

    change_password(old_password, new_password) {
        XHR.put('/v1/users/' + this.user.account + '/password').set({
            Authorization: `Bearer ${this.access_token}`
        }).send({
            old_password: old_password,
            new_password: new_password
        }).end( (err, res) => {
            if (err && res && res.status == 403) {
                alert('古いパスワードが間違っています。')
            } else if (err && res) {
                alert('サーバでエラーが発生しました。')
            } else if (err) {
                alert('サーバとの通信に失敗しました。')
            } else if (res.ok) {
                alert('更新しました。')
            } else if (res) {
                alert(`原因不明のエラーが発生しました: ${res.status}`)
            } else {
                alert('原因不明のエラーが発生しました。')
            }

            this.unmount_tmp()
        })
    }

    riot.route.base('/')

    riot.route('logout', () => {
        /*
         * この tag は事実上 DOM の最上位に位置するため、
         * 自身を unmount すれば、中身をきれいさっぱり掃除することができる。
         * とてもお手軽。
         */
        this.access_token = null
        this.user         = null
        this.unmount(true)
        riot.mount('app-content')
        riot.route('/')
    })

    riot.route('change-password', () => {
        this.tmp = riot.mount('tmp', 'change-password', {
            cancel:          this.unmount_tmp,
            change_password: this.change_password,
            user:            this.user
        })[0]

        riot.route('/')
        this.update()
    })

    riot.route.start(true)
  </script>
</app-content>
