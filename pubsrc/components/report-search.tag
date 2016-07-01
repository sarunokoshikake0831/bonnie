'use strict'

require('./datepicker.tag')
require('./search-result.tag')

const XHR       = require('superagent')
const constants = require('./constants.json')

<filter-number>
  <div class="row">
    <div class="input-field col s4">
      <input id="filter-number"
             onchange={ opts.setter }
             type="text"
             value={ opts.condition.number } />
      <label for="filter-number">レポート番号</label>
    </div>
  </div>
</filter-number>

<filter-period>
  <style scoped>
    .div__this {
      display:       flex;
      margin-top:    24px;
      margin-bottom: 32px;
    }

    .any__right-space  { margin-right:  24px }
    .div__datepicker  { width:         96px }
  </style>

  <div class="div__this">
    <h5 class="any__right-space">発生日</h5>
    <div class="div__datepicker any__right-space">
      <datepicker setter={ opts.setter('from') }
                  value={ opts.condition.date.from } />
    </div>
    <p class="any__right-space">〜</p>
    <div class="div__datepicker any__right-space">
      <datepicker setter={ opts.setter('to') }
                  value={ opts.condition.date.to } />
    </div>
  </div>
</filter-period>

<filter-type>
  <style scoped>
    .div__this { margin-bottom: 32px }
  </style>

  <h5>レポート種別</h5>
  <div class="div__this card-panel">
    <ul>
      <li>
        <input checked={ opts.condition.type.incident }
               id="filter-type-incident"
               onclick={ opts.setter('type', 'incident') }
               type="checkbox" />
        <label for="filter-type-incident">インシデント</label>
      </li>
      <li>
        <input checked={ opts.condition.type.trouble }
               id="filter-type-trouble"
               onclick={ opts.setter('type', 'trouble') }
               type="checkbox" />
        <label for="filter-type-trouble">苦情・トラブル</label>
      </li>
    </ul>
  </div>
</filter-type>

<filter-state>
  <style scoped>
    .div__this { margin-bottom: 32px }
  </style>

  <h5>状態</h5>
  <div class="div__this card-panel">
    <ul>
      <li>
        <input checked={ opts.condition.state.unreported }
               id="filter-state-unreported"
               onclick={ opts.setter('state', 'unreported') }
               type="checkbox" />
        <label for="filter-state-unreported">未報告</label>
      </li>
      <li>
        <input checked={ opts.condition.state.reported }
               id="filter-state-reported"
               onclick={ opts.setter('state', 'reported') }
               type="checkbox" />
        <label for="filter-state-reported">
          最新版を報告済み (その後更新されていない)
        </label>
      </li>
      <li>
        <input checked={ opts.condition.state.dirty }
               id="filter-state-dirty"
               onclick={ opts.setter('state', 'dirty') }
               type="checkbox" />
        <label for="filter-state-dirty">
          報告後更新された
        </label>
      </li>
    </ul>
  </div>
</filter-state>

<filter-event>
  <style scoped>
    .div__this { margin-bottom: 32px }
  </style>

  <h5>事象内容 { opts.eventid }</h5>
  <div class="div__this card-panel">
    <ul>
      <li condition={ opts.condition }
          each={ e in opts.events } 
          pfx={ pfx }
          setter={ opts.setter }>
        <input checked={ opts.condition[opts.pfx][e.id] }
               id={ 'filter-' + opts.pfx + '-' + e.id }
               onclick={ opts.setter(opts.pfx, e.id) }
               type="checkbox" />
        <label for={ 'filter-' + opts.pfx + '-' + e.id }>
          { e.desc }
        </label>
      </li>
    </ul>
  </div>

  <script>
    this.pfx = 'event' + this.opts.eventid
  </script>
</filter-event>

<filter-keyword>
  <div class="row">
    <div class="input-field col s12">
      <input id="filter-keyword"
             onchange={ opts.setter }
             type="text"
             value={ opts.condition.keyword } />
      <label for="filter-keyword">検索テキスト</label>
    </div>
  </div>
</filter-keyword>

<report-search>
  <style scoped>
    .div__buttons {
      margin-top: 24px;
      text-align: right;
    }

    .div__search-result { margin-top: 32px }
  </style>

  <ul id="slide-out" class="side-nav">
    <li><a href="#search-condition">検索</a></li>
    <li each={ report in search_result }>
      <a href={ '#report-number-' + report.number }>
        { 'No.' + report.number + ' - ' + report.title }
      </a>
    </li>
  </ul>
  <a href="#" data-activates="slide-out" class="button-collapse"></a>

  <form action="#" id="search-condition">
    <filter-number condition={ search_condition } setter={ set('number') } />
    <filter-period condition={ search_condition } setter={ set_date } />
    <filter-type   condition={ search_condition } setter={ toggle } />
    <filter-state  condition={ search_condition } setter={ toggle } />

    <filter-event condition={ search_condition }
                  eventid="0"
                  events={ constants.event0 }
                  if={ need_display('event') }
                  setter={ toggle } />

    <filter-event condition={ search_condition }
                  eventid="1"
                  events={ constants.event1 }
                  if={ need_display('event') }
                  setter={ toggle } />

    <filter-keyword condition={ search_condition } setter={ set('keyword') } /> 

    <div class="div__buttons">
      <button class="waves-effect waves-light btn" onclick={ search }>
        検索
      </button>
      <button class="waves-effect waves-light btn" onclick={ reset }>
        リセット
      </button>
    </div>
  </form>

  <div class="div__search-result" if={ search_result != null }>
    <search-result flipper={ show_toc } reports={ search_result } />
  <div>

  <script>
    this.constants     = constants
    this.search_result = null

    set(name) {
        return e => {
            this.search_condition[name] = e.target.value
            this.update()
        }
    }

    toggle(name, id) {
        return () => {
            this.search_condition[name][id] = !this.search_condition[name][id]
            this.update()
        }
    }

    set_date(id) {
        return date => {
            this.search_condition.date[id] = date
            this.update()
        }
    }

    need_display(component) {
        switch(component) {
        case 'event':
            let type = this.search_condition.type

            return type.incident || !(type.incident || type.trouble)
        }

        return true
    }

    search() {
        XHR.get('/v1/reports').set({
            Authorization: `Bearer ${this.opts.token}`
        }).query(this.search_condition).end( (err, res) => {
            if (err && res && res.status == 400) {
                alert('ヒット件数が多過ぎます。もっと絞り込んで下さい。')
            } else if (err && res) {
                alert('サーバでエラーが発生しました。')
            } else if (err) {
                alert('サーバとの通信に失敗しました。')
            } else if (res && res.ok) {
                this.search_result = res.body.reports
                this.update()
                Materialize.updateTextFields()
                $('select').material_select('destroy')
                $('select').material_select()
            } else {
                alert(`原因不明のエラーが発生しました: ${res.status}`)
            }
        })
    }

    reset () {
        this.search_result = null

        this.search_condition = {
            number: '',

            date: {
                from: '',
                to:   ''
            },

            type: {
                incident: false,
                trouble:  false
            },

            state: {
                unreported: false,
                reported:   false,
                dirty:      false
            },
    
            event0: {},
            event1: {},
    
            keyword: ''
        }
    
        constants.event0.forEach( (e) => {
            this.search_condition.event0[e.id] = false
        })
    
        constants.event1.forEach( (e) => {
            this.search_condition.event1[e.id] = false
        })

        this.update()
    }

    show_toc() { $('.button-collapse').sideNav('show') }

    this.on('mount', () => {
        $('.button-collapse').sideNav({
            menuWidth:    768,
            edge:         'left',
            closeOnClick: true
        })
    })

    this.reset()
  </script>
</report-search>
