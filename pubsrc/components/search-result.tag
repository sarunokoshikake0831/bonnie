'use strict'

require('./report-common.tag')

const XHR = require('superagent')

const constants         = require('./constants.json')
const observable_report = require('./observable-report')

<report>
  <style scoped>
    .span__number       { font-size: 256% }
    .span__number:hover { cursor:    pointer }
    .span__status       { font-size: 160% }

    .div__buttons {
      margin-top: 24px;
      text-align: right;
    }

    hr { margin: 32px 0 32px 0 }
  </style>

  <div id={ 'report-number-' + opts.report.number }>
    <div> 
      <span class="span__number" onclick={ opts.flipper }>
        No. { opts.report.number }
      </span>
      <span class="span__status">({ get_status_name() })</span>
    </div>

    <report-common props={ state } />

    <div class="div__buttons">
      <button class={ can_report()? enabled_button: disabled_button }
              onclick={ report_this }>
        報告済みにする
      </button>
      <button class="waves-effect waves-light btn" onclick={ () => {} }>
        削除
      </button>
      <button class={ is_changed? enabled_button: disabled_button }
              onclick={ () => {} }>
        更新
      </button>
    </div>
  </div>
  <hr />
  
  <script>
    const update_event = 'renew-' + Math.random().toString(36).slice(-8)

    this.state       = new observable_report(update_event, this.opts.report)
    this.is_changed  = false
    this.is_dirty    = this.opts.report.is_dirty
    this.is_reported = this.opts.report.is_reported
    this.version     = this.opts.version

    this.disabled_button = 'btn disabled'
    this.enabled_button  = 'waves-effect waves-light btn'

    get_status_name() {
        if (!this.is_reported) {
            return '未報告'
        } else if (!this.is_dirty) {
            return '最新版を報告済み (その後更新されていない)'
        } else {
            return '報告後更新された'
        }
    }

    can_report() { return !this.is_reported && !this.is_changed }

    report_this() {
        XHR.put(`/v1/reports/${this.opts.report._id}`).set({
            Authorization:            `Bearer ${this.opts.token}`,
            'X-HTTP-Method-Override': 'PATCH'
        }).query({ version: this.version }).send({
            is_reported: true
        }).end( (err, res) => {
            if (err && res && res.status == 409) {
                alert('既に更新されています。再度検索して下さい。')
            } else if (err && res) {
                alert('サーバでエラーが発生しました。')
            } else if (res && res.ok) {
                this.is_reported = true
                this.version++
                this.update()
            } else {
                alert(`原因不明のエラーが発生しました: ${res.status}`)
            }
        })
    }

    this.state.on(update_event, () => {
        this.opts.token
        this.is_changed = true
        this.update()
    })
  </script>
</report>

<search-result>
  <h6>{ opts.reports.length } 件がヒットしました。</h6>
  <hr />

  <report each={ report in opts.reports }
          flipper={ parent.opts.flipper }
          report={ report }
          token={ parent.opts.token } />
</search-result>
