'use strict'

require('./report-common.tag')

const XHR = require('superagent')

const constants         = require('./constants.json')
const observable_report = require('./observable-report')

<report>
  <style scoped>
    hr { margin: 32px 0 32px 0 }

    .div__buttons {
      margin-top: 24px;
      text-align: right;
    }
  </style>

  <div id={ 'report-number-' + opts.report.number }>
    <h3 onclick={ opts.flipper }>No. { opts.report.number }</h3>

    <report-common props={ state } />

    <div class="div__buttons">
      <button class={ is_reported? disabled_button: enabled_button }
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
    this.is_reported = this.opts.report.is_reported

    this.enabled_button  = 'waves-effect waves-light btn'
    this.disabled_button = 'btn disabled'

    report_this() {
        this.is_reported = true
        /* XXX */
        this.update()
    }

    this.state.on(update_event, () => {
        this.is_changed = true
        this.update()
    })
  </script>
</report>

<search-result>
  <h6>{ opts.reports.length } 件がヒットしました。</h6>
  <hr />

  <report each={ report in opts.reports }
          flipper={ show_toc }
          report={ report } />
  </script>

  <script>
    show_toc() { this.opts.flipper() }
  </script>
</search-result>
