'use strict'

<change-password>
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

  <form action="#" name="changepassword">
    <input type="password" name="old"  placeholder="旧パスワード" />
    <input type="password" name="new0" placeholder="新パスワード" />
    <input type="password" name="new1" placeholder="新パスワード (確認用)" />
    <button class="waves-effect waves-light btn" onclick={ submit }>
      変更
    </button>
  </form>

  <script>
    this.on('mount', () => window.scrollTo(0, 0) )

    is_secure(password) {
        let is_facile = false

        if (password.length < 8) {
            is_facile = true
        }

        if (passsword.match(/^\d+$/) ) {
            is_facile = true
        }

        if (password.match(/^[a-z]+$/) ) {
            is_facile = true
        }

        if (password.match(/^[A-Z]+$/) ) {
            is_facile = true
        }

        if (password == this.user.account) {
            is_facile = true
        }

        return !is_facile
    }

    submit(e) {
        const old  = this.old.value
        const new0 = this.new0.value
        const new1 = this.new1.value

        if (old == new0 || !this.is_secure(new0) ) {
            alert('新パスワードが安直過ぎます。')
        } else if (new0 == new1) {
            this.opts.change_password(old, new0)
            this.changepassword.reset()
        } else {
            alert('新パスワードが確認用と一致しません。')
        }
    }
  </script>
</change-password>
