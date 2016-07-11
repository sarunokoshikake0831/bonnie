'use strict'

<login-form>
  <style scoped>
    :scope {
      width:           100%;
      height:          100%;
      display:         flex;
      justify-content: center;
      position:        absolute;
      top:             0;
      left:            0;
    }

    form  {
      width:      256px;
      margin-top: 128px;
      text-align: right;
    }

    input { width: 192px }
  </style>

  <form action="#" name="login">
    <input type="text"     name="account"  placeholder="アカウント" />
    <input type="password" name="password" placeholder="パスワード" />
    <button class="waves-effect waves-light btn" onclick={ submit }>
      ログイン
    </button>
  </form>

  <script>
    this.on('mount', () => window.scrollTo(0, 0) )

    submit(e) {
        this.opts.login(this.account.value, this.password.value)
        this.login.reset()
    }
  </script>
</login-form>
