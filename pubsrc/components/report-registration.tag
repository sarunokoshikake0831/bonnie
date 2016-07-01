'use strict'

require('./report-common.tag')

const moment            = require('moment')
const XHR               = require('superagent')
const observable_report = require('./observable-report')

<report-registration>
  <style scoped>
    .div__buttons {
      margin-top: 24px;
      text-align: right;
    }
  </style>

  <form action="#">
    <report-common props={ state } />
    <div class="div__buttons">
      <button class="waves-effect waves-light btn" onclick={ register }>
        登録
      </button>
      <button class="waves-effect waves-light btn" onclick={ reset }>
        リセット
      </button>
    </div>
  </form>

  <script>
    const update_event = 'renew-report-registration'
    this.state = new observable_report(update_event)
    this.state.on(update_event, () => this.update() )

    register() {
        if (this.state.title == '') {
            alert('表題を入力して下さい。')
            return;
        }

        if (this.state.detail == '') {
            alert('詳細を入力して下さい。')
            return;
        }

        XHR.post('/v1/reports').set({
            Authorization: `Bearer ${this.opts.token}`
        }).send(this.state.make_report() ).end( (err, res) => {
            if (err && res) {
                alert('サーバでエラーが発生しました。')
            } else if (err) {
                alert('サーバとの通信に失敗しました。')
            } else if (res.ok) {
                alert(`No.${res.body.number} で登録しました。`)
                this.reset()
            } else {
                alert(`原因不明のエラーが発生しました: ${res.status}`)
            }
        })
    }

    reset() {
        this.state.reset()
        this.update()
        Materialize.updateTextFields()


        /*
         * ここから不可解な動作の対策コード
         */
        $('select').material_select('destroy')
        $('select').material_select()
        /*
         * ここまで
         */
    }
  </script>
</report-registration>
